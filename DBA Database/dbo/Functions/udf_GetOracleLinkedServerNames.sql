-- =============================================
-- Author:		Ken Taylor
-- Create date: August 13, 2013
-- Description:	Return a list of all Oracle Linked Database Servers
-- Revised as UDF in order to use in select statement since no variables need be changed.
-- Usage
/*
USE [DBA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[udf_GetOracleLinkedServerNames]

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
CREATE FUNCTION [dbo].[udf_GetOracleLinkedServerNames] 
(
)
RETURNS 
@LinkedServerNames TABLE 
(	
	SRV_NAME varchar(100)
)
AS
BEGIN
	
   

	EXEC sp_linkedservers

	
	RETURN 
END
