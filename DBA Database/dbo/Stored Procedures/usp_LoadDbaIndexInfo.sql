-- =============================================
-- Author:		Ken Taylor
-- Create date: September 18, 2013
-- Description:	Populate the [DBA].[dbo].[IndexInfo] table for all linked servers from the campus data warehouse..
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC [dbo].[usp_LoadDbaIndexInfo] @IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaIndexInfo] 
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
	IF @IsDebug = 0 TRUNCATE TABLE [dbo].[IndexInfo]
	ELSE Print '	TRUNCATE TABLE [dbo].[IndexInfo]
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
		SELECT @TSQL = '
	INSERT INTO [dbo].[IndexInfo] 
	SELECT ''' + @LinkedServerName + ''' AS LinkedServerName,
		AI_INDEX_NAME AS IndexName,
		AI_OWNER AS Owner, 
		AI_TABLE_NAME AS TableName,
		COLUMN_NAME AS ColumnName,
		COLUMN_POSITION AS ColumnPosition,
		DESCEND AS SortOrder,
		UNIQUENESS AS Uniqueness,
		DISTINCT_KEYS DistinctKeys
	FROM OPENQUERY(' + @LinkedServerName  + ', ''SELECT 
		AI.index_name AI_INDEX_NAME, 
		AI.OWNER AI_OWNER, 
		AI.TABLE_NAME AI_TABLE_NAME, 
		AIC.COLUMN_NAME, 
		AIC.COLUMN_POSITION, 
		AIC.DESCEND, 
		AI.UNIQUENESS, 
		AI.DISTINCT_KEYS
	  FROM all_indexes AI
	  INNER JOIN  all_ind_columns AIC ON AI.OWNER = AIC.INDEX_OWNER AND AI.INDEX_NAME = AIC.INDEX_NAME AND AI.TABLE_NAME = AIC.TABLE_NAME AND AI.TABLE_OWNER = AIC.TABLE_OWNER
	  ORDER BY AI_INDEX_NAME, AI_OWNER, AI_TABLE_NAME, COLUMN_POSITION'')
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
