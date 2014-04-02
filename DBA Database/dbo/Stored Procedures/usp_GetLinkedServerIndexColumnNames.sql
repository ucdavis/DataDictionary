-- =============================================
-- Author:		Ken Taylor
-- Create date: August 6, 2013
-- Description:	Return List of Index columns for the table name(s) provided.
-- Notes:   Default OWNER is SATURN.  Must supply '' or NULL for OWNER, i.e. @Owner = '' or @Owner = NULL
--	if you want indexes for ALL database owners returned.
--			Default TABLENAMES is '', which will return indexes for ALL tables in the database for
--	the Owner(s) specified.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetLinkedServerIndexColumnNames]
		@TableNames = '',
		@Owners = '',
		@LinkedServerNames = '',
		@IncludeBannerItems = 0,
		@IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/ 
-- Sample Results:
/*
IndexName	Owner	TableName	ColumnName	ColumnPosition	SortOrder	Uniqueness	DistinctKeys
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_SBGI_CODE	1	ASC	UNIQUE	1438
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_CODE	2	ASC	UNIQUE	1438
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_LEVL_CODE	3	ASC	UNIQUE	1438
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_TERM_CODE_EFFECTIVE	4	ASC	UNIQUE	1438	1438
*/

-- Modifications:
-- 2013-08-14 by kjt: Revised to use DBA database's IndexInfo table.
-- 2014-04-01 by kjt: Added param @IncludeBannerItems to filter banner items.
-- =============================================
create PROCEDURE [dbo].[usp_GetLinkedServerIndexColumnNames] 
	-- Add the parameters for the stored procedure here
	@TableNames varchar(200) = '', --A non-spaced, comma-delimited list of table names, i.e.,'SHRTGRD' or 'SHRTGRD,SARADAP', etc. 
	@Owners varchar(100) = 'SATURN', --A non-spaced, comma-delimited list of owners (schema(s), i.e.,'SHRTGRD' or 'SHRTGRD,SARADAP', etc. 
	-- Note: Must supply NULL or '' for @Owner if you desire indexes for ALL database owners returned.
	@LinkedServerNames varchar(MAX) = 'SIS', --A non-spaced, comma-delimited list of linked server names i.e.,'SIS' or 'SIS,SIS_DEV', etc. 
	@IncludeBannerItems bit = 0, --Set to 1 to return information pertaining to Banner.
	@IsDebug bit = 0 --Set to 1 to only print SQL generated; 0 otherwise to run sproc.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NumQuotes int = 1;

    DECLARE @TSQL varchar(MAX) = 'SELECT IndexName,
	LinkedServerName,
	Owner, 
	TableName,
	ColumnName,
	ColumnPosition,
	SortOrder,
	Uniqueness,
	DistinctKeys
FROM IndexInfo'

DECLARE @WhereClause varchar(MAX) = '';

	IF (@LinkedServerNames IS NOT NULL AND @LinkedServerNames NOT LIKE '')
		SELECT @WhereClause = 'LinkedServerName IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @LinkedServerNames, DEFAULT)  + ')'

	IF @Owners IS NOT NULL AND @Owners NOT LIKE ''
	BEGIN
		IF (@WhereClause IS NOT NULL AND @WhereClause NOT LIKE '')
			SELECT @WhereClause += ' AND '

		SELECT @WhereClause += 'OWNER IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @Owners, DEFAULT) + ')'
	END

	IF @TableNames IS NOT NULL AND @TableNames NOT LIKE ''
		BEGIN
			IF (@WhereClause IS NOT NULL AND @WhereClause NOT LIKE '')
				SELECT @WhereClause += ' AND '

			SELECT @WhereClause += 'TableName IN (' +  dbo.udf_CreateQuotedStringList(@NumQuotes , @TableNames, DEFAULT) +')'
		END

	IF @IncludeBannerItems = 0
		BEGIN
			IF (@WhereClause IS NOT NULL AND @WhereClause NOT LIKE '')
				SELECT @WhereClause += ' AND '

			SELECT @WhereClause += 'LinkedServerName NOT LIKE ''SIS%'''
		END

	IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
		SELECT @TSQL += '
WHERE ' + @WhereClause;

	SELECT @TSQL += '
ORDER BY IndexName, LinkedServerName, Owner, TableName, ColumnName' 

	IF @IsDebug = 1
		PRINT @TSQL
	ELSE 
		EXEC (@TSQL)
	END
