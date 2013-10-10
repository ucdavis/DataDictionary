-- =============================================
-- Author:		Ken Taylor
-- Create date: August 8, 2013
-- Description:	Return a list of Oracle database owners, i.e. schemas, and the number of their associated tables for the parameters provided.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetLinkedServerDatabaseOwnersAndTableCount]
		@LinkedServerNames = N'SIS', --The name of the linked Oracle database server.
		@IncludeEmptyTables = 1, --Set to 1 to return information for tables wth no data rows.
		@IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--	2013-08-15 by kjt: Modified to use local DBA database, and accept multiple LinkedServerNames
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLinkedServerDatabaseOwnersAndTableCount] 
	@LinkedServerNames varchar(MAX) = N'SIS', --The name of the linked Oracle database server.
	@IncludeEmptyTables bit = 1, --Set to 1 to return information for tables wth no data rows.
	@IsDebug bit = 0 --Set to 1 to print SQL only.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	--For Debugging
	DECLARE @IsDebug bit = 0, --Set to 1 to print SQL only.
	@LinkedServerNames varchar(100) = N'SIS', --The name of the linked Oracle database server.
	@IncludeEmptyTables bit = 0, --Set to 1 to return information for tables wth no data rows.
	
	*/

DECLARE @NumSingleQuotes tinyint = 1
DECLARE @WhereClause varchar(MAX) = ''

DECLARE @TSQL varchar(MAX) = 'SELECT 
	t1.LinkedServerName,
	t1.[Owner],
	'
IF @IncludeEmptyTables = 1
	SELECT @TSQL += 't1.NumTablesAll AS NumTables'
ELSE
	SELECT @TSQL += 't1.NumTables'

SELECT @TSQL += '
FROM OwnerInfo t1'

IF @LinkedServerNames IS NOT NULL AND @LinkedServerNames NOT LIKE ''
	SELECT @WhereClause = '
WHERE LinkedServerName IN (' + dbo.udf_CreateQuotedStringList(@NumSingleQuotes, @LinkedServerNames, DEFAULT) + ')'

IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
	SELECT @TSQL += @WhereClause

	SELECT @TSQL += '
GROUP BY t1.LinkedServerName, t1.Owner, NumTables, NumTablesAll
ORDER BY  t1.LinkedServerName, NumTables desc, t1.Owner'

	IF @ISDebug = 1
		PRINT @TSQL
	ELSE
		EXEC (@TSQL)
END

