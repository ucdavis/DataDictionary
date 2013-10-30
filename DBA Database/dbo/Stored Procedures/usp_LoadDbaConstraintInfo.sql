-- =============================================
-- Author:		Ken Taylor
-- Create date: September 19, 2013
-- Description:	Populate the [dbo].[ConstraintInfo] table for all linked servers from the campus data warehouse.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC [dbo].[usp_LoadDbaConstraintInfo] @IsDebug = 1

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaConstraintInfo] 
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
	IF @IsDebug = 0 TRUNCATE TABLE [dbo].[ConstraintInfo]
	ELSE Print '	TRUNCATE TABLE [dbo].[ConstraintInfo]
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
	EXEC usp_GetOracleLinkedServerNames

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
	INSERT INTO [dbo].[ConstraintInfo]
	SELECT ''' + @LinkedServerName + ''' AS LinkedServerName, 
		CONSTRAINT_NAME AS ConstraintName,
		OWNER AS Owner,
		TABLE_NAME AS TableName,
		COLUMN_NAME AS ColumnName,
		POSITION AS ColumnPosition,
		STATUS AS Status,
		CONSTRAINT_TYPE AS ConstraintType
	FROM OPENQUERY(' + @LinkedServerName + ', ''
		SELECT cons.CONSTRAINT_NAME,cons.owner, cols.table_name, cols.column_name, cols.position, cons.STATUS, cons.CONSTRAINT_TYPE 
		FROM all_constraints cons
		INNER JOIN all_cons_columns cols ON cons.constraint_name = cols.constraint_name AND cons.owner = cols.owner and cons.TABLE_NAME = cols.TABLE_NAME
		ORDER BY cons.CONSTRAINT_NAME, cons.Owner, cols.table_name, cols.position'')'
		IF @IsDebug = 1
			PRINT @TSQL
		ELSE
			EXEC(@TSQL)

		FETCH NEXT FROM MyCursor INTO @LinkedServerName
	END
	CLOSE MyCursor
	DEALLOCATE MyCursor

END
