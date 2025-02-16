USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Send_DB_MAIL_AT_SQL_RESTART]    Script Date: 2/6/2025 1:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--select * from msdb..sysmail_profile
create PROCEDURE [dbo].[Send_DB_MAIL_AT_SQL_RESTART]
	-- Add the parameters for the stored procedure here
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Posidex',
    @recipients='cloversqlconnect@cloverinfotech.com;cloversqldb@chola1.murugappa.com',   
       --@copy_recipients='saravanakumark@chola.murugappa.com;ramachandrank@chola.murugappa.com', 
    @body = '"This is an automated notification. Please do not reply to this mail. 

10.11.32.17  SQL Server Service has been restarted."',
    @subject = '10.11.32.17 SQL Server Service Restarted' ;

END
GO
