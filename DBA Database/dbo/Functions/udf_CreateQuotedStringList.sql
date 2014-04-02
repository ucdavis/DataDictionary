-- =============================================
-- Author:		Ken Taylor
-- Create date: January 10, 2013
-- Description:	Builds and returns a NumSingleQuotes quoted list of quoted strings such as
--	'430200', '440201', '440205', '440210', '440211', '440219', '440221', '440222', ... or 
--	''430200'', ''440201'', ''440205'', ''440210'', ''440211'', ''440219'', ''440221'', ... or
--  ''''430200'''', ''''440201'''', ''''440205'''', ''''440210'''', ''''440211'''', ''''440219'''',  ..., etc
--	to be used within a SQL statement's WHERE clause's "IN" clause, i.e., "WHERE FieldName IN (<quoted strings list goes here>)".
-- Usage:
-- SELECT dbo.udf_CreatedQuotedStringList(1) -- Returns single quoted string, i.e. '430200', '440201', '440205', '440210', '440211', '440219', '440221', '440222', ...
-- SELECT dbo.udf_CreatedQuotedStringList(DEFAULT/2) --Returns a double single quoted string, i.e. ''430200'', ''440201'', ''440205'', ''440210'', ''440211'', ...
-- SELECT dbo.udf_CreatedQuotedStringList(4) --Returns a double, double single quoted string, i.e. ''''430200'''', ''''440201'''', ''''440205'''', ''''440210'''', ...
--	The final example is for use within an OPENQUERY TSQL String.
-- Modifications:
--	2013-08-07 by kjt: Changed var @temp length from varchar(20) to varchar(200).
--	2014-03-19 by kjt: Added logic to trim leading or trailing spaces from values. 
-- =============================================
CREATE FUNCTION [dbo].[udf_CreateQuotedStringList] 
(
	@NumSingleQuotes tinyint = 2, --Assume that the ARC codes list is not going to be used in an SQL statement executed directly from the query window,
								-- but used for creating an SQL statement that is executed from within a stored procedure or function by default. 
    @CommaDelimittedString varchar(MAX),
    @SplitChar char(1) = ','
)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @StringValueTable TABLE (String varchar(50))
	DECLARE @X xml
 
	SELECT @X = CONVERT(xml,'<root><s>' + REPLACE(@CommaDelimittedString,@SplitChar,'</s><s>') + '</s></root>')
	
	INSERT INTO @StringValueTable
	SELECT [Value] = T.c.value('.','varchar(200)')
	FROM @X.nodes('/root/s') T(c)
	
	
	-- Declare the return variable here
	DECLARE @QuotedStringsList varchar(MAX) = ''

	DECLARE @temp varchar(200) = '';
	DECLARE @SingleQuote varchar(4) = ''''; -- Use this as the text qualifier when creating an ARC codes list for use within
											--   an OPENQUERY/Pass-thru that is executed directly from a query window, as opposed to a TSQL string.

	DECLARE @DoubleSingleQuotes varchar(6) = ''''''; -- Use these as the text qualifiers when creating an ARC codes list for use within
													 --   an OPENQUERY/Pass-thru query INSIDE an SQL string that is to be executed, as in "EXEC(@TSQL)".

	DECLARE @TextQualifier varchar(10) = @SingleQuote
	DECLARE @QuoteCount smallint = 1 
	WHILE @QuoteCount < @NumSingleQuotes
	BEGIN
		SELECT @TextQualifier += @SingleQuote
		SELECT @QuoteCount = @QuoteCount + 1
	END
	

	DECLARE MyCursor CURSOR FOR SELECT String FROM @StringValueTable

	OPEN MyCursor

	FETCH NEXT FROM MyCursor INTO @temp
	-- Build the quoted strings list:
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @QuotedStringsList +=  @TextQualifier + RTRIM(LTRIM(@temp)) + @TextQualifier
		FETCH NEXT FROM MyCursor INTO @temp
    
    	IF @@FETCH_STATUS = 0
    		SELECT @QuotedStringsList += ', ' 
	END

	CLOSE MyCursor
	DEALLOCATE MyCursor

	RETURN @QuotedStringsList
END
