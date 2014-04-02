-- =============================================
-- Author:		Ken Taylor
-- Create date: August 6, 2013
-- Description:	Return a list of all Oracle Linked Database Servers
-- Usage
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[usp_GetOracleLinkedServers]

SELECT	'Return Value' = @return_value

GO
*/
-- Sample Results:
/*
SRV_NAME	SRV_PROVIDERNAME	SRV_PRODUCT	SRV_DATASOURCE	SRV_PROVIDERSTRING	SRV_LOCATION	SRV_CAT
CLAMPS	SQLNCLI		CLAMPS	NULL	NULL	NULL
DONBOT	SQLNCLI	SQL Server	DONBOT	NULL	NULL	NULL
FIS_DS	OraOLEDB.Oracle	Oracle	FIS_DS	ChunkSize=65535	NULL	NULL
ICMSP	OraOLEDB.Oracle	Oracle	(DESCRIPTION=
(ADDRESS=(PROTOCOL=TCP)(HOST=regoracle.ucdavis.edu)(PORT=1521))
(CONNECT_DATA=(SID=ICMSP))
)	ChunkSize=65535	NULL	NULL
ISODS_PROD	OraOLEDB.Oracle	Oracle	ISODS_PROD	ChunkSize=65535	NULL	NULL
MOTHRA_PROD	OraOLEDB.Oracle	Oracle	MOTHRA	ChunkSize=65535	NULL	NULL
PAY_PERS_EXTR	OraOLEDB.Oracle	Oracle	PAY_PERS_EXTR	ChunkSize=65535	NULL	NULL
*/
-- Modifications:
--	2013-10-30 by kjt:  Added filtering to remove SIS servers from list.
--  2014-04-01 by kjt: Added param @IncludeBannerItems to include Banner items if desired.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetOracleLinkedServers] 
	-- Add the parameters for the stored procedure here
	@IncludeBannerItems bit = 0 --Set to 1 to include Banner info.
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

	IF @IncludeBannerItems = 0
		SELECT * FROM @OracleLinkedServers WHERE SRV_NAME NOT LIKE 'SIS%'
	ELSE 
		SELECT * FROM @OracleLinkedServers
END