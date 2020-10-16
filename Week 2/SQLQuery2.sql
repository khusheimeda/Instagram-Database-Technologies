USE [InstagramDB]
GO

set statistics time, io on
go

DBCC DROPCLEANBUFFERS
go

DBCC FREEPROCCACHE
go


sp_helpindex Users
go

sp_helpindex Posts
go

--not in
--find the userid of users who haven't posted anything on their profile yet
--should be getting 217,962 rows (233690-15728)
--select count(userId) from users;	--233690
--select count(postUserId) from posts;	--15728

select userId from USERS where USERS.userId not in (select postUserId from POSTS)
go

select userId from Users
except
select postUserId from POSTS
go

select userId from USERS left outer join POSTS on POSTS.postUserId=USERS.userId where POSTS.postUserId is NULL
go

--update before performing union
update posts set likes = 100 where postUserId between 40000 and 50000
update posts set likes = 200 where postUserId between 1000 and 2000
update posts set caption='I am a caption' where postUserId between 10000 and 20000

--union
--get the privacy level, caption and number of likes of users whose userId lies between 5000 and 800000 and postId lies between 7000 and 10000 in the descending order of number of likes
select U.privacyLevel, P.caption, P.likes
from USERS U, POSTS P 
where U.userId=P.postUserId and U.userId between 5000 and 800000 and P.postId between 7000 and 10000
group by U.privacyLevel, P.caption, P.likes
order by P.likes desc
go

select U.privacyLevel, P.caption, P.likes
from USERS U, POSTS P 
where U.userId=P.postUserId and U.userId between 5000 and 800000 and P.postId between 7000 and 8000
group by U.privacyLevel, P.caption, P.likes
UNION
select U.privacyLevel, P.caption, P.likes
from USERS U, POSTS P 
where U.userId=P.postUserId and U.userId between 5000 and 800000 and P.postId between 8000 and 10000
group by U.privacyLevel, P.caption, P.likes
order by P.likes desc
go

select T.privacyLevel, T.caption, T.likes
from
(
select U.userId, U.privacyLevel, P.caption, P.likes
from USERS U, POSTS P 
where U.userId=P.postUserId and P.postId between 7000 and 8000
group by U.userId, U.privacyLevel, P.caption, P.likes
UNION
select U.userId, U.privacyLevel, P.caption, P.likes
from USERS U, POSTS P 
where U.userId=P.postUserId and P.postId between 8000 and 10000
group by U.userId, U.privacyLevel, P.caption, P.likes
) T
where T.userId between 5000 and 800000
group by T.privacyLevel, T.caption, T.likes
order by T.likes desc
go

--create and populate two new tables for join
CREATE TABLE TAGGED (
  postId		INT			NOT NULL,
  taggedUserId	INT			NOT NULL,
  PRIMARY KEY(taggedUserId, postId),
  FOREIGN KEY(postId) REFERENCES POSTS(postId),
  FOREIGN KEY(taggedUserId) REFERENCES USERS(userId)
  ON DELETE CASCADE	ON UPDATE CASCADE
  ) on FG1;

CREATE TABLE POSTS_PICTURE (
  postId		INT			NOT NULL,
  pictureId		INT			NOT NULL,
  PRIMARY KEY(postId, pictureId),
  FOREIGN KEY(postId) REFERENCES POSTS(postId) 
  ON DELETE CASCADE		ON UPDATE CASCADE
  ) on FG1;

set nocount on

select @@TRANCOUNT

begin transaction T1

declare @i int,
		@pi int,
		@tui int

set @i = 600000
while @i <= 1000000
begin

   select @i = RAND()*100000
	set @tui = (select top 1 userId from Users order by newid())
	set @pi = (select top 1 postId from Posts order by newid())
   insert into TAGGED(postId, taggedUserId)
   select @pi, @tui

   set @i = @i + 1
end
go

select * from tagged;

commit transaction T1

set nocount off

set nocount on

select @@TRANCOUNT

begin transaction T1

declare @i int,
		@pi int

set @i = 1
while @i <= 1000000
begin

   select @i = RAND()*100000
	set @pi = (select top 1 postId from Posts order by newid())
   insert into posts_picture (postId, pictureId)
   select @pi, @i

   set @i = @i + 1
end
go

select * from POSTS_PICTURE;
commit transaction T1

set nocount off

--join
select U.username, P.likes, PP.pictureId, T.postId, T.taggedUserId
from USERS U, POSTS P, POSTS_PICTURE PP, TAGGED T
where U.userId between 5000 and 800000 and
	  U.userId = P.postUserId and
	  P.postId = PP.postId and
	  P.postId = T.postId
order by 2 desc
go

select U.username, P.likes, PP.pictureId, T.postId, T.taggedUserId
from USERS U, POSTS P, POSTS_PICTURE PP, TAGGED T
where 
	  U.userId = P.postUserId and
	  P.postId = PP.postId and
	  PP.postId > 20000 and
	  P.postId = T.postId 
order by 2 desc
go

select U.username, P.likes, PP.pictureId, T.postId, T.taggedUserId
from USERS U, POSTS P, POSTS_PICTURE PP, TAGGED T
where 
	  U.userId = P.postUserId and
	  P.caption='I am a caption' and 
	  P.postId = PP.postId and
	  P.postId = T.postId 
order by 2 desc
go

create index Posts_caption_idx on Posts(caption) on FG2;
drop index Posts_caption_idx on Posts