USE [master]
GO
/****** Object:  StoredProcedure [dbo].[usp_DBStatus]    Script Date: 2/6/2025 1:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




  
create procedure [dbo].[usp_DBStatus]  
  
as  
  
begin  
  
if(select count(*) from sys.databases where state_desc<>'Online')>0  
Begin  
  
DECLARE @table NVARCHAR(MAX) ;  
  
SET @table =  
N'<H1 style= color:red>Offline Databases Report</H1>' +  
N'<table border="1">' +  
N'<tr><th>Database Name</th><th>Database Status</th></tr>' +  
CAST ( ( Select td=name, '',td=state_desc from sys.databases where state_desc<>'Online'  
FOR XML PATH('tr'), TYPE  
) AS NVARCHAR(MAX) ) +  
N'</table>' ;  
  
EXEC msdb.dbo.sp_send_dbmail @profile_name='Posidex', --Change to your Profile Name  
@recipients='cloversqlconnect@cloverinfotech.com;cloversqldb@chola1.murugappa.com', --Put the email address of those who want to receive the e-mail  
@subject = 'Offline Databases Report 10.11.32.17',  
@body = @table,  
@body_format = 'HTML' ;  
  
END  
Else Print 'All Databases are Online'  
  
end  


GO
