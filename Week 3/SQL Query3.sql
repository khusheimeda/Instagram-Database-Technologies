SELECT * FROM OPENQUERY(POSTGRESQL, 'SELECT * FROM likes')

USE [InstagramDB]
GO

set statistics time, io on
go

DBCC DROPCLEANBUFFERS
go

DBCC FREEPROCCACHE
go

--table POSTS is in InstagramDB in MSSQL
select * from POSTS;

--join of one MSSQL table with a table from Postgresql
select P.postUserId,
       P.caption,
	   P.likes,
	   L.likedUserId
from POSTS P,
     (select * from openquery(POSTGRESQL, 'SELECT * FROM likes')) L
where P.postId = L.postId;


select P.postUserId,
       P.caption,
	   P.likes,
	   L.postId
from POSTS P,
     (select * from openquery(POSTGRESQL, 'SELECT * FROM likes')) L
where P.postId = L.postId;
