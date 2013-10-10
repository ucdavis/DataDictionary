-- =============================================
-- Author:		Ken Taylor
-- Create date: September 19, 2013
-- Description:	Populate the [dbo].[OwnerInfo] table for all linked servers from the campus data warehouse.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC [dbo].[usp_LoadDbaOwnerInfo] @IsDebug = 1

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
--
-- =============================================
CREATE PROCEDURE [dbo].[usp_LoadDbaOwnerInfo] 
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
	IF @IsDebug = 0 TRUNCATE TABLE [dbo].[OwnerInfo]
	ELSE Print '	TRUNCATE TABLE [dbo].[OwnerInfo]
'
	DECLARE @TSQL varchar(MAX) = ''
	SELECT @TSQL = '
	INSERT INTO dbo.OwnerInfo (Linkedservername, [owner], NumTables, NumTablesAll)
	Select Linkedservername, owner, 0 AS NumTables, count(*) AS NumTablesAll
	FROM dbo.TableInfo 
	--WHERE numrows is null OR NumRows > 0
	group by Linkedservername, owner'

	IF @IsDebug = 1 PRINT @TSQL
	ELSE EXEC(@TSQL)  

	DECLARE myCursor CURSOR FOR 
	Select 
	Linkedservername, owner, count(*) NumTables
	FROM dbo.TableInfo 
	WHERE numrows is null OR NumRows > 0
	group by Linkedservername, owner

	DECLARE @LinkedServerName varchar(100), @Owner varchar(200), @NumTables int
	OPEN MyCursor
	FETCH NEXT FROM myCursor  INTO  @LinkedServerName, @Owner, @NumTables
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		SELECT @TSQL = '
	UPDATE dbo.OwnerInfo 
	SET NumTables = ' + CONVERT(varchar(20), @NumTables) + ' WHERE LinkedServerName = ''' + @LinkedServerName + ''' AND [Owner] = ''' + @Owner + '''
'

		IF @IsDebug = 1
			PRINT @TSQL
		ELSE
			EXEC(@TSQL)

		FETCH NEXT FROM myCursor INTO @LinkedServerName, @Owner, @NumTables
	END
	CLOSE MyCursor
	DEALLOCATE MyCursor

END
