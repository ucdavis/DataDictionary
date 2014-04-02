-- =============================================
-- Author:		Ken Taylor
-- Create date: August 6, 2013
-- Description:	Return a list of column names, comments and data types for the parameters given.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetLinkedServerColumnNamesCommentsAndDataTypes] 
		@Owners = 'SATURN', --Use a non-spaced comma delimited list, i.e. 'SATURN,SYS', etc.
		@TableNames = '', --Or an non-spaced comma delimited list of tables, i.e. 'SABAUDF,SABNSTU',etc
		@LinkedServerNames = N'SIS',--Use a non-spaced comma delimited list of linked Oracle server names, i.e. 'SIS,FIS_DS', etc.
		@IncludeBannerItems bit = 0, --Set to 1 to include Banner info.
		@IsDebug = 0 --Set to 1 to print SQL only.

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--	2013-08-14 by kjt: Renamed and revised for use with DBA database's TableInfo table, plus also handle
--	multiple linked servers.
--	2014-04-01 by kjt: Added param @IncludeBannerItems to filter out data with whose LinkedServerNames begin with 'SIS'
-- =============================================
create PROCEDURE [dbo].[usp_GetLinkedServerColumnNamesCommentsAndDataTypes] 
	-- Add the parameters for the stored procedure here
	@Owners varchar(MAX) = 'SATURN', --Use a non-spaced comma delimited list, i.e. 'SATURN,SYS', etc.
	@TableNames varchar(MAX) = '', --Or an non-spaced comma delimited list of tables, i.e. 'SABAUDF,SABNSTU',etc
	@LinkedServerNames varchar(MAX) = 'SIS', --Use a non-spaced comma delimited list of linked Oracle server names, i.e. 'SIS,FIS_DS', etc.
	@IncludeBannerItems bit = 0, --Set to 1 to include Banner info.
	@IsDebug bit = 0 --Set to 1 to print SQL only.

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NumQuotes int = 1
	DECLARE @WhereClause varchar(MAX) = ''


	IF @LinkedServerNames IS NOT NULL AND @LinkedServerNames NOT LIKE ''
		SELECT @WhereClause = 'LinkedServerName IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @LinkedServerNames, DEFAULT) + ')'
	
	IF @TableNames IS NOT NULL AND @TableNames NOT LIKE ''
		BEGIN
			IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
				SELECT @WhereClause += ' AND '

			SELECT @WhereClause += 'TableName IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @TableNames, DEFAULT) + ')'
		END

	IF @Owners IS NOT NULL AND @Owners NOT LIKE ''
		BEGIN
			IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
				SELECT @WhereClause += ' AND '
			SELECT @WhereClause += 'OWNER IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @Owners, DEFAULT) + ')'
		END

	IF @IncludeBannerItems = 0
		BEGIN
			IF (@WhereClause IS NOT NULL AND @WhereClause NOT LIKE '')
				SELECT @WhereClause += ' AND '

			SELECT @WhereClause += 'LinkedServerName NOT LIKE ''SIS%'''
		END

	DECLARE @TSQL varchar(MAX) = 'SELECT LinkedServerName, Owner, TableName, ColumnName, ColumnComments, DataType, DataLength, DataPrecision, DataScale, Nullable, ColumnID
FROM ColumnInfo'

	IF @WhereClause != ''
		SELECT @TSQL += '
WHERE ' + @WhereClause

	SELECT @TSQL += '
ORDER BY OWNER, TableName, ColumnID'

	IF @IsDebug = 1
		PRINT @TSQL
	ELSE
		EXEC (@TSQL)
END
