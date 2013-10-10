-- =============================================
-- Author:		Ken Taylor
-- Create date: September 17, 2013
-- Description:	Populate the [dbo].[TableInfo] table for all linked servers from the campus data warehouse..
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC [dbo].[usp_LoadDbaTableInfo] @IsDebug = 1

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaTableInfo] 
	@IsDebug bit = 0 --Set to 1 to print SQL only.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	--For Debugging
	DECLARE @IsDebug bit = 1
	*/
	IF @IsDebug = 0 TRUNCATE TABLE [dbo].[TableInfo]
	ELSE Print '	TRUNCATE TABLE [dbo].[TableInfo]
'
--DECLARE @LinkedServersTable TABLE (Name varchar(100))
	DECLARE @OracleLinkedServers TABLE (
		SRV_NAME varchar(100), 
		SRV_PROVIDERNAME varchar(200), 
		SRV_PRODUCT varchar(100), 
		SRV_DATASOURCE varchar(500),
		SRV_PROVIDERSTRING varchar(500),
		SRV_LOCATION varchar(200),
		SRV_CAT varchar(100)
	)

	INSERT INTO @OracleLinkedServers
	EXEC sp_linkedservers

	If @IsDebug = 1
		SELECT SRV_NAME Name FROM @OracleLinkedServers WHERE SRV_PROVIDERNAME = 'OraOLEDB.Oracle' 

	DECLARE MyCursor CURSOR FOR SELECT SRV_NAME Name 
	FROM @OracleLinkedServers
	WHERE SRV_PROVIDERNAME = 'OraOLEDB.Oracle'

	DECLARE @TSQL varchar(MAX) = ''
	DECLARE @LinkedServerName varchar(100) = ''
	OPEN MyCursor
	FETCH NEXT FROM MyCursor INTO @LinkedServerName
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		SELECT @TSQL = 'INSERT INTO dbo.TableInfo 
		SELECT ''' + @LinkedServerName +''' AS LinkedServerName, [Owner], TABLE_NAME TableName, Comments, [Text], NUM_ROWS NumRows, TABLE_TYPE TableType
		FROM OPENQUERY(' + @LinkedServerName + ', ''
			SELECT
				T.OWNER, T.TABLE_NAME, TC.COMMENTS, '''''''' AS TEXT, T.NUM_ROWS, TABLE_TYPE 
			FROM all_tables T
			LEFT OUTER JOIN all_tab_comments TC ON T.OWNER = TC.OWNER AND T.TABLE_NAME = TC.TABLE_NAME AND TABLE_TYPE = ''''TABLE''''
			WHERE (T.TABLE_NAME NOT IN (''''CK_LOG'''', ''''EXCEPTIONS'''') AND T.TABLE_NAME NOT LIKE ''''%$%'''' AND T.TABLE_NAME NOT LIKE ''''DUMMY%'''' AND T.TABLE_NAME NOT LIKE ''''%_AUDIT''''
				AND T.TABLE_NAME NOT LIKE ''''%_TEMP''''
				AND T.TABLE_NAME NOT LIKE ''''%_OLD%'''' AND T.TABLE_NAME NOT LIKE ''''TWG%'''' AND T.TABLE_NAME NOT LIKE ''''%_SRF%'''' AND T.TABLE_NAME NOT LIKE ''''%_1111'''' AND T.TABLE_NAME NOT LIKE ''''%_TMP'''' AND T.TABLE_NAME NOT LIKE ''''WURFEED_%'''' AND T.TABLE_NAME NOT LIKE ''''%_BKP'''' AND T.TABLE_NAME NOT LIKE ''''%_WORK'''')
				AND  (T.owner not like ''''%SYS%'''' AND T.owner not like ''''%$%'''' AND T.owner not like ''''XDB'''')
		
			--GROUP BY  T.OWNER, T.TABLE_NAME, TC.COMMENTS, T.NUM_ROWS, TABLE_TYPE HAVING T.NUM_ROWS > 0
			--ORDER BY 1, 2 
			'') AS derivedtbl_1

		UNION ALL

		SELECT ''' + @LinkedServerName + ''' AS LinkedServerName, [Owner], VIEW_NAME TableName, Comments, [Text], NULL NumRows, TABLE_TYPE TableType
		FROM OPENQUERY(' + @LinkedServerName + ', ''select av.owner, av.view_name, atc.COMMENTS, av.text, TABLE_TYPE from all_views av
		left outer join all_tab_comments atc on av.owner = atc.owner AND av.VIEW_NAME = atc.TABLE_NAME AND TABLE_TYPE = ''''VIEW''''
		where (av.owner not like ''''%SYS%'''' AND av.owner not like ''''%$%'''' AND av.owner not like ''''XDB'''') AND (av.VIEW_NAME NOT LIKE ''''%$%'''')
		--ORDER BY av.VIEW_NAME, av.OWNER
		'')
		ORDER BY [Owner], TableName
		'
		IF @IsDebug = 1
			PRINT @TSQL
		ELSE
			EXEC(@TSQL)

		FETCH NEXT FROM MyCursor INTO @LinkedServerName
	END
	CLOSE MyCursor
	DEALLOCATE MyCursor

END
