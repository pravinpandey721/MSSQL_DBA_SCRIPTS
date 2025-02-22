USE [master]
GO
/****** Object:  StoredProcedure [dbo].[log_space]    Script Date: 2/6/2025 1:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[log_space]  
  
as  
  
select b.name,b.recovery_model_desc,b.log_reuse_wait_desc,(a.size*8)/(1024*1024)as log from sys.databases b,sys.sysaltfiles a  
where a.dbid = b.database_id and a.filename like '%.ldf'and (a.size*8)/(1024*1024)>0.9 
GO
