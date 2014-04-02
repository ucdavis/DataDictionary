-- =============================================
-- Author:		Ken Taylor
-- Create date: August 2, 2013
-- Description:	Return List of Constraint columns for the table name(s) provided.
-- Notes:   Default OWNER is SATURN.  Must supply '' or NULL for OWNER, i.e. @Owner = '' or @Owner = NULL
--	if you want constraints for ALL database owners returned.
--			Default TABLENAMES is '', which will return constraints for ALL tables in the database for
--	the Owner(s) specified.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetLinkedServerConstraintColumnNames]
		@TableNames = N'SHRTGRD',
		@Owners = N'SATURN',
		@LinkedServerNames = N'SIS',
		@IncludeBannerItems = 1,
		@IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/ 
-- Sample Results:
/*
ConstraintName	Owner	TableName	ColumnName	ColumnPosition	Status	ConstraintType
FK1_SHRTGRD_INV_STVGMOD_CODE	SATURN	SHRTGRD	SHRTGRD_GMOD_CODE	1	ENABLED	R
FK1_SHRTGRD_INV_STVSBGI_CODE	SATURN	SHRTGRD	SHRTGRD_SBGI_CODE	1	DISABLED	R
FK1_SHRTGRD_INV_STVTERM_CODE	SATURN	SHRTGRD	SHRTGRD_TERM_CODE_EFFECTIVE	1	ENABLED	R
FK2_SHRTGRD_INV_STVTERM_CODE	SATURN	SHRTGRD	SHRTGRD_TERM_CODE_EXPIRED	1	ENABLED	R
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_SBGI_CODE	1	ENABLED	P
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_CODE	2	ENABLED	P
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_LEVL_CODE	3	ENABLED	P
PK_SHRTGRD	SATURN	SHRTGRD	SHRTGRD_TERM_CODE_EFFECTIVE	4	ENABLED	P
SYS_C009231	SATURN	SHRTGRD	SHRTGRD_SBGI_CODE	NULL	ENABLED	C
SYS_C009232	SATURN	SHRTGRD	SHRTGRD_CODE	NULL	ENABLED	C
SYS_C009233	SATURN	SHRTGRD	SHRTGRD_LEVL_CODE	NULL	ENABLED	C
SYS_C009234	SATURN	SHRTGRD	SHRTGRD_ABBREV	NULL	ENABLED	C
SYS_C009235	SATURN	SHRTGRD	SHRTGRD_TERM_CODE_EFFECTIVE	NULL	ENABLED	C
SYS_C009236	SATURN	SHRTGRD	SHRTGRD_QUALITY_POINTS	NULL	ENABLED	C
SYS_C009237	SATURN	SHRTGRD	SHRTGRD_ATTEMPTED_IND	NULL	ENABLED	C
SYS_C009238	SATURN	SHRTGRD	SHRTGRD_COMPLETED_IND	NULL	ENABLED	C
SYS_C009239	SATURN	SHRTGRD	SHRTGRD_PASSED_IND	NULL	ENABLED	C
SYS_C009240	SATURN	SHRTGRD	SHRTGRD_GPA_IND	NULL	ENABLED	C
SYS_C009241	SATURN	SHRTGRD	SHRTGRD_GRDE_STATUS_IND	NULL	ENABLED	C
SYS_C009242	SATURN	SHRTGRD	SHRTGRD_ACTIVITY_DATE	NULL	ENABLED	C
*/
-- Modifications:
-- 2013-08-14 by kjt: Revised to use DBA database's ConstraintInfo table.
-- 2014-04-01 by kjt: Added param @IncludeBannerItems to filter out data with whose LinkedServerNames begin with 'SIS'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLinkedServerConstraintColumnNames] 
	-- Add the parameters for the stored procedure here
	@TableNames varchar(MAX) = '', --A non-spaced, comma-delimited list of table names, i.e.,'SHRTGRD' or 'SHRTGRD,SARADAP', etc. 
	@Owners varchar(MAX) = 'SATURN', --A non-spaced, comma-delimited list of owners (schema(s), i.e.,'SHRTGRD' or 'SHRTGRD,SARADAP', etc. 
	-- Note: Must supply NULL or '' for @Owner if you desire constraints for ALL database owners returned.
	@LinkedServerNames varchar(MAX) = 'SIS', --A non-spaced, comma-delimited list of linked server names i.e.,'SIS' or 'SIS,SIS_DEV', etc. 
	@IncludeBannerItems bit = 0, --Set to 1 to include Banner info.
	@IsDebug bit = 0 --Set to 1 to only print SQL generated; 0 otherwise to run sproc.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NumQuotes int = 1;

    DECLARE @TSQL varchar(MAX) = 'SELECT 
	ConstraintName AS ConstraintName,
	LinkedServerName, 
	OWNER AS Owner,
	TableName AS TableName,
	ColumnName AS ColumnName,
	ColumnPosition AS ColumnPosition,
	STATUS AS Status,
	ConstraintType AS ConstraintType
FROM ConstraintInfo'

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
ORDER BY ConstraintName, LinkedServerName, Owner, TableName, ColumnPosition' 

	IF @IsDebug = 1
		PRINT @TSQL
	ELSE 
		EXEC (@TSQL)
END

