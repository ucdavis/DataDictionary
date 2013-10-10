
-- =============================================
-- Author:		Ken Taylor
-- Create date: September 9, 2012
-- Description:	Given aContainsSearchCondition search string, 
--				return the records matching the search string.
--
-- Notes: This is an example of a Multi-statement Table-valued function.   
-- This syntax behaves nicely within VS2010 database projects.  However, it requires 
-- nearly twice the number of SQL statements when compared to a similar Inline Table-valued
-- function designed for the identical purpose, plus explicit declaration of the table
-- variable beforehand.
-- Use DEFAULT as substitute for @LinkedServerNames to search all linked server for matching criteria; otherwise, specify
--     which servers to filter results by providing a non-spaced, comma-delimited string.
--
-- Usage:
/*
-- Search ALL LinkedServer for matching expression:
 USE [DBA]
 GO
  
 DECLARE @ContainsSearchCondition varchar(255) = 'course'; -- Searches on either TableName, ColumnName, Comments or ColumnComments.
 SELECT * from udf_GetTableColumnCommentsResults(@ContainsSearchCondition, DEFAULT)

 -- OR to search a particular LinkedServer: --
 USE [DBA]
 GO
  
 DECLARE @ContainsSearchCondition varchar(255) = 'course'; -- Searches on either TableName, ColumnName, Comments or ColumnComments.
 SELECT * from udf_GetTableColumnCommentsResults(@ContainsSearchCondition, 'ISODS_PROD')

  -- OR to search multiple LinkedServers: --
 USE [DBA]
 GO
  
 DECLARE @ContainsSearchCondition varchar(255) = 'course'; -- Searches on either TableName, ColumnName, Comments or ColumnComments.
 SELECT * from udf_GetTableColumnCommentsResults(@ContainsSearchCondition, 'ISODS_PROD,SIS')
*/
-- 
-- results:

--
-- Modifications:
--	2013-09-11 by kjt: Added LinkedServerNames parameter, and modified logic accordingly.
--	2013-09-30 by kjt: Added SearchTables, SearchColumns, SearchComments to search only for matches in 
--		corresponding selections, and modified logic accordingly.
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTableColumnCommentsResults] 
(	
	@ContainsSearchCondition varchar(255), --A string containing the word or words to search on.
	@LinkedServerNames varchar(MAX) = '', --A non-spaced, comma-delimited list of linked servers to search within.
	@SearchTables bit = 1, --Set this to one if you want to search for a matching table
	@SearchColumns bit = 1, --Set this to one if you want to search for a matching column
	@SearchComments bit = 1 --Set this to one if you want to search for matching comments.
	-- Note: Leaving them all de-selected is the same as selecting them all.
)
RETURNS @returntable TABLE 
(
	   [LinkedServerName] varchar(100) not null
      ,[Owner] varchar(200) not null
      ,[TableName] varchar(200) not null
      ,[Comments] nvarchar(4000) null
      ,[ColumnName] varchar(200) not null
      ,[ColumnComments] nvarchar(4000) null
	  ,[NumRows] int null
	  ,[TableType] nvarchar(20)
)
AS
BEGIN
	DECLARE @StringValueTable TABLE (String varchar(200))
	DECLARE @X xml
 
	SELECT @X = CONVERT(xml,'<root><s>' + REPLACE(@LinkedServerNames,',','</s><s>') + '</s></root>')
	
	INSERT INTO @StringValueTable
	SELECT [Value] = T.c.value('.','varchar(200)')
	FROM @X.nodes('/root/s') T(c)

	IF  (@SearchTables = 1 AND @SearchColumns = 1 AND @SearchComments = 1) OR
		(@SearchTables = 0 AND @SearchColumns = 0 AND @SearchComments = 0)
	BEGIN
		IF EXISTS (SELECT 1 FROM @StringValueTable WHERE String IS NOT NULL AND LEN(String) > 0) 
			BEGIN
				INSERT INTO @returntable
				SELECT TOP 100 PERCENT  
				   [LinkedServerName]
				  ,[Owner]
				  ,[TableName]
				  ,[Comments]
				  ,[ColumnName]
				  ,[ColumnComments]
				  ,[NumRows]
				  ,[TableType]
				FROM [dbo].[ServerOwnerTableColumn] SEARCH_TBL
				INNER JOIN FREETEXTTABLE(ServerOwnerTableColumn, ([TableName], [ColumnName], [Comments], [ColumnComments]), @ContainsSearchCondition) KEY_TBL on SEARCH_TBL.Id = KEY_TBL.[KEY]
				WHERE LinkedServerName IN (SELECT * FROM @StringValueTable)
				ORDER BY KEY_TBL.[RANK] DESC
			END
		ELSE 
			BEGIN
				INSERT INTO @returntable
				SELECT TOP 100 PERCENT  
				   [LinkedServerName]
				  ,[Owner]
				  ,[TableName]
				  ,[Comments]
				  ,[ColumnName]
				  ,[ColumnComments]
				  ,[NumRows]
				  ,[TableType]
				FROM [dbo].[ServerOwnerTableColumn] SEARCH_TBL
				INNER JOIN FREETEXTTABLE(ServerOwnerTableColumn, ([TableName], [ColumnName], [Comments], [ColumnComments]), @ContainsSearchCondition) KEY_TBL on SEARCH_TBL.Id = KEY_TBL.[KEY]
				ORDER BY KEY_TBL.[RANK] DESC
			END
	END
	ELSE
	BEGIN
		IF @SearchTables = 1
				INSERT INTO @returntable ( 
					 [LinkedServerName]
					,[Owner]
					,[TableName]
					,[Comments]
					,[ColumnName]
					,[ColumnComments]
					,[NumRows]
					,[TableType])
				SELECT DISTINCT TOP 100 PERCENT
					 [LinkedServerName]
					,[Owner]
					,[TableName]
					,[Comments]
					,'' AS [ColumnName]
					,'' AS [ColumnComments]
					,[NumRows]
					,[TableType]
				FROM [dbo].[ServerOwnerTableColumn] SEARCH_TBL
				INNER JOIN FREETEXTTABLE(ServerOwnerTableColumn, ([TableName]), @ContainsSearchCondition) KEY_TBL on SEARCH_TBL.Id = KEY_TBL.[KEY]
				ORDER BY 
					 [LinkedServerName]
					,[Owner]
					,[TableName]
					,[Comments]
					,[ColumnName]
					,[ColumnComments]
					,[NumRows]
					,[TableType]
		IF @SearchColumns = 1
				INSERT INTO @returntable
				SELECT TOP 100 PERCENT  
					[LinkedServerName]
					,[Owner]
					,[TableName]
					,[Comments]
					,[ColumnName]
					,[ColumnComments]
					,[NumRows]
					,[TableType]
				FROM [dbo].[ServerOwnerTableColumn] SEARCH_TBL
				INNER JOIN FREETEXTTABLE(ServerOwnerTableColumn, ([ColumnName]), @ContainsSearchCondition) KEY_TBL on SEARCH_TBL.Id = KEY_TBL.[KEY]
				ORDER BY KEY_TBL.[RANK] DESC
		IF @SearchComments = 1
				INSERT INTO @returntable
				SELECT TOP 100 PERCENT  
					[LinkedServerName]
					,[Owner]
					,[TableName]
					,[Comments]
					,[ColumnName]
					,[ColumnComments]
					,[NumRows]
					,[TableType]
				FROM [dbo].[ServerOwnerTableColumn] SEARCH_TBL
				INNER JOIN FREETEXTTABLE(ServerOwnerTableColumn, ([Comments], [ColumnComments]), @ContainsSearchCondition) KEY_TBL on SEARCH_TBL.Id = KEY_TBL.[KEY]
				ORDER BY KEY_TBL.[RANK] DESC
	END
	RETURN
END