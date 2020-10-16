CREATE DATABASE [InstagramDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InstagramDB', FILENAME = N'C:\Users\KR\Instagram_Disks\disk1\InstagramDB.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'InstagramDB_log', FILENAME = N'C:\Users\KR\Instagram_Disks\disk2\InstagramDB_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [InstagramDB] SET COMPATIBILITY_LEVEL = 140
GO
ALTER DATABASE [InstagramDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InstagramDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InstagramDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InstagramDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InstagramDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [InstagramDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [InstagramDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InstagramDB] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [InstagramDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InstagramDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InstagramDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InstagramDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InstagramDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InstagramDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InstagramDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InstagramDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [InstagramDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InstagramDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InstagramDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InstagramDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InstagramDB] SET  READ_WRITE 
GO
ALTER DATABASE [InstagramDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [InstagramDB] SET  MULTI_USER 
GO
ALTER DATABASE [InstagramDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InstagramDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [InstagramDB] SET DELAYED_DURABILITY = DISABLED 
GO
USE [InstagramDB]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = On;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary;
GO
USE [InstagramDB]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [InstagramDB] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO

USE [master]
GO
ALTER DATABASE [InstagramDB] ADD FILEGROUP [FG1]
GO
ALTER DATABASE [InstagramDB] ADD FILEGROUP [FG2]
GO

USE [master]
GO
ALTER DATABASE [InstagramDB] ADD FILE ( NAME = N'F1', FILENAME = N'C:\Users\KR\Instagram_Disks\disk1\F1.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [FG1]
GO
ALTER DATABASE [InstagramDB] ADD FILE ( NAME = N'F2', FILENAME = N'C:\Users\KR\Instagram_Disks\disk1\F2.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [FG2]
GO

USE [InstagramDB]
GO

CREATE TABLE USERS( 
  userId		INT			NOT NULL	PRIMARY KEY,
  username		VARCHAR(15)	NOT NULL	UNIQUE,
  firstName		VARCHAR(15)	NOT NULL,
  lastName		VARCHAR(15)	NOT NULL,
  email			VARCHAR(50)	NOT NULL	
	CONSTRAINT email_format
	CHECK (email like '%_@__%.__%'),
  bio			VARCHAR(15),
  password		VARCHAR(15)	NOT NULL,
  privacyLevel	BIT			NOT NULL)
  ON FG1;

alter table Users drop constraint UQ__USERS__F3DBC572C5528587

create PARTITION FUNCTION UsersRangePF1 (int)  
    AS RANGE LEFT FOR VALUES (150000) ;  
GO  

create PARTITION SCHEME UsersRangePS1  
    AS PARTITION UsersRangePF1  
    TO (FG1, FG2) ;  
GO  

alter table users drop constraint email_format

CREATE TABLE UsersPartitionTable (userId		INT			NOT NULL	PRIMARY KEY,
  username		VARCHAR(15)	NOT NULL,
  firstName		VARCHAR(15)	NOT NULL,
  lastName		VARCHAR(15)	NOT NULL,
  email			VARCHAR(50)	NOT NULL,
  bio			VARCHAR(15),
  password		VARCHAR(15)	NOT NULL,
  privacyLevel	BIT			NOT NULL) 
  ON UsersRangePS1 (userId) 
GO  

select count(userId) from Users;
select count(userId) from UsersPartitionTable	--getting 0

create index Users_username_idx on Users(username) ON FG2;

set nocount on

select @@TRANCOUNT

begin transaction T1

declare @i int,
		@n int,
        @c varchar(15)

set @i = 1
while @i <= 1000000
begin

   select @i = RAND()*100000,
		  @c = convert(varchar, @i)

   insert into Users (userId, username, firstName, lastName, email, bio, password, privacyLevel)
   select @i, @c + 'ABC', 'FN', 'LN', 'fnln@gmail.com', 'Hi', 'password', 1

   set @i = @i + 1
end
go

commit transaction T1

set nocount off

sp_helpindex Users

dbcc checktable (Users)

dbcc showcontig(Users)

DBCC INDEXDEFRAG(InstagramDB,users)

update Users set bio = 'Hey there!' 
where userId between 200000 and 300000


delete from Users where userId between 30000 and 40000
delete from Users where userId between 100000 and 220000
delete from Users where userId between 2800000 and 320000
delete from Users where userId between 600000 and 750000

dbcc showcontig(Users)

DBCC INDEXDEFRAG(InstagramDB,Users)

dbcc checktable(Users)

select Db_name (database_id), * from sys.dm_os_buffer_descriptors 
order by 1, file_id, page_id

select Db_name (database_id), * from sys.dm_os_buffer_descriptors 
where Db_name (database_id) = 'InstagramDB'
order by 1, file_id, page_id


--to see the number of rows in each partition
SELECT $PARTITION.UsersRangePF1(userId), COUNT(*) FROM Users GROUP BY $PARTITION.UsersRangePF1(userId);
GO


CREATE TABLE POSTS (
  postId		INT			NOT NULL,
  postUserId	INT			NOT NULL,
  caption		VARCHAR(100),
  latitude		INT		CHECK(latitude>-90 AND latitude<90),
  longitude		INT		CHECK(longitude>-180 AND longitude<180),
  timePost		TIMESTAMP		NOT NULL,
  disableComments	BIT		NOT NULL		DEFAULT 0,
  likes			INT			DEFAULT 0,
  comments		INT			DEFAULT 0,
  PRIMARY KEY(postId),
  FOREIGN KEY(postUserId) REFERENCES USERS(userId) 
  ON DELETE	CASCADE		ON UPDATE CASCADE
  ) on FG1;

  create PARTITION FUNCTION PostsRangePF1 (int)  
    AS RANGE LEFT FOR VALUES (150000) ;  
GO  

create PARTITION SCHEME PostsRangePS1  
    AS PARTITION PostsRangePF1  
    TO (FG1, FG2) ;  
GO  

CREATE TABLE PostsPartitionTable (
  postId		INT			NOT NULL,
  postUserId	INT			NOT NULL,
  caption		VARCHAR(100),
  latitude		INT		CHECK(latitude>-90 AND latitude<90),
  longitude		INT		CHECK(longitude>-180 AND longitude<180),
  timePost		TIMESTAMP		NOT NULL,
  disableComments	BIT		NOT NULL		DEFAULT 0,
  likes			INT			DEFAULT 0,
  comments		INT			DEFAULT 0,
  PRIMARY KEY(postId),
  FOREIGN KEY(postUserId) REFERENCES USERS(userId) 
  ON DELETE	CASCADE		ON UPDATE CASCADE
  ) ON PostsRangePS1 (postId) 
GO 

set nocount on

select @@TRANCOUNT

begin transaction T1

declare @i int,
		@pui int

set @i = 500000
while @i <= 1000000
begin

   select @i = RAND()*100000
	set @pui = (select top 1 userId from Users order by newid())
   insert into posts (postId, postUserId, caption, latitude, longitude)
   select @i, @pui, 'Caption', 45, 45

   set @i = @i + 1
end
go

select count(postId) from posts
select count(userId) from users

commit transaction T1

set nocount off

sp_helpindex Posts

dbcc checktable (Posts)

dbcc showcontig(Posts)

DBCC INDEXDEFRAG(InstagramDB,Posts)











update posts set likes = 10 where postId = 71632
update posts set likes = 100 where postId = 41084
update posts set likes = 50 where postId = 233829
update posts set likes = 250 where postId = 932938
update posts set likes = 50 where postId = 367395
update posts set likes = 50 where postId = 410535
update posts set likes = 10 where postId = 777810


set statistics time on;
go

dbcc dropcleanbuffers
go
--correlated query
--To find the user whose post has the maximum number of likes.
    SELECT username 
    FROM USERS 
    WHERE userId IN (SELECT postUserId 
                    FROM POSTS 
                    WHERE likes = (SELECT MAX(likes) 
                                    FROM POSTS))
	GO

sp_helpindex Posts
create index Posts_likes_idx on Posts(likes) on FG2

dbcc dropcleanbuffers
go

--aggregate query with equi-join condition
--To find the total number of posts on a user's profile.
    SELECT username, 
    (SELECT COUNT(*) as NumberOfPosts FROM POSTS WHERE postUserId = USERS.userId) 
    FROM USERS
	GO
drop index Users_username_idx on Users
create index Users_username_idx on Users(username) ON FG2;

dbcc dropcleanbuffers
go

--update query
	update posts set caption='I am a caption' where postId between 10 and 100
	update Users set privacyLevel=0 where userId > 100000

--group by
SELECT count(postId)
FROM posts
GROUP BY caption;

create index Posts_caption_idx on Posts(caption)
drop index Posts_caption_idx on Posts

dbcc dropcleanbuffers
go

--for composite index
select userId from USERS where password='password' and privacyLevel=1

create index Users_composite_idx on Users(password, privacyLevel)
drop index Users_composite_idx on Users

dbcc dropcleanbuffers
go

