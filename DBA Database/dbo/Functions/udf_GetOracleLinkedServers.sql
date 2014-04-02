-- =============================================
-- Author:		Ken Taylor
-- Create date: Octiber 31, 2013
-- Description:	Return a list of all Oracle Linked Database Servers
-- Usage
/*
USE [DBA]
GO

SELECT * FROM dbo.udf_GetOracleLinkedServers(1)

GO
*/
-- Modifications:
-- 2014-04-01 by kjt: Added param @IncludeBannerItems to include Banner items if desired.
-- =============================================
CREATE FUNCTION [dbo].[udf_GetOracleLinkedServers]
(
	-- Add the parameters for the function here
	@IncludeBannerItems bit = 0 --Set to 1 to include Banner info
)
RETURNS 
@OracleLinkedServers TABLE 
(
		SRV_NAME varchar(100), 
		SRV_PROVIDERNAME varchar(200), 
		SRV_PRODUCT varchar(100), 
		SRV_DATASOURCE varchar(500),
		SRV_PROVIDERSTRING varchar(500),
		SRV_LOCATION varchar(200),
		SRV_CAT varchar(100)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @OracleLinkedServers
	select
        SRV_NAME            = srv.name,
        SRV_PROVIDERNAME    = srv.provider,
        SRV_PRODUCT         = srv.product,
        SRV_DATASOURCE      = srv.data_source,
        SRV_PROVIDERSTRING  = srv.provider_string,
        SRV_LOCATION        = srv.location,
        SRV_CAT             = srv.catalog
    from
        sys.servers srv
    order by 1

	IF @IncludeBannerItems = 0 
		DELETE FROM @OracleLinkedServers WHERE SRV_NAME LIKE 'SIS%'

	RETURN 
END