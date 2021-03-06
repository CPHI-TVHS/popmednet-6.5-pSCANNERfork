IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[RoutingCounts]'))  drop view dbo.RoutingCounts
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[_RoutingCounts]'))  drop view dbo._RoutingCounts
go

set ansi_padding on
go

create view _RoutingCounts
with schemabinding
as
select QueryId,
	Sum(case when QueryStatusTypeId = 2 then 1 else 0 end) as CountSubmitted,
	Sum(case when QueryStatusTypeId = 3 then 1 else 0 end) as CountCompleted,
	Sum(case when QueryStatusTypeId = 4 then 1 else 0 end) as CountAwaitingRequestApproval,
	Sum(case when QueryStatusTypeId = 10 then 1 else 0 end) as CountAwaitingResponseApproval,
	COUNT_BIG(*) as CountTotal
from
	dbo.QueriesDataMarts
group by QueryId
go

create unique clustered index pk_ix on _RoutingCounts(QueryId) 
go

create index ix on _RoutingCounts(QueryId,CountSubmitted, CountCompleted, CountAwaitingRequestApproval, CountAwaitingResponseApproval, CountTotal)
go

create view RoutingCounts as select * from _RoutingCounts with(noexpand)
go

if exists( select * from sysindexes where object_name(id) = 'queries' and name = 'ix_org' ) drop index ix_org on queries
if exists( select * from sysindexes where object_name(id) = 'queries' and name = 'ix_sid' ) drop index ix_sid on queries
if exists( select * from sysindexes where object_name(id) = 'organizations' and name = 'ix_sid' ) drop index ix_sid on organizations
go

create index ix_org on queries(organizationid)
create index ix_sid on organizations([sid])
create index ix_sid on queries([sid])
go