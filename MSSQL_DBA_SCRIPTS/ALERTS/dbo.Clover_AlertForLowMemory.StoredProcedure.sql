USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Clover_AlertForLowMemory]    Script Date: 2/6/2025 1:17:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Clover_AlertForLowMemory]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @availmemory int
	declare @subjectline varchar(max)
	select  @availmemory=available_physical_memory_kb from  

sys.dm_os_sys_memory
--print   @availmemory
	--set @availmemory=1900
	IF @availmemory < 102400

	BEGIN
		set @subjectline= 'On  Server - AVAILABLE MEMORY IS LOW  '  + 

convert(varchar(10),@availmemory) + 'MB'
	

	EXEC msdb.dbo.sp_send_dbmail 

	@recipients='cloversqlconnect@cloverinfotech.com',

	@profile_name = 'Posidex ',    

	@subject = @subjectline,

	@body = 'Kindly check the server, in order to avoid the issues.

Regards,
SQLDBA.'
	
	END
END




GO
