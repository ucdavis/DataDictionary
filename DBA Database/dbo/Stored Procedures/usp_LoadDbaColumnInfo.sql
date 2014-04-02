-- =============================================
-- Author:		Ken Taylor
-- Create date: September 18, 2013
-- Description:Populate the [dbo].[ColumnInfo] table for all linked servers from the campus data warehouse. 
--	and data types for the parameters provided.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC @return_value = [dbo].[usp_LoadDbaColumnInfo] @IsDebug = 1

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
-- 2013-10-30 by kjt: Revised to use new function dbo.udf_GetOracleLinkedServers().
-- 2014-03-07 by kjt: Revised to handle duplicate UC_HARRIS_ADDRESS table.
-- 2014-03-12 by kjt: Revised to use MERGE statements Vs. TRUNCATE and INSERT.
-- 2014-04-01 by kjt: Added param @IncludeBannerItems to include Banner items if desired.
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaColumnInfo] 
	@IncludeBannerItems bit = 0, --Set to 0 to include Banner info.
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
--	IF @IsDebug = 0 TRUNCATE TABLE [dbo].[ColumnInfo]
--	ELSE Print '	TRUNCATE TABLE [dbo].[ColumnInfo]
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
	MERGE dbo.ColumnInfo AS D1 
	USING (
	SELECT  LinkedServerName, [Owner],  TableName,  ColumnName,  ColumnComments,  DataType,  DataLength,  DataPrecision,  DataScale,  Nullable,  ColumnID
	FROM (
		SELECT  '''+@LinkedServerName+''' AS LinkedServerName, [Owner], TABLE_NAME TableName, COLUMN_NAME ColumnName, COLUMN_COMMENTS ColumnComments, DATA_TYPE DataType, DATA_LENGTH DataLength, DATA_PRECISION DataPrecision, DATA_SCALE DataScale, NULLABLE Nullable, COLUMN_ID ColumnID
		FROM OPENQUERY('+@LinkedServerName+',
			''SELECT C.OWNER, C.TABLE_NAME , C.COLUMN_NAME, CC.COMMENTS COLUMN_COMMENTS, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID
			 FROM ALL_TABLES A
			 INNER JOIN all_TAB_columns C ON A.OWNER = C.OWNER AND A.TABLE_NAME = C.TABLE_NAME
			 LEFT OUTER JOIN all_col_comments CC ON C.OWNER = CC.OWNER AND C.TABLE_NAME = CC.TABLE_NAME AND C.COLUMN_NAME = CC.COLUMN_NAME
			 WHERE (C.TABLE_NAME NOT IN (''''CK_LOG'''', ''''EXCEPTIONS'''') AND C.TABLE_NAME NOT LIKE ''''%$%'''' AND C.TABLE_NAME NOT LIKE ''''DUMMY%'''' AND C.TABLE_NAME NOT LIKE ''''%_AUDIT'''' AND  C.TABLE_NAME NOT LIKE ''''%_OLD%'''' AND C.TABLE_NAME NOT LIKE ''''TWG%'''' AND C.TABLE_NAME NOT LIKE ''''%_SRF%'''' AND C.TABLE_NAME NOT LIKE ''''%_1111'''' AND C.TABLE_NAME NOT LIKE ''''%_TMP'''' AND C.TABLE_NAME NOT LIKE ''''WURFEED_%'''' AND C.TABLE_NAME NOT LIKE ''''%_BKP'''' AND C.TABLE_NAME NOT LIKE ''''%_WORK'''')
				 AND (C.OWNER NOT LIKE ''''%SYS%'''' AND C.OWNER NOT LIKE ''''%$%'''' AND C.OWNER NOT LIKE ''''XDB'''')
				 AND (C.OWNER, C.TABLE_NAME, A.NUM_ROWS) NOT IN ((''''ADVANCEREP'''', ''''UCD_HARRIS_address'''', 0))
			 --ORDER BY C.OWNER, C.TABLE_NAME, C.COLUMN_ID
				 '') AS derivedtbl_1

		UNION ALL

		SELECT  '''+@LinkedServerName+''' AS LinkedServerName, [Owner], TABLE_NAME TableName, COLUMN_NAME ColumnName, COLUMN_COMMENTS ColumnComments, DATA_TYPE DataType, DATA_LENGTH DataLength, DATA_PRECISION DataPrecision, DATA_SCALE DataScale, NULLABLE Nullable, COLUMN_ID ColumnID
		FROM OPENQUERY('+@LinkedServerName+',
		  ''select av.owner, av.view_name TABLE_NAME, ac.COLUMN_NAME, acc.COMMENTS COLUMN_COMMENTS, ac.DATA_TYPE,
		      ac.DATA_LENGTH, ac.DATA_PRECISION, ac.DATA_SCALE, ac.NULLABLE, ac.COLUMN_ID
		   from all_views av
		   INNER join all_tab_columns ac ON av.OWNER = ac.OWNER AND av.VIEW_NAME = ac.TABLE_NAME
		   left outer join all_col_comments acc ON ac.OWNER = acc.OWNER AND ac.TABLE_NAME = acc.TABLE_NAME AND ac.COLUMN_NAME = acc.COLUMN_NAME
		   where (av.owner not like ''''%SYS%'''' AND av.owner not like ''''%$%'''' AND av.owner not like ''''XDB'''') AND (av.VIEW_NAME NOT LIKE ''''%$%'''')
		'') AS derivedtbl_2
		) t1
		--ORDER BY Owner, TableName, ColumnId
		) S1 ON D1.LinkedServerName = S1.LinkedServerName AND D1.[Owner] = S1.[Owner] AND D1.TableName = S1.TableName AND D1.ColumnName = S1.ColumnName

	WHEN MATCHED THEN UPDATE set
	   D1.[ColumnComments] = ISNULL(S1.[ColumnComments], D1.[ColumnComments]) 
      ,D1.[DataType] = S1.[DataType]
      ,D1.[DataLength] = S1.[DataLength]
	  ,D1.[DataPrecision] = S1.[DataPrecision]
	  ,D1.[DataScale] = S1.[DataScale]
	  ,D1.[Nullable] = S1.[Nullable]
	  ,D1.[ColumnID] = S1.[ColumnID]

	WHEN NOT MATCHED BY TARGET THEN INSERT VALUES (
		LinkedServerName, 
		[Owner],  
		TableName,  
		ColumnName,  
		ColumnComments,  
		DataType,  
		DataLength,  
		DataPrecision, 
		DataScale,  
		Nullable,  
		ColumnID
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
