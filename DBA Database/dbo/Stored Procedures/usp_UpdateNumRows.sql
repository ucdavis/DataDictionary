-- =============================================
-- Author:		Ken Taylor
-- Create date: September 30, 2013
-- Description: Update TableInfo and ServerOwnerTableColumn NumRows columns.  This is used
--	ad-hoc when the script did not populate the NumRows automatically.
-- Usage:
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_UpdateNumRows] 
		@Owner = 'BANINST1', --Name of database owner, i.e. 'BANINST1', etc.
		@TableName = 'AR_FINAID_ENROLLMENT', --Name of table, i.e. 'AR_FINAID_ENROLLMENT',etc
		@LinkedServerName = N'SIS',--Oracle linked server name, i.e. 'SIS', etc.
		@IsDebug = 0 --Set to 1 to print SQL only.

SELECT	'Return Value' = @return_value

GO
*/
-- Modifications:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateNumRows]
	@LinkedServerName varchar(200) ='SIS_DEV', 
	@Owner varchar(200) = 'BANINST1', 
	@TableName varchar(500) ='AR_FINAID_ENROLLMENT',
    @IsDebug bit = 0
AS
BEGIN

/*
DECLARE @IsDebug bit = 0
DECLARE @LinkedServerName varchar(200) ='SIS_DEV', @Owner varchar(200) = 'BANINST1', @TableName varchar(500) ='AR_FINAID_ENROLLMENT'
*/

DECLARE @TSQL varchar(MAX) = ''

SELECT @TSQL = '
update tableinfo set numrows = (select * from openquery(' + @LinkedServerName + ', ''select count(*) from ' + @Owner + '.' + @TableName +'''))
where tablename = ''' + @TableName + ''' and [owner] = ''' + @Owner + ''' and LinkedServerName = ''' + @LinkedServerName + ''''

IF @IsDebug = 1
	PRINT @TSQL
ELSE 
	EXEC (@TSQL)

SELECT @TSQL = '
update [dbo].[ServerOwnerTableColumn]
set numrows = t1.numrows
from  [dbo].[ServerOwnerTableColumn] t2
INNER JOIN tableinfo t1 ON t2.tablename = t1.tablename and t2.[owner] = t1.[owner] AND t2.linkedservername = t1.linkedservername
where t2.tablename = ''' + @TableName + ''' and t2.[owner] = ''' + @Owner + ''' AND t2.LinkedServerName = ''' + @LinkedServerName + ''''

IF @IsDebug = 1
	PRINT @TSQL
ELSE 
	EXEC (@TSQL)
END
