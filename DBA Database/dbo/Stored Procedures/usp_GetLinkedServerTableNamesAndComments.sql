-- =============================================
-- Author:		Ken Taylor
-- Create date: July 24, 2013
-- Description:	Return a list of Oracle Linked Server table names, descriptions, row counts, and table type for the parameters provided.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetLinkedServerTableNamesAndComments]
		@Owners = 'SATURN', --Use a non-spaced comma delimited list, i.e. 'SATURN,SYS', etc.
		@TableNames = '', --Use a non-spaced comma delimited list, i.e. 'SABECRL,SABIDEN', etc.
		@IncludeEmptyTables = 0, --Set to 1 to return information for tables wth no data rows.
		@IncludeBannerItems = 0, --Set to 1 to return information pertaining to Banner.
		@LinkedServerNames = 'SIS', --Use a non-spaced comma delimited list, i.e. 'SIS,FIS_DS', etc.
		@IsDebug = 0

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--	2013-08-14 by kjt: Renamed and revised for use with DBA database's TableInfo table, plus also handle
--	multiple linked servers.
--	2013-10-07 by kjt: Added "Text" as returned column.
--  2014-04-01 by kjt: Added param @IncludeBannerItems to filter banner items.
-- =============================================
create PROCEDURE [dbo].[usp_GetLinkedServerTableNamesAndComments] 
	@Owners varchar(100) = 'SATURN', --Use a non-spaced comma delimited list, i.e. 'SATURN,SYS', etc.
	@TableNames varchar(MAX) = '', --Use a non-spaced comma delimited list, i.e. 'SABECRL,SABIDEN', etc.
	@IncludeEmptyTables bit = 0, --Set to 1 to return information for tables wth no data rows.
	@IncludeBannerItems bit = 0, --Set to 1 to return information pertaining to Banner.
	@LinkedServerNames varchar(100) = N'SIS',--Use a non-spaced comma delimited list, i.e. 'SIS,FIS_DS', etc.
	@IsDebug bit = 0 --Set to 1 to print SQL only.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	--For Debugging
	DECLARE @IsDebug bit = 0, --Set to 1 to print SQL only.
	@Owners varchar(MAX) = 'SATURN', --Use a non-spaced comma delimited list, i.e. 'SATURN,SYS', etc.
	@TableNames varchar(MAX) = '', --Use a non-spaced comma delimited list, i.e. 'SABECRL,SABIDEN', etc.
	@IncludeEmptyTables = 0, --Set to 1 to return information for tables wth no data rows.
	@IncludeBannerItems bit = 0,--Set to 1 to return information pertaining to Banner.
	@LinkedServerNames varchar(MAX) = N'SIS' --Use a non-spaced comma delimited list, i.e. 'SIS,FIS_DS', etc.
	*/

	DECLARE @NumQuotes int = 1
	DECLARE @WhereClause varchar(MAX) = ''

	IF @LinkedServerNames IS NOT NULL AND @LinkedServerNames NOT LIKE ''
		SELECT @WhereClause = 'LinkedServerName IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @LinkedServerNames, DEFAULT) + ')'

	IF @IncludeBannerItems = 0
		IF @LinkedServerNames IS NOT NULL AND @LinkedServerNames NOT LIKE ''
			SELECT @WhereClause += ' AND LinkedServerName NOT LIKE ''SIS%'''
		ELSE 
			SELECT @WhereClause = '
WHERE LinkedServerName NOT LIKE ''SIS%'''

	IF @TableNames IS NOT NULL AND @TableNames NOT LIKE ''
		BEGIN
			IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
				SELECT @WhereClause += ' AND '
			SELECT @WhereClause += 'TableName IN (' + (dbo.udf_CreateQuotedStringList(@NumQuotes, @TableNames, DEFAULT))  + ')'
		END

	IF @Owners IS NOT NULL AND @Owners NOT LIKE ''
		BEGIN
			IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
				SELECT @WhereClause += ' AND '
			SELECT @WhereClause += 'OWNER IN (' + dbo.udf_CreateQuotedStringList(@NumQuotes, @Owners, DEFAULT) + ')'
		END

	DECLARE @TSQL varchar(MAX) = '
	SELECT LinkedServerName, Owner, TableName, Comments, CONVERT(varchar(MAX),[Text]) [Text], NumRows, ISNULL(TableType, ''TABLE'') TableType 
	FROM TableInfo'

	IF @WhereClause IS NOT NULL AND @WhereClause NOT LIKE ''
		SELECT @TSQL += '
	WHERE ' + @WhereClause 

	IF (@TableNames IS NULL OR @TableNames LIKE '') AND @IncludeEmptyTables = 0
		SELECT @TSQL += '
	GROUP BY LinkedServerName, OWNER, TableName, COMMENTS, NumRows, TableType, CONVERT(varchar(MAX),[Text]) HAVING (NumRows > 0 OR NumRows IS NULL)'
	
	SELECT @TSQL += '
	ORDER BY 1, 2, 3'

	

	IF @ISDebug = 1
		PRINT @TSQL
	ELSE
		EXEC (@TSQL)
END

