-- =============================================
-- Author:		Ken Taylor
-- Create date: Octiber 5, 2013
-- Description:	Update the [dbo].[TableInfo] table with missing row counts for objects with TableType VIEW
--	where NumRows IS NULL.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC [dbo].[usp_UpdateDbaTableInfoWithMissingRowCounts] @IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
-- 2014-03-07 by kjt: Added filtering for bad views UCD_1295_RANDOM and STUDENT_DEGREE_V.
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateDbaTableInfoWithMissingRowCounts] 
	@IsDebug bit = 0 --Set to 1 to print SQL only.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- For debugging: cut and paste sproc between outside most BEGIN and END and the uncomment @IsDebug to run.
 --DECLARE @IsDebug bit = 0


	while EXISTS (
		SELECT DISTINCT  [LinkedServerName], [Owner], [Tablename]
		FROM [dbo].[TableInfo]
		where TableType = 'VIEW'   
		AND ([LinkedServerName]  NOT LIKE 'SIS_DEV' AND [Owner]  NOT LIKE 'BANINST1' --AND [TableName]   NOT LIKE 'G%V%'
		) 
		AND ([LinkedServerName]  NOT LIKE 'SIS' AND [Owner]  NOT LIKE 'UTILITY')
		AND ([LinkedServerName]  NOT LIKE 'AIS_STAGE' AND [Owner]  NOT LIKE 'ADVANCEREP' AND [TableName] NOT LIKE 'UCD_1295_RANDOM')
		AND ([LinkedServerName]  NOT LIKE 'ISODS_PROD' AND [Owner]  NOT LIKE 'PERSON' AND [TableName] NOT LIKE 'STUDENT_DEGREE_V')
		AND [Owner] NOT LIKE 'APEX_030200'
		AND [Owner] NOT LIKE 'ORDDATA'
		AND NumRows IS NULL
		)

		BEGIN
			DECLARE mycursor CURSOR FOR SELECT DISTINCT TOP 10 [LinkedServerName], [Owner], [Tablename]
			FROM [dbo].[TableInfo]
			where TableType = 'VIEW'   
			AND ([LinkedServerName]  NOT LIKE 'SIS_DEV' AND [Owner]  NOT LIKE 'BANINST1' --AND [TableName]   NOT LIKE 'G%V%'
			) 
			AND ([LinkedServerName]  NOT LIKE 'SIS' AND [Owner]  NOT LIKE 'UTILITY')
			AND ([LinkedServerName]  NOT LIKE 'AIS_STAGE' AND [Owner]  NOT LIKE 'ADVANCEREP' AND [TableName] NOT LIKE 'UCD_1295_RANDOM')
			AND ([LinkedServerName]  NOT LIKE 'ISODS_PROD' AND [Owner]  NOT LIKE 'PERSON' AND [TableName] NOT LIKE 'STUDENT_DEGREE_V')
			AND [Owner] NOT LIKE 'APEX_030200'
			AND [Owner] NOT LIKE 'ORDDATA'
			AND NumRows IS NULL

			IF OBJECT_ID('tempdb..#CDW_ROW_COUNTS') IS NULL
			CREATE TABLE #CDW_ROW_COUNTS (LinkedServerName varchar(500), [Owner] varchar(500), TableName varchar(500), NumRows int)

			DECLARE @LinkedServerName varchar(500),  @Owner varchar(500), @TableName varchar(500)
			DECLARE @TSQL varchar(MAX) = ''

			OPEN mycursor
			FETCH NEXT FROM mycursor INTO @LinkedServerName, @Owner, @TableName
			WHILE @@FETCH_STATUS <> -1
				BEGIN
					SELECT @TSQL = '	INSERT INTO #CDW_ROW_COUNTS
	SELECT ' + QUOTENAME(@LinkedServerName, '''') + ' AS LinkedServerName, ' + QUOTENAME(@Owner, '''') + ' AS Owner, ' + QUOTENAME(@TableName, '''') + ' AS TableName, NumRows 
	FROM OPENQUERY(' + @LinkedServerName + ', ''SELECT COUNT(*) NumRows FROM ' + @Owner + '.' + @TableName + ''')'

					IF @IsDebug = 1
						PRINT @TSQL
					ELSE
						EXEC (@TSQL) 

					FETCH NEXT FROM mycursor INTO @LinkedServerName, @Owner, @TableName
				END

			CLOSE mycursor
			DEALLOCATE mycursor

			SELECT * FROM #CDW_ROW_COUNTS

			UPDATE [dbo].[TableInfo]
			SET [dbo].[TableInfo].NumRows = t2.NumRows
			FROM #CDW_ROW_COUNTS t2
			INNER JOIN [dbo].[TableInfo] t1
			ON t2.LinkedServerName = t1.LinkedServerName AND t2.[Owner] = t1.[Owner] AND t2.TableName = t1.TableName
			WHERE  t1.NumRows IS NULL
		END

		IF OBJECT_ID('tempdb..#CDW_ROW_COUNTS') IS NOT NULL
			DROP TABLE #CDW_ROW_COUNTS
END
