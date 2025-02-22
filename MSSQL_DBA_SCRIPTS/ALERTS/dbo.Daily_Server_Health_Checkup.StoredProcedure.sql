USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Daily_Server_Health_Checkup]    Script Date: 2/6/2025 1:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






  
  
  
  
  
  
  
  
  
  
  
  
  
--select * from sys.sysobjects where name like '%profile%' and xtype='U'      
  
--select * from msdb..sysmail_mailitems order by send_request_date desc      
  
--select * from msdb..sysmail_profile      
  
        
  
 CREATE PROCEDURE [dbo].[Daily_Server_Health_Checkup]      
  
        
  
AS        
  
        
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
  
SET NOCOUNT ON      
  
SET ANSI_WARNINGS ON      
  
SET ANSI_WARNINGS ON        
  
SET ARITHABORT OFF        
  
SET ARITHIGNORE ON        
  
        
  
        
  
DECLARE @vRecipients AS VARCHAR (MAX)        
  
DECLARE @vCopy_Recipients AS VARCHAR (MAX)        
  
DECLARE @vUnused_Index_Uptime_Threshold AS INT        
  
DECLARE @vOnline_Since AS NVARCHAR (19)        
  
DECLARE @vUptime_Days AS INT        
  
DECLARE @vDate_24_Hours_Ago AS DATETIME        
  
DECLARE @vDate_Now AS DATETIME        
  
DECLARE @vSubject AS NVARCHAR (255)        
  
DECLARE @vFixed_Drives_Free_Space_Table AS TABLE (drive VARCHAR (5),TotalSize int, FreeSpace INT,Percentage int)     
  
DECLARE @vDatabase_Name AS NVARCHAR (500)        
  
DECLARE @vXML_String AS NVARCHAR (MAX)        
  
DECLARE @vBody AS NVARCHAR (MAX)        
  
DECLARE @vSQL_String AS NVARCHAR (MAX)        
  
    
  
DECLARE @hr int      
  
DECLARE @fso int      
  
DECLARE @drive char(1)      
  
DECLARE @odrive int      
  
DECLARE @TotalSize varchar(20)      
  
DECLARE @MB bigint ; SET @MB = 1048576      
  
CREATE TABLE #drives (ServerName varchar(50),      
  
drive char(1) PRIMARY KEY,      
  
FreeSpace int NULL,      
  
TotalSize int NULL,      
  
FreespaceTimestamp DATETIME NULL)      
  
INSERT #drives(drive,FreeSpace)      
  
EXEC master.dbo.xp_fixeddrives      
  
EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT      
  
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso      
  
DECLARE dcur CURSOR LOCAL FAST_FORWARD      
  
FOR SELECT drive from #drives      
  
ORDER by drive      
  
OPEN dcur    
  
FETCH NEXT FROM dcur INTO @drive      
  
WHILE @@FETCH_STATUS=0      
  
BEGIN      
  
EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @drive      
  
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso      
  
EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT      
  
IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive      
  
UPDATE #drives      
  
SET TotalSize=@TotalSize/@MB    
  
--, ServerName = @@servername, FreespaceTimestamp = (GETDATE())      
  
WHERE drive=@drive      
  
FETCH NEXT FROM dcur INTO @drive      
  
END      
  
CLOSE dcur      
  
DEALLOCATE dcur      
  
EXEC @hr=sp_OADestroy @fso      
  
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso      
  
--insert into dbo.Disk_space_detail    
  
insert into @vFixed_Drives_Free_Space_Table(drive,TotalSize,FreeSpace,Percentage)    
  
SELECT --ServerName,      
  
drive,      
  
TotalSize as 'Total(MB)',      
  
FreeSpace as 'Free(MB)',      
  
CAST((FreeSpace/(TotalSize*1.0))*100.0 as int) as 'Free(%)'    
  
--,  FreespaceTimestamp      
  
FROM #drives      
  
ORDER BY drive      
  
DROP TABLE #drives    
  
    
  
    

SET @vRecipients = 'muthuvels@chola.murugappa.com; sharmilik@chola.murugappa.com;visuk@chola.murugappa.com; cloversupportit@chola.murugappa.com; mssql.cholasupport@cloverinfotech.com'

 SET @vCopy_Recipients ='serversupport@chola.murugappa.com; saravanakumark@chola.murugappa.com;dhanarajanP@chola.murugappa.com;avinashn@chola.murugappa.com'  


SET @vUnused_Index_Uptime_Threshold = 7    
     
  
SELECT        
  
  @vOnline_Since = CONVERT (NVARCHAR (19), DB.create_date, 120)        
  
 ,@vUptime_Days = DATEDIFF (DAY, DB.create_date, GETDATE ())        
  
FROM        
  
 [master].[sys].[databases] DB        
  
WHERE        
  
 DB.name = 'tempdb'        
  
        
  
        
  
SET @vDate_24_Hours_Ago = GETDATE ()-1        
  
SET @vDate_Now = @vDate_24_Hours_Ago+1        
  
SET @vSubject = 'Chola SQL Server System Report: 10.9.45.156 (HFCLMSDB01\HFCLMSDB01)'      
  
SET @vXML_String = ''        
  
SET @vBody = ''        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Error Trapping: Check If Temp Table(s) Already Exist(s) And Drop If Applicable        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_instance_property_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_instance_property_temp        
  
        
  
END        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_database_size_distribution_stats_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_database_size_distribution_stats_temp        
  
        
  
END        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_model_compatibility_size_growth_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_model_compatibility_size_growth_temp        
  
        
  
END        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_last_backup_set_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_last_backup_set_temp        
  
        
  
END        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_agent_jobs_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_agent_jobs_temp        
  
        
  
END        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_unused_indexes_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_unused_indexes_temp        
  
        
  
END        
  
        
  
--------------------------------------------------------------------------------------------------------------------  
  
--sql service status 2008  
  
--------------------------------------------------------------------------------------------------------------------  
  
  
  
CREATE TABLE tempdb.dbo.hold_sql_services  
  
   (  
  
     SQL_ServiceName VARCHAR(100)  
  
     )  
  
       
  
INSERT INTO tempdb.dbo.hold_sql_services EXEC xp_cmdshell 'sc query type= service state= all |find "SQL" |find /V "DISPLAY_NAME" |find /V "AD" | find /V "Writer"'  
  
  
  
INSERT INTO tempdb.dbo.hold_sql_services EXEC xp_cmdshell 'sc query type= service state= all |find "MsDts" |find /V "DISPLAY_NAME"'  
  
  
  
DELETE tempdb.dbo.hold_sql_services WHERE SQL_ServiceName IS NULL  
  
  
  
ALTER TABLE tempdb.dbo.hold_sql_services  
  
    ADD SNID INT IDENTITY(1,1)  
  
  
  
CREATE TABLE tempdb.dbo.hold_sql_status  
  
    (  
  
    SvcStatus VARCHAR(55)  
  
    )  
  
  
  
DECLARE @SvcStatus VARCHAR(100)  
  
DECLARE @nSvcName VARCHAR(100)  
  
DECLARE @oSvcName VARCHAR(100)  
  
DECLARE @gService CURSOR  
  
DECLARE @cmd VARCHAR(500)  
  
DECLARE @cSTOP INT  
  
DECLARE @SvcStatTxt VARCHAR(100)  
  
  
  
SET @gService = CURSOR FOR  
  
SELECT SQL_ServiceName  
  
FROM tempdb.dbo.hold_sql_services  
  
  
  
OPEN @gService  
  
  
  
FETCH NEXT  
  
FROM @gService INTO @oSvcName  
  
  
  
WHILE @@FETCH_STATUS = 0  
  
BEGIN  
  
   SET @nSvcName=REPLACE(@oSvcName,'SERVICE_NAME: ','')  
  
   --Print @nSvcName  
  
  
  
   SET @cmd='sc query ' + @nSvcName + '|find "STATE"'  
  
   --Print @cmd  
  
  
  
   INSERT INTO tempdb.dbo.hold_sql_status EXEC xp_cmdshell @cmd  
  
  
  
   DELETE tempdb.dbo.hold_sql_status WHERE SvcStatus IS NULL  
  
  
  
   FETCH NEXT  
  
   FROM @gService INTO @oSvcName  
  
END  
  
  
  
CLOSE @gService  
  
DEALLOCATE @gService  
  
  
  
ALTER TABLE tempdb.dbo.hold_sql_status  
  
    ADD SSID INT IDENTITY(1,1)  
  
  
  
SET NOCOUNT ON   
  
  
  
  
  
  
  
SELECT sn.SQL_ServiceName AS ServiceName,   
  
CASE WHEN CHARINDEX('RUNNING',ss.SvcStatus) > 0 THEN 'RUNNING'  
  
       WHEN CHARINDEX('STOPPED',ss.SvcStatus) > 0 THEN 'STOPPED'  
  
       WHEN CHARINDEX('START_PENDING',ss.SvcStatus) > 0 THEN 'START PENDING'  
  
       WHEN CHARINDEX('STOP_PENDING',ss.SvcStatus) > 0 THEN 'STOP PENDING'  
  
       ELSE 'UNKNOWN' END AS ServiceStatus  
  
into #ssaj_sssr_instance_service_status  
  
FROM tempdb.dbo.hold_sql_status ss  
  
INNER JOIN tempdb.dbo.hold_sql_services sn ON sn.SNID=ss.SSID   
  
  
  
  
  
SET @vXML_String =          
  
          
  
          
  
 CONVERT (NVARCHAR (MAX),          
  
  (          
  
   SELECT          
  
     '',X.ServiceName AS 'td'          
  
    ,'',X.ServiceStatus AS 'td'          
  
         
  
           
  
   FROM          
  
    dbo.#ssaj_sssr_instance_service_status X          
  
   FOR          
  
    XML PATH ('tr')          
  
  )          
  
 )          
  
       
  
  
  
  
  
  SET @vBody =  @vBody +         
  
          
  
 '          
  
  <h3><center>Server instance service status</center></h3>          
  
  <center>          
  
   <table border=1 cellpadding=2>          
  
    <tr>          
  
     <th>servicename</th>          
  
     <th>status_desc</th>          
  
                     
  
    </tr>          
  
 '          
  
          
  
          
  
SET @vBody = @vBody + @vXML_String +          
  
          
  
 '          
  
   </table>          
  
  </center>          
  
 '    
  
    
  
  
  
  
  
  
  
  drop table dbo.#ssaj_sssr_instance_service_status     
  
  drop table  tempdb.dbo.hold_sql_services  
  
  drop table  tempdb.dbo.hold_sql_status   
  
   
  
  
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query I: Server Instance Property Information        
  
----------------------------------------------------------------------------------------------------------------------        
  
  
  
  
  
SELECT        
  
  SERVERPROPERTY ('ComputerNamePhysicalNetBIOS') AS netbios_name        
  
 ,@@SERVERNAME AS server_name        
  
 ,REPLACE (CONVERT (NVARCHAR (500), SERVERPROPERTY ('Edition')),' Edition','') AS edition        
  
 ,SERVERPROPERTY ('ProductVersion') AS version        
  
 ,SERVERPROPERTY ('ProductLevel') AS [level]        
  
 ,@vOnline_Since AS online_since        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, @vUptime_Days), 1)), 4, 20)) AS uptime_days        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, @@TOTAL_READ), 1)), 4, 20)) AS reads        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, @@TOTAL_WRITE), 1)), 4, 20)) AS writes    
  
 --,@AVGCPU as AverageCPU       
  
INTO        
  
 dbo.#ssaj_sssr_instance_property_temp        
  
        
  
        
  
IF @@ROWCOUNT = 0        
  
BEGIN        
  
        
  
 GOTO skip_instance_property        
  
        
  
END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
   SELECT        
  
     '',X.netbios_name AS 'td'        
  
    ,'',X.server_name AS 'td'        
  
    ,'',X.edition AS 'td'        
  
    ,'',X.version AS 'td'        
  
    ,'',X.level AS 'td'        
  
    ,'',X.online_since AS 'td'        
  
    ,'','right_align'+X.uptime_days AS 'td'        
  
    ,'','right_align'+X.reads AS 'td'        
  
    ,'','right_align'+X.writes AS 'td'        
  
   --,'',@AVGCPU AS 'td'        
  
   FROM        
  
    dbo.#ssaj_sssr_instance_property_temp X        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody =        
  
        
  
 '        
  
  <h3><center>Server Instance Property Information</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>NetBIOS Name</th>        
  
     <th>Server Name</th>        
  
     <th>Edition</th>        
  
     <th>Version</th>        
  
     <th>Level</th>        
  
     <th>Online Since</th>        
  
     <th>Uptime Days</th>        
  
     <th>Reads</th>        
  
     <th>Writes</th>      
  
        
  
    </tr>        
  
 '        
  
        
  
        
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_instance_property:        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_instance_property_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_instance_property_temp        
  
        
  
END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query II: Fixed Drives Free Space        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
--INSERT INTO @vFixed_Drives_Free_Space_Table        
  
        
  
-- (        
  
--   drive        
  
--  ,free_space_mb    
  
         
  
-- )        
  
        
  
--EXEC master.dbo.xp_fixeddrives        
  
        
  
        
  
--IF @@ROWCOUNT = 0        
  
--BEGIN        
  
        
  
-- GOTO skip_fixed_drives_free_space        
  
        
  
--END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
  SELECT 'tr/@bgcolor'= CASE  WHEN X.FreeSpace > 20480 
   THEN '#90EE90' 
ELSE '#FF4500' END,      
  
     '',X.drive+':' AS 'td'        
  
     ,'',X.Totalsize AS 'td'    
  
     ,'',X.FreeSpace AS 'td'    
  
     ,'',X.Percentage AS 'td'    
  
    --,'','right_align'+REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, X.free_space_mb), 1)), 4, 20)) AS 'td'        
  
    --,'','right_align'+REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, X.free_space_mb), 1)), 4, 20)) AS 'td'        
  
    --,'','right_align'+REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, X.free_space_mb), 1)), 4, 20)) AS 'td'        
  
   FROM        
  
    @vFixed_Drives_Free_Space_Table X        
  
   ORDER BY        
  
    X.drive        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody = @vBody+        
  
        
  
 '        
  
  <br><br>        
  
  <h3><center>Fixed Drives Free Space</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>Drive</th>        
  
     <th>Total Size (MB)</th>        
  
    <th>Free Space(MB)</th>        
  
    <th>%Free Space</th>        
  
    </tr>        
  
 '        
  
        
  
        
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_fixed_drives_free_space:        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query III: Database Size (Summary) / Distribution Stats        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
CREATE TABLE dbo.#ssaj_sssr_database_size_distribution_stats_temp        
  
        
  
 (        
  
   database_name NVARCHAR (500)        
  
  ,total_size_mb NVARCHAR (20)        
  
  ,unallocated_mb NVARCHAR (20)        
  
  ,reserved_mb NVARCHAR (20)        
  
  ,data_mb NVARCHAR (20)        
  
  ,index_mb NVARCHAR (20)        
  
  ,unused_mb NVARCHAR (20)        
  
 )        
  
        
  
        
  
SET @vDatabase_Name = (SELECT TOP 1 DB.name FROM [master].[sys].[databases] DB WHERE DB.state = 0 AND DB.is_read_only = 0 AND DB.is_in_standby = 0 AND DB.source_database_id IS NULL ORDER BY DB.name)        
  
        
  
        
  
WHILE @vDatabase_Name IS NOT NULL        
  
BEGIN        
  
        
  
 SET @vSQL_String =        
  
        
  
  '        
  
   USE ['+@vDatabase_Name+'];        
  
        
  
        
  
   INSERT INTO dbo.#ssaj_sssr_database_size_distribution_stats_temp        
  
        
  
   SELECT        
  
     DB_NAME () AS database_name        
  
    ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((A.total_size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS total_size_mb        
  
    ,(CASE        
  
     WHEN A.database_size >= B.total_pages THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND (((A.database_size-B.total_pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20))        
  
     ELSE ''0''        
  
     END) AS unallocated_mb        
  
    ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((B.total_pages*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS reserved_mb        
  
    ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((B.pages*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS data_mb        
  
    ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND (((B.used_pages-B.pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS index_mb        
  
    ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND (((B.total_pages-B.used_pages)*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS unused_mb        
  
   FROM        
  
        
  
    (        
  
     SELECT        
  
       SUM (CASE        
  
        WHEN DBF.type = 0 THEN DBF.size        
  
        ELSE 0        
  
        END) AS database_size        
  
      ,SUM (DBF.size) AS total_size        
  
     FROM        
  
      [sys].[database_files] AS DBF        
  
     WHERE        
  
      DBF.type IN (0,1)        
  
    ) A        
  
        
  
    CROSS JOIN        
  
        
  
     (        
  
     SELECT        
  
        SUM (AU.total_pages) AS total_pages        
  
       ,SUM (AU.used_pages) AS used_pages        
  
       ,SUM (CASE        
  
         WHEN IT.internal_type IN (202,204) THEN 0        
  
         WHEN AU.type <> 1 THEN AU.used_pages        
  
         WHEN P.index_id <= 1 THEN AU.data_pages        
  
         ELSE 0        
  
         END) AS pages        
  
      FROM        
  
       [sys].[partitions] P        
  
       INNER JOIN [sys].[allocation_units] AU ON AU.container_id = P.partition_id        
  
       LEFT JOIN [sys].[internal_tables] IT ON IT.[object_id] = P.[object_id]        
  
     ) B        
  
  '        
  
        
  
        
  
 EXEC (@vSQL_String)        
  
        
  
        
  
 SET @vDatabase_Name = (SELECT TOP 1 DB.name FROM [master].[sys].[databases] DB WHERE DB.state = 0 AND DB.is_read_only = 0 AND DB.is_in_standby = 0 AND DB.source_database_id IS NULL AND DB.name > @vDatabase_Name ORDER BY DB.name)        
  
        
  
END        
  
        
  
        
  
IF (SELECT COUNT (*) FROM dbo.#ssaj_sssr_database_size_distribution_stats_temp) = 0        
  
BEGIN        
  
        
  
 GOTO skip_database_size_distribution_stats        
  
        
  
END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
   SELECT        
  
     '',X.database_name AS 'td'        
  
    ,'','right_align'+X.total_size_mb AS 'td'        
  
    ,'','right_align'+X.unallocated_mb AS 'td'        
  
    ,'','right_align'+X.reserved_mb AS 'td'        
  
    ,'','right_align'+X.data_mb AS 'td'        
  
    ,'','right_align'+X.index_mb AS 'td'        
  
    ,'','right_align'+X.unused_mb AS 'td'        
  
   FROM        
  
    dbo.#ssaj_sssr_database_size_distribution_stats_temp X        
  
   ORDER BY        
  
    X.database_name        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody = @vBody+        
  
        
  
 '        
  
  <br><br>        
  
  <h3><center>Database Size (Summary) / Distribution Stats</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>Database Name</th>        
  
     <th>Total Size (MB)</th>        
  
     <th>Unallocated (MB)</th>        
  
     <th>Reserved (MB)</th>        
  
     <th>Data (MB)</th>        
  
     <th>Index (MB)</th>        
  
     <th>Unused (MB)</th>        
  
    </tr>        
  
 '        
  
        
  
        
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_database_size_distribution_stats:        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_database_size_distribution_stats_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_database_size_distribution_stats_temp        
  
        
  
END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query IV: Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
SELECT        
  
  DB_NAME (MF.database_id) AS database_name   
  
  ,DB.state_desc       
  
 ,DB.recovery_model_desc        
  
 ,DB.compatibility_level        
  
 ,CONVERT (NVARCHAR (10), LEFT (UPPER (MF.type_desc),1)+LOWER (SUBSTRING (MF.type_desc, 2, 250))) AS file_type        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((MF.size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20)) AS file_size_mb        
  
 ,RIGHT ((CASE        
  
    WHEN MF.growth = 0 THEN 'Fixed Size'        
  
    WHEN MF.max_size = -1 THEN 'Unrestricted'        
  
    WHEN MF.max_size = 0 THEN 'None'        
  
    WHEN MF.max_size = 268435456 THEN '2 TB'        
  
    ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((MF.max_size*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20))+' MB'        
  
    END),20) AS max_size        
  
 ,RIGHT ((CASE        
  
    WHEN MF.growth = 0 THEN 'N/A'        
  
    WHEN MF.is_percent_growth = 1 THEN REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, MF.growth), 1)), 4, 20))+' %'        
  
    ELSE REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND ((MF.growth*CONVERT (BIGINT, 8192))/1048576.0, 0)), 1)), 4, 20))+' MB'        
  
    END),20) AS growth_increment        
  
 ,ROW_NUMBER () OVER        
  
      (        
  
       PARTITION BY        
  
        MF.database_id        
  
       ORDER BY        
  
         MF.type        
  
        ,MF.[file_id]        
  
      ) AS database_filter_id        
  
INTO        
  
 dbo.#ssaj_sssr_model_compatibility_size_growth_temp        
  
FROM        
  
 [master].[sys].[master_files] MF        
  
 INNER JOIN [master].[sys].[databases] DB ON DB.database_id = MF.database_id        
  
        
  
        
  
IF @@ROWCOUNT = 0        
  
BEGIN        
  
        
  
 GOTO skip_model_compatibility_size_growth        
  
        
  
END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
   SELECT        
  
     '',(CASE        
  
      WHEN X.database_filter_id = 1 THEN X.database_name        
  
      ELSE ''        
  
      END) AS 'td'        
  
    ,  
  
 '',(CASE        
  
      WHEN X.database_filter_id = 1 THEN X.state_desc        
  
      ELSE ''        
  
      END) AS 'td'        
  
   
  
 ,  
  
 '',(CASE        
  
      WHEN X.database_filter_id = 1 THEN X.recovery_model_desc        
  
      ELSE ''        
  
      END) AS 'td'        
  
    ,'',(CASE        
  
      WHEN X.database_filter_id = 1 THEN ISNULL (CONVERT (VARCHAR (5), X.compatibility_level),'N/A')        
  
      ELSE ''        
  
      END) AS 'td'        
  
    ,'',X.file_type AS 'td'        
  
    ,'','right_align'+X.file_size_mb AS 'td'        
  
    ,'','right_align'+X.max_size AS 'td'        
  
    ,'','right_align'+X.growth_increment AS 'td'        
  
   FROM        
  
    dbo.#ssaj_sssr_model_compatibility_size_growth_temp X        
  
   ORDER BY        
  
     X.database_name        
  
    ,X.database_filter_id        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody = @vBody+        
  
        
  
 '        
  
  <br><br>        
  
  <h3><center>Database Recovery Model / Compatibility / Size (Detailed) / Growth Stats</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>Database Name</th>        
  
     <th>Database Status</th>  
  
  <th>Recovery Model</th>        
  
     <th>Compatibility</th>        
  
     <th>File Type</th>        
  
     <th>File Size (MB)</th>        
  
     <th>Max Size</th>        
  
     <th>Growth Increment</th>        
  
    </tr>        
  
 '        
  
        
  
        
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_model_compatibility_size_growth:        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_model_compatibility_size_growth_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_model_compatibility_size_growth_temp        
  
        
  
END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query V: Last Backup Set Details        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
SELECT        
  
  BS.database_name        
  
 ,BS.backup_set_id        
  
 ,(CASE        
  
  WHEN BS.type = 'D' THEN 'Database'        
  
  WHEN BS.type = 'F' THEN 'File Or Filegroup'        
  
  WHEN BS.type = 'G' THEN 'Differential File'        
  
  WHEN BS.type = 'I' THEN 'Differential Database'        
  
  WHEN BS.type = 'L' THEN 'Log'        
  
  WHEN BS.type = 'P' THEN 'Partial'        
  
  WHEN BS.type = 'Q' THEN 'Differential Partial'        
  
  ELSE 'N/A'        
  
  END) AS backup_type        
  
 ,CONVERT (VARCHAR (19), BS.backup_start_date, 120) AS backup_start_date        
  
 ,(CASE        
  
  WHEN DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) >= 360000 THEN '99:59:59+'        
  
  WHEN DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) < 1 THEN '__:__:__'        
  
  WHEN DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) < 60 THEN '__:__:'+RIGHT ('00'+CONVERT (VARCHAR (2), ((DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))%3600)%60),2)        
  
  WHEN DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date) < 3600 THEN '__:'+RIGHT ('00'+CONVERT (VARCHAR (2), ((DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))%3600)/60),2)+':'+RIGHT ('00'+CONVERT (VARCHAR (2), ((DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))%3600)%60),2)        
  
  ELSE RIGHT ('00'+CONVERT (VARCHAR (2), (DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))/3600),2)+':'+RIGHT ('00'+CONVERT (VARCHAR (2), ((DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))%3600)/60),2)+':'+RIGHT ('00'+CONVERT
  
  
  
    
  
    
  
      
  
 (VARCHAR (2), ((DATEDIFF (SECOND, BS.backup_start_date, BS.backup_finish_date))%3600)%60),2)        
  
  END) AS duration        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, ROUND (BS.backup_size/1048576.0, 0)), 1)), 4, 20)) AS backup_size_mb        
  
 ,REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, DATEDIFF (DAY, BS.backup_start_date, GETDATE ())), 1)), 4, 20)) AS days_ago        
  
 ,ROW_NUMBER () OVER        
  
      (        
  
       PARTITION BY        
  
        BS.database_name        
  
       ORDER BY        
  
        BS.type        
  
      ) AS database_filter_id        
  
INTO        
  
 dbo.#ssaj_sssr_last_backup_set_temp        
  
FROM        
  
 msdb.dbo.backupset BS        
  
 INNER JOIN        
  
        
  
  (        
  
   SELECT        
  
    MAX (X.backup_set_id) AS backup_set_id_max        
  
   FROM        
  
    msdb.dbo.backupset X        
  
   GROUP BY        
  
     X.database_name        
  
    ,X.type        
  
  ) A ON A.backup_set_id_max = BS.backup_set_id        
  
        
  
        
  
IF @@ROWCOUNT = 0        
  
BEGIN        
  
        
  
 GOTO skip_last_backup_set        
  
        
  
END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
   SELECT        
  
     '',(CASE        
  
      WHEN X.database_filter_id = 1 THEN X.database_name        
  
      ELSE ''        
  
      END) AS 'td'        
  
    ,'',X.backup_set_id AS 'td'        
  
    ,'',X.backup_type AS 'td'        
  
    ,'',X.backup_start_date AS 'td'        
  
    ,'',X.duration AS 'td'        
  
    ,'','right_align'+X.backup_size_mb AS 'td'        
  
    ,'','right_align'+X.days_ago AS 'td'        
  
   FROM        
  
    dbo.#ssaj_sssr_last_backup_set_temp X        
  
   ORDER BY        
  
     X.database_name        
  
    ,X.database_filter_id        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody = @vBody+        
  
        
  
 '        
  
  <br><br>        
  
  <h3><center>Last Backup Set Details</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>Database Name</th>        
  
     <th>Backup Set ID</th>        
  
     <th>Backup Type</th>        
  
     <th>Backup Start Date</th>        
  
     <th>Duration</th>        
  
     <th>Backup Size (MB)</th>        
  
     <th>Days Ago</th>        
  
    </tr>        
  
 '        
  
        
  
        
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_last_backup_set:        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_last_backup_set_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_last_backup_set_temp        
  
        
  
END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query VI: SQL Server Agent Jobs (Last 24 Hours)        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
SELECT        
  
  SJ.name AS job_name        
  
 ,CONVERT (VARCHAR (19), CONVERT (DATETIME, CONVERT (VARCHAR (8), SJH.run_date)+' '+LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),2)+':'+SUBSTRING (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),3,2)+':'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),2)), 120) AS last_run_date_time ,(CASE    WHEN SJH.run_status = 0 THEN 'Failed'        
  
  WHEN SJH.run_status = 1 THEN 'Succeeded'        
  
  WHEN SJH.run_status = 2 THEN 'Retry'        
  
  WHEN SJH.run_status = 3 THEN 'Canceled'        
  
  WHEN SJH.run_status = 4 THEN 'In Progress'        
  
  END) AS last_status        
  
 ,(CASE        
  
  WHEN RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6) = '000000' THEN '__:__:__'        
  
  WHEN LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),4) = '0000' THEN '__:__:'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),2)        
  
  WHEN LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),2) = '00' THEN '__:'+SUBSTRING (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),3,2)+':'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),2)        
  
  ELSE LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),2)+':'+SUBSTRING (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),3,2)+':'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_duration),6),2)        
  
  END) AS duration        
  
 ,ISNULL (CONVERT (VARCHAR (19), B.next_run_date_time, 120),'___________________') AS next_run_date_time        
  
 ,ISNULL (REVERSE (SUBSTRING (REVERSE (CONVERT (VARCHAR (20), CONVERT (MONEY, DATEDIFF (DAY, GETDATE (), B.next_run_date_time)), 1)), 4, 20)),'N/A') AS days_away        
  
INTO        
  
 dbo.#ssaj_sssr_agent_jobs_temp        
  
FROM        
  
 msdb.dbo.sysjobs SJ        
  
 INNER JOIN msdb.dbo.sysjobhistory SJH ON SJH.job_id = SJ.job_id        
  
  AND CONVERT (DATETIME, CONVERT (VARCHAR (9), SJH.run_date)+' '+LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),2)+':'+SUBSTRING (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),3,2)+':'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJH.run_time),6),2)) >= @vDate_24_Hours_Ago        
  
 INNER JOIN        
  
        
  
  (        
  
   SELECT        
  
    MAX (X.instance_id) AS instance_id_max        
  
   FROM        
  
    msdb.dbo.sysjobhistory X        
  
   GROUP BY        
  
X.job_id        
  
  ) A ON A.instance_id_max = SJH.instance_id 
 LEFT JOIN(SELECT        
  
     SJS.job_id        
  
    ,MIN (CONVERT (DATETIME, CONVERT (VARCHAR (9), SJS.next_run_date)+' '+LEFT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJS.next_run_time),6),2)+':'+SUBSTRING (RIGHT ('000000'+CONVERT (VARCHAR (6), SJS.next_run_time),6),3,2)+':'+RIGHT (RIGHT ('000000'+CONVERT (VARCHAR (6), SJS.next_run_time),6),2))) AS next_run_date_time  FROM  msdb.dbo.sysjobschedules SJS WHERE  SJS.next_run_date > 0        
  
   GROUP BY        
  
    SJS.job_id) B ON B.job_id = SJ.job_id  where SJH.run_status = 0      
  
        
  
        
  
IF @@ROWCOUNT = 0        
  
BEGIN        
  
        
  
 GOTO skip_agent_jobs        
  
        
  
END        
  
        
  
        
  
SET @vXML_String =        
  
        
  
 CONVERT (NVARCHAR (MAX),        
  
  (        
  
  SELECT 'tr/@bgcolor'= CASE X.last_status WHEN  'Succeeded'
   THEN '#90EE90' 
ELSE '#FF4500' END,      
  
     '',X.job_name AS 'td'        
  
    ,'',X.last_run_date_time AS 'td'        
  
    ,'',X.last_status AS 'td'        
  
    ,'',X.duration AS 'td'        
  
    ,'',X.next_run_date_time AS 'td'        
  
    ,'','right_align'+X.days_away AS 'td'        
  
   FROM        
  
    dbo.#ssaj_sssr_agent_jobs_temp X        
  
   ORDER BY        
  
    X.job_name        
  
   FOR        
  
    XML PATH ('tr')        
  
  )        
  
 )        
  
        
  
        
  
SET @vBody = @vBody+        
  
        
  
 '        
  
  <br><br>        
  
  <h3><center>SQL Server Agent Jobs (Last 24 Hours)</center></h3>        
  
  <center>        
  
   <table border=1 cellpadding=2>        
  
    <tr bgcolor="#8181F7">        
  
     <th>Job Name</th>        
  
     <th>Last Run Date / Time</th>        
  
     <th>Last Status</th>        
  
     <th>Duration</th>        
  
     <th>Next Run Date / Time</th>        
  
     <th>Days Away</th>        
  
    </tr>        
  
 '        
  
        
  
       
  
SET @vBody = @vBody+@vXML_String+        
  
        
  
 '        
  
   </table>        
  
  </center>        
  
 '        
  
        
  
        
  
skip_agent_jobs:        
  
        
  
        
  
IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_agent_jobs_temp') IS NOT NULL        
  
BEGIN        
  
        
  
 DROP TABLE dbo.#ssaj_sssr_agent_jobs_temp        
  
        
  
END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Main Query VII: Unused Indexes        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
--IF @vUptime_Days <= @vUnused_Index_Uptime_Threshold        
  
--BEGIN        
  
        
  
-- GOTO skip_unused_indexes        
  
        
  
--END        
  
      
  
        
  
--CREATE TABLE dbo.#ssaj_sssr_unused_indexes_temp        
  
        
  
-- (        
  
--   database_name NVARCHAR (512)        
  
--  ,[object_name] SYSNAME        
  
--  ,column_name SYSNAME        
  
--  ,index_name SYSNAME        
  
--  ,[disabled] VARCHAR (3)        
  
--  ,hypothetical VARCHAR (3)        
  
--  ,drop_index_statement NVARCHAR (4000)        
  
-- )        
  
        
  
        
  
--SET @vDatabase_Name = (SELECT TOP 1 DB.name FROM [master].[sys].[databases] DB WHERE DB.state = 0 AND DB.is_read_only = 0 AND DB.is_in_standby = 0 AND DB.source_database_id IS NULL ORDER BY DB.name)        
  
        
  
        
  
--WHILE @vDatabase_Name IS NOT NULL        
  
--BEGIN        
  
        
  
-- SET @vSQL_String =        
  
        
  
--  '        
  
--   USE ['+@vDatabase_Name+'];        
  
        
  
        
  
--   INSERT INTO dbo.#ssaj_sssr_unused_indexes_temp        
  
        
  
--   SELECT        
  
--     DB_NAME () AS database_name        
  
--    ,O.name AS [object_name]        
  
--    ,C.name AS column_name        
  
--    ,I.name AS index_name        
  
--    ,(CASE        
  
--     WHEN I.is_disabled = 1 THEN ''Yes''        
  
--     ELSE ''No''        
  
--     END) AS [disabled]        
  
--    ,(CASE        
  
--     WHEN I.is_hypothetical = 1 THEN ''Yes''        
  
--     ELSE ''No''        
  
--     END) AS hypothetical        
  
--    ,''USE ''+DB_NAME ()+''; DROP INDEX ''+S.name+''.''+O.name+''.''+I.name+'';'' AS drop_index_statement        
  
--   FROM        
  
--    [sys].[indexes] I        
  
--    INNER JOIN [sys].[objects] O ON O.[object_id] = I.[object_id]        
  
--     AND O.type = ''U''        
  
--     AND O.is_ms_shipped = 0        
  
--     AND O.name <> ''sysdiagrams''        
  
--    INNER JOIN [sys].[tables] T ON T.[object_id] = I.[object_id]        
  
--    INNER JOIN [sys].[schemas] S ON S.[schema_id] = T.[schema_id]        
  
--    INNER JOIN [sys].[index_columns] IC ON IC.[object_id] = I.[object_id]        
  
--     AND IC.index_id = I.index_id        
  
--    INNER JOIN [sys].[columns] C ON C.[object_id] = IC.[object_id]        
  
--     AND C.column_id = IC.column_id        
  
--   WHERE        
  
--    I.type > 0        
  
--    AND I.is_primary_key = 0        
  
--    AND I.is_unique_constraint = 0        
  
--    AND NOT EXISTS        
  
        
  
--     (        
  
--      SELECT        
  
--       *        
  
--      FROM        
  
--       [sys].[index_columns] XIC        
  
--       INNER JOIN [sys].[foreign_key_columns] FKC ON FKC.parent_object_id = XIC.[object_id]        
  
--        AND FKC.parent_column_id = XIC.column_id        
  
--      WHERE        
  
--       XIC.[object_id] = I.[object_id]        
  
--       AND XIC.index_id = I.index_id        
  
--     )        
  
        
  
--    AND NOT EXISTS        
  
        
  
--     (        
  
--      SELECT        
  
--       *        
  
--      FROM        
  
--       [master].[sys].[dm_db_index_usage_stats] IUS        
  
--      WHERE        
  
--       IUS.database_id = DB_ID (DB_NAME ())        
  
--       AND IUS.[object_id] = I.[object_id]        
  
--       AND IUS.index_id = I.index_id        
  
--     )        
  
--  '        
  
        
  
        
  
-- EXEC (@vSQL_String)        
  
        
  
        
  
-- SET @vDatabase_Name = (SELECT TOP 1 DB.name FROM [master].[sys].[databases] DB WHERE DB.state = 0 AND DB.is_read_only = 0 AND DB.is_in_standby = 0 AND DB.source_database_id IS NULL AND DB.name > @vDatabase_Name ORDER BY DB.name)        
  
        
  
--END        
  
        
  
        
  
--IF (SELECT COUNT (*) FROM dbo.#ssaj_sssr_unused_indexes_temp) = 0        
  
--BEGIN        
  
        
  
-- GOTO skip_unused_indexes        
  
        
  
--END        
  
        
  
        
  
--SET @vXML_String =        
  
        
  
-- CONVERT (NVARCHAR (MAX),        
  
--  (        
  
--   SELECT        
  
--     '',X.database_name AS 'td'        
  
--    ,'',X.[object_name] AS 'td'        
  
--    ,'',X.column_name AS 'td'        
  
--    ,'',X.index_name AS 'td'        
  
--    ,'',X.[disabled] AS 'td'        
  
--    ,'',X.hypothetical AS 'td'        
  
--    ,'',X.drop_index_statement AS 'td'        
  
--   FROM        
  
--    dbo.#ssaj_sssr_unused_indexes_temp X        
  
--   ORDER BY        
  
--     X.database_name        
  
--    ,X.[object_name]        
  
--    ,X.column_name        
  
--    ,X.index_name        
  
--   FOR        
  
--    XML PATH ('tr')        
  
--  )        
  
-- )        
  
        
  
        
  
--SET @vBody = @vBody+        
  
        
  
-- '        
  
--  <br><br>        
  
--  <h3><center>Unused Indexes</center></h3>        
  
--  <center>        
  
--   <table border=1 cellpadding=2>        
  
--    <tr bgcolor="#8181F7">        
  
--     <th>Database Name</th>        
  
--     <th>Object Name</th>        
  
--     <th>Column Name</th>        
  
--     <th>Index Name</th>        
  
--     <th>Disabled</th>        
  
--     <th>Hypothetical</th>        
  
--     <th>Drop Index Statement</th>        
  
--    </tr>        
  
-- '        
  
        
  
        
  
--SET @vBody = @vBody+@vXML_String+        
  
        
  
-- '        
  
--   </table>        
  
--  </center>        
  
-- '        
  
        
  
        
  
--skip_unused_indexes:        
  
        
  
        
  
--IF OBJECT_ID ('tempdb.dbo.#ssaj_sssr_unused_indexes_temp') IS NOT NULL        
  
--BEGIN       
  
        
  
-- DROP TABLE dbo.#ssaj_sssr_unused_indexes_temp        
  
        
  
--END        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- Variable Update: Finalize @vBody Variable Contents        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
SET @vBody =        
  
        
  
 '        
  
  <html>        
  
   <body>        
  
   <style type="text/css">        
  
    table {font-size:8.0pt;font-family:Arial;text-align:left;}        
  
    tr {text-align:left;}        
  
   </style>        
  
 '        
  
        
  
 +@vBody+        
  
        
  
 '        
  
   </body>        
  
  </html>        
  
 '        
  
        
  
        
  
SET @vBody = REPLACE (@vBody,'<td>right_align','<td align="right">')        
  
        
  
        
  
----------------------------------------------------------------------------------------------------------------------        
  
-- sp_send_dbmail: Deliver Results / Notification To End User(s)        
  
----------------------------------------------------------------------------------------------------------------------        
  
        
  
EXEC msdb.dbo.sp_send_dbmail        
  
        
  
  @recipients = @vRecipients        
  
 ,@copy_recipients = @vCopy_Recipients        
  
 ,@subject = @vSubject        
  
 ,@profile_name= 'Posidex'  
  
 ,@body = @vBody        
  
 ,@body_format = 'HTML'        
  
  
  
  
  
GO
