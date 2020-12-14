USE ABC_Mobile_Services
GO
EXEC sp_addlinkedserver @server='WWI2', -- local SQL name given to the linked server
 
@srvproduct='', -- not used 
 
@provider='MSOLAP', -- OLE DB provider 
 
@datasrc='DESKTOP-8AIVGG4\KR', -- analysis server name (machine name) 
 
@catalog='SQLShackOLAPMadeEasy' -- default catalog/database 
 
--Drop the server
-- Clean-up
--USE [master]
--GO
--EXEC master.dbo.sp_dropserver @server = WWI2 
--GO