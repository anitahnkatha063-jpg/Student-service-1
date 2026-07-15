

CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO
CREATE TABLE Members (
    MemberID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE
    
);

INSERT INTO Members (MemberID, Name, Email) VALUES
(1, 'Alice', 'alice@mail.com'),
(2, 'Bob', 'bob@mail.com'),
(3, 'Eve', 'eve@mail.com'),
(4, 'Cain', 'cain@mail.com'),
(5, 'Albert', 'albert@mail.com');


CREATE TABLE Books (
    ISBN VARCHAR(20) PRIMARY KEY,
    Title VARCHAR(20) NOT NULL,
    Author VARCHAR(50) NOT NULL
);

INSERT INTO Books (ISBN, Title, Author) VALUES
('123648', 'Networking', 'White Black'),
('306090', 'Distributed Systems', 'Wright Left'),
('202040', 'Internet Security', 'Cain Tech'),
('305544', 'Data Principles', 'Eve Rose');

CREATE TABLE Borrowing (
BorrowID VARCHAR(10) PRIMARY KEY,
MemberID INT ,
ISBN VARCHAR (20),
BorrowDate DATE, 
ReturnDate DATE,
CONSTRAINT FK_Borrowing_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    CONSTRAINT FK_Borrowing_Books FOREIGN KEY (ISBN) REFERENCES Books(ISBN),
);
Go

INSERT INTO Borrowing (BorrowID ,MemberID ,ISBN ,BorrowDate,ReturnDate) VALUES 
('B001','1', '123648', '04-05-2026', '14-05-2026'),
    ('B002','7', '6692200', '29-04-2026', '12-05-2026'),
    ('B003','2', '202040',  '05-05-2026', '21-05-2026')
    ('B004','9', '101010', '07-05-2026' '26-05-2026';
GO

DELETE FROM Borrowing WHERE BorrowID ='B004';
GO

ALTER TABLE Members ADD Passward VARCHAR(255);

UPDATE Members SETEmail = 'alice2026@mail.com'WHERE MemberID =1;

DELETE FROM Books WHERE Title ='Distributed Systems';

SELECT m.Name, b.Title, br.MembersID,br.ISBN
FROM Borrowing br
INNER JOIN Members m ON br.MembersID =m.MembersID
INNER JOIN Books b ON br.ISBN = b.ISBN;
 
 CREATE VIEW BorrowedBooksView AS 
 SELECT br. BorrowedID,m.Name,b.Title,br.BorrowedDate,br.ReturnDate
 FROM Borrowing br 
 INNER JOIN Members m ON br. MemberID = m.MemberID
 INNER JOIN Books b ON br.ISBN = b.ISBN;
 
 CREATE TRIGGER PreventDeleteMember
 BEFORE DELETE ON Members 
 FOR EACH ROW 
 BEGIN 
   SIGNAL SQLSTATE'45000'
   SET MESSAGE_TEXT ='Deletions from the Membaers table are not allowed.';
   UPDATE Members SET Passward = SHA2('passward123',256)WHERE MembersID =1;
    UPDATE Members SET Passward = SHA2('secureBob45',256)WHERE MembersID =2;
     UPDATE Members SET Passward = SHA2('evePass89!',256)WHERE MembersID =3;
      UPDATE Members SET Passward = SHA2('cainPass77',256)WHERE MembersID =4;
       UPDATE Members SET Passward = SHA2('albertSecret',256)WHERE MembersID =5;
  
