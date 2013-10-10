-- =============================================
-- Author:		Ken Taylor
-- Create date: August 6, 2013
-- Description:	Return a list of all Oracle Linked Database Servers
-- Usage
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetOracleLinkedServerNames]

SELECT	'Return Value' = @return_value

GO
*/
-- Sample Results:
/*
SRV_NAME
FIS_DS
FIS_DS_PROD
ISODS_PROD
MOTHRA_PROD
MOTHRA_TEST
MOTHTEST
PAY_PERS_EXTR
SIS
SIS_DEV
*/
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetOracleLinkedServerNames] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @OracleLinkedServers TABLE (
		SRV_NAME varchar(100), 
		SRV_PROVIDERNAME varchar(200), 
		SRV_PRODUCT varchar(100), 
		SRV_DATASOURCE varchar(500),
		SRV_PROVIDERSTRING varchar(500),
		SRV_LOCATION varchar(200),
		SRV_CAT varchar(100)
	)

	INSERT INTO @OracleLinkedServers
	EXEC sp_linkedservers

	SELECT SRV_NAME Name 
	FROM @OracleLinkedServers
	WHERE SRV_PROVIDERNAME = 'OraOLEDB.Oracle'

	/*
	FIS_DS
	FIS_DS_PROD
	ISODS_PROD
	MOTHRA_PROD
	MOTHRA_TEST
	MOTHTEST
	PAY_PERS_EXTR
	SIS
	SIS_DEV
	*/
END
