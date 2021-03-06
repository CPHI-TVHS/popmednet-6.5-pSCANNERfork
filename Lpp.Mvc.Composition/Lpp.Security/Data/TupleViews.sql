-- This file contains SQL views for producing object tuples of different sizes with their corresponding ACL entries.

	-------------------------------------------------------------------------------
	-- SecurityInheritanceClosure2 - an exact duplicate of the SecurityInheritanceClosure table
	-------------------------------------------------------------------------------
	create table SecurityInheritanceClosure2( [Start] uniqueidentifier not null, [End] uniqueidentifier not null, [Distance] int not null default 0 )
	go

	alter table SecurityInheritanceClosure2 add constraint SecurityInheritanceClosure2_PK primary key([Start],[End])
	go

	insert into SecurityInheritanceClosure2( [Start],[End],[Distance] ) select [Start],[End],[Distance] from SecurityInheritanceClosure
	go
	-------------------------------------------------------------------------------
	-- SecurityInheritanceClosure3 - an exact duplicate of the SecurityInheritanceClosure table
	-------------------------------------------------------------------------------
	create table SecurityInheritanceClosure3( [Start] uniqueidentifier not null, [End] uniqueidentifier not null, [Distance] int not null default 0 )
	go

	alter table SecurityInheritanceClosure3 add constraint SecurityInheritanceClosure3_PK primary key([Start],[End])
	go

	insert into SecurityInheritanceClosure3( [Start],[End],[Distance] ) select [Start],[End],[Distance] from SecurityInheritanceClosure
	go
	-------------------------------------------------------------------------------
	-- SecurityInheritanceClosure4 - an exact duplicate of the SecurityInheritanceClosure table
	-------------------------------------------------------------------------------
	create table SecurityInheritanceClosure4( [Start] uniqueidentifier not null, [End] uniqueidentifier not null, [Distance] int not null default 0 )
	go

	alter table SecurityInheritanceClosure4 add constraint SecurityInheritanceClosure4_PK primary key([Start],[End])
	go

	insert into SecurityInheritanceClosure4( [Start],[End],[Distance] ) select [Start],[End],[Distance] from SecurityInheritanceClosure
	go
	-------------------------------------------------------------------------------
	-- SecurityInheritanceClosure5 - an exact duplicate of the SecurityInheritanceClosure table
	-------------------------------------------------------------------------------
	create table SecurityInheritanceClosure5( [Start] uniqueidentifier not null, [End] uniqueidentifier not null, [Distance] int not null default 0 )
	go

	alter table SecurityInheritanceClosure5 add constraint SecurityInheritanceClosure5_PK primary key([Start],[End])
	go

	insert into SecurityInheritanceClosure5( [Start],[End],[Distance] ) select [Start],[End],[Distance] from SecurityInheritanceClosure
	go

create trigger SecurityInheritanceClosure_Copy_Insert on SecurityInheritanceClosure after insert as
			insert into SecurityInheritanceClosure2( [Start],[End],[Distance] ) select [Start], [End], [Distance] from inserted
			insert into SecurityInheritanceClosure3( [Start],[End],[Distance] ) select [Start], [End], [Distance] from inserted
			insert into SecurityInheritanceClosure4( [Start],[End],[Distance] ) select [Start], [End], [Distance] from inserted
			insert into SecurityInheritanceClosure5( [Start],[End],[Distance] ) select [Start], [End], [Distance] from inserted
	go
create trigger SecurityInheritanceClosure_Copy_Delete on SecurityInheritanceClosure after delete as
			delete from SecurityInheritanceClosure2 
		from SecurityInheritanceClosure2 c 
		inner join deleted d on c.[Start] = d.[Start] and c.[End] = d.[End]
			delete from SecurityInheritanceClosure3 
		from SecurityInheritanceClosure3 c 
		inner join deleted d on c.[Start] = d.[Start] and c.[End] = d.[End]
			delete from SecurityInheritanceClosure4 
		from SecurityInheritanceClosure4 c 
		inner join deleted d on c.[Start] = d.[Start] and c.[End] = d.[End]
			delete from SecurityInheritanceClosure5 
		from SecurityInheritanceClosure5 c 
		inner join deleted d on c.[Start] = d.[Start] and c.[End] = d.[End]
	go
create trigger SecurityInheritanceClosure_Copy_Update on SecurityInheritanceClosure after update as
			update SecurityInheritanceClosure2 set [Distance] = i.[Distance]
		from SecurityInheritanceClosure2 c 
		inner join inserted i on c.[Start] = i.[Start] and c.[End] = i.[End]
			update SecurityInheritanceClosure3 set [Distance] = i.[Distance]
		from SecurityInheritanceClosure3 c 
		inner join inserted i on c.[Start] = i.[Start] and c.[End] = i.[End]
			update SecurityInheritanceClosure4 set [Distance] = i.[Distance]
		from SecurityInheritanceClosure4 c 
		inner join inserted i on c.[Start] = i.[Start] and c.[End] = i.[End]
			update SecurityInheritanceClosure5 set [Distance] = i.[Distance]
		from SecurityInheritanceClosure5 c 
		inner join inserted i on c.[Start] = i.[Start] and c.[End] = i.[End]
	go

set ansi_padding on
go


create view _Security_Tuple1
with schemabinding
as
	select 
		ih1.[Start] as Id1, 
		t.ObjectId1 as ParentId1,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) as DistancesJoined,
		e.PrivilegeId, m.[Start] as SubjectId,
		count_big(*) as TotalEntries, sum(1-e.Allow) as DeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 0 then 1 else 0 end ) as ExplicitDeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 1 then 1 else 0 end ) as ExplicitAllowedEntries,
		sum( case when m.[End] = m.[Start] then 1 else 0 end ) as NotViaMembership
	from dbo.AclEntries e
	inner join dbo.SecurityTargets t on e.TargetId = t.Id
	inner join dbo.SecurityMembershipClosure m on e.SubjectId = m.[End]
	inner join dbo.SecurityInheritanceClosure ih1 on ih1.[End] = t.ObjectId1
	where t.Arity = 1
	group by 
		ih1.[Start], 
		t.ObjectId1,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ),
		e.PrivilegeId, m.[Start]
go

create unique clustered index _Security_Tuple1_PK on _Security_Tuple1(
	Id1, SubjectId, PrivilegeId,
	DistancesJoined
)
create index _Security_Tuple1_Reverse_IX on _Security_Tuple1(
	SubjectId, PrivilegeId, Id1,
	DistancesJoined, DeniedEntries
)
go

create view Security_Tuple1
as
select 
	Id1, ParentId1,
	SubjectId, PrivilegeId, 1-NotViaMembership as ViaMembership, DeniedEntries, ExplicitDeniedEntries, ExplicitAllowedEntries
from _Security_Tuple1 x with(noexpand)
where x.DistancesJoined = (
	select min(y.DistancesJoined) from _Security_Tuple1 y with(noexpand)
	where x.SubjectId = y.SubjectId and x.PrivilegeId = y.PrivilegeId and x.Id1 = y.Id1
)
go


create view _Security_Tuple2
with schemabinding
as
	select 
		ih1.[Start] as Id1, ih2.[Start] as Id2, 
		t.ObjectId1 as ParentId1, t.ObjectId2 as ParentId2,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) as DistancesJoined,
		e.PrivilegeId, m.[Start] as SubjectId,
		count_big(*) as TotalEntries, sum(1-e.Allow) as DeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 0 then 1 else 0 end ) as ExplicitDeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 1 then 1 else 0 end ) as ExplicitAllowedEntries,
		sum( case when m.[End] = m.[Start] then 1 else 0 end ) as NotViaMembership
	from dbo.AclEntries e
	inner join dbo.SecurityTargets t on e.TargetId = t.Id
	inner join dbo.SecurityMembershipClosure m on e.SubjectId = m.[End]
	inner join dbo.SecurityInheritanceClosure ih1 on ih1.[End] = t.ObjectId1
inner join dbo.SecurityInheritanceClosure2 ih2 on ih2.[End] = t.ObjectId2
	where t.Arity = 2
	group by 
		ih1.[Start], ih2.[Start], 
		t.ObjectId1, t.ObjectId2,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ),
		e.PrivilegeId, m.[Start]
go

create unique clustered index _Security_Tuple2_PK on _Security_Tuple2(
	Id1, Id2, SubjectId, PrivilegeId,
	DistancesJoined
)
create index _Security_Tuple2_Reverse_IX on _Security_Tuple2(
	SubjectId, PrivilegeId, Id1, Id2,
	DistancesJoined, DeniedEntries
)
go

create view Security_Tuple2
as
select 
	Id1, Id2, ParentId1, ParentId2,
	SubjectId, PrivilegeId, 1-NotViaMembership as ViaMembership, DeniedEntries, ExplicitDeniedEntries, ExplicitAllowedEntries
from _Security_Tuple2 x with(noexpand)
where x.DistancesJoined = (
	select min(y.DistancesJoined) from _Security_Tuple2 y with(noexpand)
	where x.SubjectId = y.SubjectId and x.PrivilegeId = y.PrivilegeId and x.Id1 = y.Id1 and x.Id2 = y.Id2
)
go


create view _Security_Tuple3
with schemabinding
as
	select 
		ih1.[Start] as Id1, ih2.[Start] as Id2, ih3.[Start] as Id3, 
		t.ObjectId1 as ParentId1, t.ObjectId2 as ParentId2, t.ObjectId3 as ParentId3,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ) as DistancesJoined,
		e.PrivilegeId, m.[Start] as SubjectId,
		count_big(*) as TotalEntries, sum(1-e.Allow) as DeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 0 then 1 else 0 end ) as ExplicitDeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 1 then 1 else 0 end ) as ExplicitAllowedEntries,
		sum( case when m.[End] = m.[Start] then 1 else 0 end ) as NotViaMembership
	from dbo.AclEntries e
	inner join dbo.SecurityTargets t on e.TargetId = t.Id
	inner join dbo.SecurityMembershipClosure m on e.SubjectId = m.[End]
	inner join dbo.SecurityInheritanceClosure ih1 on ih1.[End] = t.ObjectId1
inner join dbo.SecurityInheritanceClosure2 ih2 on ih2.[End] = t.ObjectId2
inner join dbo.SecurityInheritanceClosure3 ih3 on ih3.[End] = t.ObjectId3
	where t.Arity = 3
	group by 
		ih1.[Start], ih2.[Start], ih3.[Start], 
		t.ObjectId1, t.ObjectId2, t.ObjectId3,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ),
		e.PrivilegeId, m.[Start]
go

create unique clustered index _Security_Tuple3_PK on _Security_Tuple3(
	Id1, Id2, Id3, SubjectId, PrivilegeId,
	DistancesJoined
)
create index _Security_Tuple3_Reverse_IX on _Security_Tuple3(
	SubjectId, PrivilegeId, Id1, Id2, Id3,
	DistancesJoined, DeniedEntries
)
go

create view Security_Tuple3
as
select 
	Id1, Id2, Id3, ParentId1, ParentId2, ParentId3,
	SubjectId, PrivilegeId, 1-NotViaMembership as ViaMembership, DeniedEntries, ExplicitDeniedEntries, ExplicitAllowedEntries
from _Security_Tuple3 x with(noexpand)
where x.DistancesJoined = (
	select min(y.DistancesJoined) from _Security_Tuple3 y with(noexpand)
	where x.SubjectId = y.SubjectId and x.PrivilegeId = y.PrivilegeId and x.Id1 = y.Id1 and x.Id2 = y.Id2 and x.Id3 = y.Id3
)
go


create view _Security_Tuple4
with schemabinding
as
	select 
		ih1.[Start] as Id1, ih2.[Start] as Id2, ih3.[Start] as Id3, ih4.[Start] as Id4, 
		t.ObjectId1 as ParentId1, t.ObjectId2 as ParentId2, t.ObjectId3 as ParentId3, t.ObjectId4 as ParentId4,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih4.Distance, 0 ) ), 5 ) as DistancesJoined,
		e.PrivilegeId, m.[Start] as SubjectId,
		count_big(*) as TotalEntries, sum(1-e.Allow) as DeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 0 then 1 else 0 end ) as ExplicitDeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 1 then 1 else 0 end ) as ExplicitAllowedEntries,
		sum( case when m.[End] = m.[Start] then 1 else 0 end ) as NotViaMembership
	from dbo.AclEntries e
	inner join dbo.SecurityTargets t on e.TargetId = t.Id
	inner join dbo.SecurityMembershipClosure m on e.SubjectId = m.[End]
	inner join dbo.SecurityInheritanceClosure ih1 on ih1.[End] = t.ObjectId1
inner join dbo.SecurityInheritanceClosure2 ih2 on ih2.[End] = t.ObjectId2
inner join dbo.SecurityInheritanceClosure3 ih3 on ih3.[End] = t.ObjectId3
inner join dbo.SecurityInheritanceClosure4 ih4 on ih4.[End] = t.ObjectId4
	where t.Arity = 4
	group by 
		ih1.[Start], ih2.[Start], ih3.[Start], ih4.[Start], 
		t.ObjectId1, t.ObjectId2, t.ObjectId3, t.ObjectId4,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih4.Distance, 0 ) ), 5 ),
		e.PrivilegeId, m.[Start]
go

create unique clustered index _Security_Tuple4_PK on _Security_Tuple4(
	Id1, Id2, Id3, Id4, SubjectId, PrivilegeId,
	DistancesJoined
)
create index _Security_Tuple4_Reverse_IX on _Security_Tuple4(
	SubjectId, PrivilegeId, Id1, Id2, Id3, Id4,
	DistancesJoined, DeniedEntries
)
go

create view Security_Tuple4
as
select 
	Id1, Id2, Id3, Id4, ParentId1, ParentId2, ParentId3, ParentId4,
	SubjectId, PrivilegeId, 1-NotViaMembership as ViaMembership, DeniedEntries, ExplicitDeniedEntries, ExplicitAllowedEntries
from _Security_Tuple4 x with(noexpand)
where x.DistancesJoined = (
	select min(y.DistancesJoined) from _Security_Tuple4 y with(noexpand)
	where x.SubjectId = y.SubjectId and x.PrivilegeId = y.PrivilegeId and x.Id1 = y.Id1 and x.Id2 = y.Id2 and x.Id3 = y.Id3 and x.Id4 = y.Id4
)
go


create view _Security_Tuple5
with schemabinding
as
	select 
		ih1.[Start] as Id1, ih2.[Start] as Id2, ih3.[Start] as Id3, ih4.[Start] as Id4, ih5.[Start] as Id5, 
		t.ObjectId1 as ParentId1, t.ObjectId2 as ParentId2, t.ObjectId3 as ParentId3, t.ObjectId4 as ParentId4, t.ObjectId5 as ParentId5,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih4.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih5.Distance, 0 ) ), 5 ) as DistancesJoined,
		e.PrivilegeId, m.[Start] as SubjectId,
		count_big(*) as TotalEntries, sum(1-e.Allow) as DeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 0 then 1 else 0 end ) as ExplicitDeniedEntries,
		sum( case when m.[End] = m.[Start] and e.Allow = 1 then 1 else 0 end ) as ExplicitAllowedEntries,
		sum( case when m.[End] = m.[Start] then 1 else 0 end ) as NotViaMembership
	from dbo.AclEntries e
	inner join dbo.SecurityTargets t on e.TargetId = t.Id
	inner join dbo.SecurityMembershipClosure m on e.SubjectId = m.[End]
	inner join dbo.SecurityInheritanceClosure ih1 on ih1.[End] = t.ObjectId1
inner join dbo.SecurityInheritanceClosure2 ih2 on ih2.[End] = t.ObjectId2
inner join dbo.SecurityInheritanceClosure3 ih3 on ih3.[End] = t.ObjectId3
inner join dbo.SecurityInheritanceClosure4 ih4 on ih4.[End] = t.ObjectId4
inner join dbo.SecurityInheritanceClosure5 ih5 on ih5.[End] = t.ObjectId5
	where t.Arity = 5
	group by 
		ih1.[Start], ih2.[Start], ih3.[Start], ih4.[Start], ih5.[Start], 
		t.ObjectId1, t.ObjectId2, t.ObjectId3, t.ObjectId4, t.ObjectId5,
		right( '00000' + convert( nvarchar(5), isnull( ih1.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih2.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih3.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih4.Distance, 0 ) ), 5 ) + right( '00000' + convert( nvarchar(5), isnull( ih5.Distance, 0 ) ), 5 ),
		e.PrivilegeId, m.[Start]
go

create unique clustered index _Security_Tuple5_PK on _Security_Tuple5(
	Id1, Id2, Id3, Id4, Id5, SubjectId, PrivilegeId,
	DistancesJoined
)
create index _Security_Tuple5_Reverse_IX on _Security_Tuple5(
	SubjectId, PrivilegeId, Id1, Id2, Id3, Id4, Id5,
	DistancesJoined, DeniedEntries
)
go

create view Security_Tuple5
as
select 
	Id1, Id2, Id3, Id4, Id5, ParentId1, ParentId2, ParentId3, ParentId4, ParentId5,
	SubjectId, PrivilegeId, 1-NotViaMembership as ViaMembership, DeniedEntries, ExplicitDeniedEntries, ExplicitAllowedEntries
from _Security_Tuple5 x with(noexpand)
where x.DistancesJoined = (
	select min(y.DistancesJoined) from _Security_Tuple5 y with(noexpand)
	where x.SubjectId = y.SubjectId and x.PrivilegeId = y.PrivilegeId and x.Id1 = y.Id1 and x.Id2 = y.Id2 and x.Id3 = y.Id3 and x.Id4 = y.Id4 and x.Id5 = y.Id5
)
go


create trigger SecurityTargets_MakeSureObjectsExist on SecurityTargets after insert, update
as
	declare @empty uniqueidentifier
	set @empty = '00000000-0000-0000-0000-000000000000'

			insert into SecurityInheritance(Start,[End]) 
		select distinct ObjectId1, ObjectId1 from inserted 
		left join SecurityInheritance ih on [Start] = ObjectId1 and [End] = ObjectId1
		where ih.[Start] is null and ObjectId1 <> @empty
			insert into SecurityInheritance(Start,[End]) 
		select distinct ObjectId2, ObjectId2 from inserted 
		left join SecurityInheritance ih on [Start] = ObjectId2 and [End] = ObjectId2
		where ih.[Start] is null and ObjectId2 <> @empty
			insert into SecurityInheritance(Start,[End]) 
		select distinct ObjectId3, ObjectId3 from inserted 
		left join SecurityInheritance ih on [Start] = ObjectId3 and [End] = ObjectId3
		where ih.[Start] is null and ObjectId3 <> @empty
			insert into SecurityInheritance(Start,[End]) 
		select distinct ObjectId4, ObjectId4 from inserted 
		left join SecurityInheritance ih on [Start] = ObjectId4 and [End] = ObjectId4
		where ih.[Start] is null and ObjectId4 <> @empty
			insert into SecurityInheritance(Start,[End]) 
		select distinct ObjectId5, ObjectId5 from inserted 
		left join SecurityInheritance ih on [Start] = ObjectId5 and [End] = ObjectId5
		where ih.[Start] is null and ObjectId5 <> @empty
	go