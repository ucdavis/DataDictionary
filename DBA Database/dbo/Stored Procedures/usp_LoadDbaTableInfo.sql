-- =============================================
-- Author:		Ken Taylor
-- Create date: September 17, 2013
-- Description:	Populate the [dbo].[TableInfo] table for all linked servers from the campus data warehouse..
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC @return_value = [dbo].[usp_LoadDbaTableInfo] @IsDebug = 1

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
-- 20140307 by kjt: Added logic to ignore duplicate UCD_HARRIS_ADDRESS table.
-- 20140312 by kjt: Revised to use MERGE statements.
--  2014-04-01 by kjt: Added param @IncludeBannerItems to include Banner items if desired.
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaTableInfo] 
	@IncludeBannerItems bit = 0, --Set to 1 to include Banner info.
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
	--IF @IsDebug = 0 TRUNCATE TABLE [dbo].[TableInfo]
	--ELSE Print '	TRUNCATE TABLE [dbo].[TableInfo]
--'
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
	SELECT * FROM dbo.udf_GetOracleLinkedServers(@IncludeBannerItems);

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
		SELECT @TSQL = '
	MERGE dbo.TableInfo AS D1
	USING (
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
		        AND (T.OWNER, T.TABLE_NAME, T.NUM_ROWS) NOT IN ((''''ADVANCEREP'''', ''''UCD_HARRIS_address'''', 0))
			--GROUP BY  T.OWNER, T.TABLE_NAME, TC.COMMENTS, T.NUM_ROWS, TABLE_TYPE --HAVING T.NUM_ROWS > 0
			--ORDER BY 1, 2, 3
			'') AS derivedtbl_1

		UNION ALL

		SELECT ''' + @LinkedServerName + ''' AS LinkedServerName, [Owner], VIEW_NAME TableName, Comments, [Text], NULL NumRows, TABLE_TYPE TableType
		FROM OPENQUERY(' + @LinkedServerName + ', ''select av.owner, av.view_name, atc.COMMENTS, av.text, TABLE_TYPE from all_views av
		left outer join all_tab_comments atc on av.owner = atc.owner AND av.VIEW_NAME = atc.TABLE_NAME AND TABLE_TYPE = ''''VIEW''''
		where (av.owner not like ''''%SYS%'''' AND av.owner not like ''''%$%'''' AND av.owner not like ''''XDB'''') AND (av.VIEW_NAME NOT LIKE ''''%$%'''')
		--ORDER BY av.VIEW_NAME, av.OWNER
		'')
		--ORDER BY [LinkedServerName], [Owner], TableName
	) S1 ON D1.LinkedServerName = S1.LinkedServerName AND D1.[Owner] = S1.[Owner] AND D1.TableName = S1.TableName

	WHEN MATCHED THEN UPDATE set
	   D1.[Comments] = ISNULL(S1.[Comments], D1.[Comments]) 
      ,D1.[Text] = S1.[Text]
      ,D1.[NumRows] = ISNULL(S1.[NumRows], D1.[NumRows])
	  ,D1.[TableType] = S1.[TableType]

	WHEN NOT MATCHED BY TARGET THEN INSERT VALUES (
		LinkedServerName, 
		[Owner], 
		TableName, 
		Comments, 
		[Text], 
		NumRows, 
		TableType
	)

	--WHEN NOT MATCHED BY SOURCE THEN DELETE
	;' 
		IF @IsDebug = 1
			PRINT @TSQL
		ELSE
			EXEC(@TSQL)

		FETCH NEXT FROM MyCursor INTO @LinkedServerName
	END
	CLOSE MyCursor
	DEALLOCATE MyCursor

END
