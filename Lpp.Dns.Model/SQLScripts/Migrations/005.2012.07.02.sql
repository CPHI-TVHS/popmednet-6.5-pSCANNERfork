declare @sqlText nvarchar(max)
SELECT @sqlText = 'ALTER TABLE [dbo].[AuditPropertyValues] DROP CONSTRAINT [' + object_name(object_id) + ']'
FROM sys.foreign_keys WHERE object_name(object_id) like '%FK__AuditProp__Event__%' AND parent_object_id = OBJECT_ID(N'[dbo].[AuditPropertyValues]')
if @sqlText is not null begin exec sp_sqlexec @sqlText end
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_AuditPropertValues_AuditEvents]') AND parent_object_id = OBJECT_ID(N'[dbo].[AuditPropertyValues]'))
alter table auditpropertyvalues drop constraint FK_AuditPropertValues_AuditEvents
GO

alter table auditpropertyvalues with check add constraint FK_AuditPropertValues_AuditEvents
foreign key(EventId) references AuditEvents on delete cascade
GO