-- =============================================
-- Author:		Ken Taylor
-- Create date: April 2nd, 2014
-- Description:	Merge the list of appproved Banner access users into a local table for quicker application access.
-- Usage:
/*
USE [DBA]
GO

SET NOCOUNT ON;

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_LoadDbaBannerLoginIds]
		@IsDebug = 1

SELECT	'Return Value' = @return_value

SET NOCOUNT OFF;

GO
*/
-- Modifications:
--
-- =============================================
CREATE PROCEDURE usp_LoadDbaBannerLoginIds 
	-- Add the parameters for the stored procedure here
	@IsDebug bit = 0 --Set to 1 to print generated SQL only.
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TSQL varchar(MAX) = ''

    -- Insert statements for procedure here
	SELECT @TSQL = '
MERGE [dbo].[BannerLoginIds] AS t1
using (
	SELECT Login_ID AS LoginId FROM OPENQUERY(SIS, ''SELECT WOVDDAL_LOGIN_ID LOGIN_ID FROM WOVDDAL'')
) t2 ON  t1.LoginId = t2.LoginId
WHEN NOT MATCHED BY TARGET THEN INSERT VALUES (
LoginId);'

-------------------------------------------------

	IF @IsDebug = 1
		PRINT @TSQL
	ELSE
		EXEC(@TSQL)
END