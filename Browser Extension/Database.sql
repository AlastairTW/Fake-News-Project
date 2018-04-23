CREATE DATABASE FakeNewsExtension;

USE FakeNewsExtension;

CREATE TABLE Voting (
URL varchar(999) NOT NULL, 
False_Info int DEFAULT 0, 
True_Info int DEFAULT 0, 




CONSTRAINT
PK_URL PRIMARY KEY
(URL)
);