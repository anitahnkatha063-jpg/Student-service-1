CREATE DATABASE StudentServicesDB;
GO

USE StudentServicesDB;
GO


--  CREATE LOGINS (Server-Level)

CREATE LOGIN AdminLogin WITH PASSWORD = 'AdminPass123!', CHECK_POLICY = OFF;
CREATE LOGIN FacultyLogin WITH PASSWORD = 'FacultyPass123!', CHECK_POLICY = OFF;
CREATE LOGIN StudentLogin WITH PASSWORD = 'StudentPass123!', CHECK_POLICY = OFF;
GO


--  CREATE USERS (Database-Level)

CREATE USER AdminUser FOR LOGIN AdminLogin;
CREATE USER FacultyUser FOR LOGIN FacultyLogin;
CREATE USER StudentUser FOR LOGIN StudentLogin;
GO


--  CREATE SYSTEM ROLES (If not already done)

-- Note: db_owner gives the Admin full control over everything
ALTER ROLE db_owner ADD MEMBER AdminUser; 

-- Faculty & Student roles for specific permissions
CREATE ROLE FacultyRole;
CREATE ROLE StudentRole;
GO


--  ASSIGN USERS TO THE ROLES 

ALTER ROLE FacultyRole ADD MEMBER FacultyUser;
ALTER ROLE StudentRole ADD MEMBER StudentUser;
GO












-- Creating the Departments table
CREATE TABLE Departments(
    DeptID INT IDENTITY(1,1) PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL,
    Location VARCHAR(50) NOT NULL, -- E.g., 'Block A'
    HOD VARCHAR(100) NOT NULl
);
GO

--  Insert  sample records
INSERT INTO Departments (DeptName, Location, HOD) VALUES 
('Computing and Informatics', 'Block A', 'Mr. John Mutua'),
('Mechanical Engineering', 'Block B', 'Eng. Sarah Wangari'),
('Electrical Engineering', 'Block B', 'Dr. Kevin Kamau'),
('Business Studies', 'Block C', 'Mrs. Faith Ndwiga'),
('Hospitality Management', 'Block D', 'Chef Alice Omwamba');
GO





---TASK 4
-- 1. Courses Table
CREATE TABLE Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseName VARCHAR(150) NOT NULL,
    CourseType VARCHAR(20) CHECK (CourseType IN ('Diploma', 'Certificate', 'Artisan')),
    DeptID INT FOREIGN KEY REFERENCES Departments(DeptID)
);

-- 2. Classes Table
CREATE TABLE Classes (
    ClassID INT IDENTITY(1,1) PRIMARY KEY,
    ClassName VARCHAR(50) NOT NULL,
    CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
    IntakeYear INT NOT NULL
);

-- 3. Students Table (with specialized uniqueness and gender checks)
CREATE TABLE Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(150) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')), -- iii) Check Constraint
    Address VARCHAR(250),
    ClassID INT FOREIGN KEY REFERENCES Classes(ClassID),
    EnrollmentStatus VARCHAR(20) CHECK (EnrollmentStatus IN ('in session', 'on attachment', 'completed')),
    FeeBalance DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT UQ_Student_Name_DOB UNIQUE (FullName, DOB) -- v) Unique Constraint
);

-- 4. Subjects Table
CREATE TABLE Subjects (
    SubjectCode VARCHAR(20) PRIMARY KEY, -- Includes module code mapping
    SubjectName VARCHAR(100) NOT NULL,
    WeeklyHours INT CHECK (WeeklyHours BETWEEN 2 AND 6),
    CourseID INT FOREIGN KEY REFERENCES Courses(CourseID)
);

-- 5. Lecturers Table
CREATE TABLE Lecturers (
    LecturerID INT IDENTITY(1,1) PRIMARY KEY,
    LecturerName VARCHAR(150) NOT NULL,
    Specialty VARCHAR(100),
    HasExtraRoles BIT DEFAULT 0, -- 1 if HOD or Class Teacher
    AllocatedHours INT DEFAULT 40
);

-- 6. Workload Allocation Table
CREATE TABLE WorkloadAllocations (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    LecturerID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    SubjectCode VARCHAR(20) FOREIGN KEY REFERENCES Subjects(SubjectCode),
    ClassID INT FOREIGN KEY REFERENCES Classes(ClassID),
    Term INT NOT NULL,
    Year INT NOT NULL
);

-- 7. Assessments Table
CREATE TABLE Assessments (
    AssessmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    SubjectCode VARCHAR(20) FOREIGN KEY REFERENCES Subjects(SubjectCode),
    Term INT NOT NULL,
    Year INT NOT NULL,
    CAT1 INT CHECK (CAT1 BETWEEN 0 AND 20), -- iv) Check Constraint
    CAT2 INT CHECK (CAT2 BETWEEN 0 AND 20), -- iv) Check Constraint
    ExamScore INT CHECK (ExamScore BETWEEN 0 AND 60), -- iv) Check Constraint
    AttendancePercentage INT CHECK (AttendancePercentage BETWEEN 0 AND 100),
    IsSupplementary BIT DEFAULT 0
);

-- 8. Hostels & Allocations
CREATE TABLE Hostels (
    HostelID INT IDENTITY(1,1) PRIMARY KEY,
    HostelName VARCHAR(50) NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL
);

CREATE TABLE HostelAllocations (
    AllocationID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    HostelID INT FOREIGN KEY REFERENCES Hostels(HostelID),
    Term INT NOT NULL,
    Year INT NOT NULL,
    PaymentConfirmed BIT DEFAULT 0
);

-- 9. Clubs & Memberships
CREATE TABLE Clubs (
    ClubID INT IDENTITY(1,1) PRIMARY KEY,
    ClubName VARCHAR(100) NOT NULL,
    PatronID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    ChairpersonID INT FOREIGN KEY REFERENCES Students(StudentID),
    LastActiveYear INT NOT NULL
);

CREATE TABLE ClubMemberships (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    ClubID INT FOREIGN KEY REFERENCES Clubs(ClubID),
    YearJoined INT NOT NULL
);

-- 10. Industry Attachments Table
CREATE TABLE Attachments (
    AttachmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    FirmName VARCHAR(150) NOT NULL,
    PeriodWeeks INT NOT NULL,
    Term INT NOT NULL,
    Year INT NOT NULL,
    CompletionStatus VARCHAR(20) CHECK (CompletionStatus IN ('Ongoing', 'Completed', 'Failed'))
);
GO



-- i) Add Column
ALTER TABLE Students ADD DirectContact VARCHAR(15);
GO

-- ii) Change Data Type of non-referenced column
ALTER TABLE Hostels ALTER COLUMN RoomNumber VARCHAR(20) NOT NULL;
GO

-- iii) Export/Drop/Recreate Demonstration Sequence
-- 1. Backup table logic structure into temporary storage
SELECT * INTO #TempHostelsBackup FROM Hostels;

-- 2. Drop table
DROP TABLE HostelAllocations; -- Dropping reference first to avoid dependency failures
DROP TABLE Hostels;

-- 3. Recreate and repopulate
CREATE TABLE Hostels (
    HostelID INT IDENTITY(1,1) PRIMARY KEY,
    HostelName VARCHAR(50) NOT NULL,
    RoomNumber VARCHAR(20) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL
);
-- (Recreate HostelAllocations setup here as well)
GO






--TASK 5 a
-- Seeding Master Courses & Classes data
INSERT INTO Courses VALUES ('Computer Science', 'Diploma', 1), ('Electrical Eng', 'Certificate', 3);
INSERT INTO Classes VALUES ('CS-2025-A', 1, 2025), ('EE-2026-B', 2, 2026);

-- Seeding exactly 10 multi-context records into Students table
INSERT INTO Students (FullName, DOB, Gender, Address, ClassID, EnrollmentStatus, FeeBalance) VALUES
('Alex Kiprop', '2002-05-12', 'M', 'Nairobi', 1, 'in session', 12000.00),
('Beatrice Wanjiku', '2003-08-22', 'F', 'Thika', 1, 'in session', 0.00),
('Charles Njoroge', '2001-02-14', 'M', 'Kiambu', 1, 'on attachment', 4500.00),
('Dorcas Chebet', '2004-11-30', 'F', 'Kericho', 2, 'in session', 15000.00),
('Evans Omwamba', '2000-07-19', 'M', 'Kisii', 1, 'completed', 0.00),
('Faith Mutheu', '2003-04-05', 'F', 'Machakos', 2, 'on attachment', 0.00),
('Gideon Bilal', '2002-12-25', 'M', 'Mombasa', 1, 'in session', 8500.00),
('Hannah Nyambura', '2001-10-10', 'F', 'Nakuru', 2, 'in session', 22000.00),
('Ian Kamau', '2003-01-01', 'M', 'Nyeri', 1, 'in session', 0.00),
('Joy Nafula', '2002-09-15', 'F', 'Bungoma', 2, 'completed', 0.00);

-- Seeding remaining accessory structural arrays
INSERT INTO Subjects VALUES ('CS-MOD1-01', 'Database Systems', 4, 1), ('EE-MOD1-02', 'Basic Electronics', 3, 2);
INSERT INTO Lecturers VALUES ('Dr. Alan Turing', 'Data Science', 0, 40), ('Prof. Maxwell', 'Circuits', 1, 30);
INSERT INTO Hostels VALUES ('Kilimanjaro', 'Room 101', 5000), ('Ruwenzori', 'Room 202', 6000);
INSERT INTO HostelAllocations VALUES (1, 1, 1, 2026), (2, 1, 2, 2026);
INSERT INTO Clubs VALUES ('Coding Club', 1, 1, 2026), ('Drama Club', 2, 4, 2022); -- Drama inactive since 2022
INSERT INTO ClubMemberships VALUES (1, 1, 2025), (2, 1, 2026);
INSERT INTO Attachments VALUES (3, 'Safacom PLC', 12, 1, 2026, 'Ongoing'), (6, 'KPLC Ltd', 12, 1, 2026, 'Completed');
INSERT INTO Assessments VALUES (1, 'CS-MOD1-01', 1, 2026, 18, 17, 52, 85, 0), (2, 'CS-MOD1-01', 1, 2026, 12, 10, 35, 90, 0);
GO

--task 5 b
-- i) Students whose names start with a specified letter ('A')
SELECT * FROM Students WHERE FullName LIKE 'A%';

-- ii) Departments located in a given block
SELECT * FROM Departments WHERE Location = 'Block B';

-- iii) Students in a specified class (ClassID = 1)
SELECT * FROM Students WHERE ClassID = 1;

-- iv) Clubs with no members
SELECT c.ClubName FROM Clubs c 
LEFT JOIN ClubMemberships m ON c.ClubID = m.ClubID 
WHERE m.MembershipID IS NULL;


--task 5 c
-- i) Update a user's contact details
UPDATE Students SET Address = 'Kitengela Residence' WHERE StudentID = 1;

-- ii) Update a student's enrollment status
UPDATE Students SET EnrollmentStatus = 'on attachment' WHERE StudentID = 1;

-- iii) Change a club's chairperson
UPDATE Clubs SET ChairpersonID = 2 WHERE ClubID = 1;

-- iv) Deregister clubs with no members for 3 consecutive years (Relative to 2026 system timeline context)
DELETE FROM Clubs WHERE LastActiveYear <= 2023;

 --task 5 d
 -- i) Lecturers and the subjects they teach
SELECT l.LecturerName, s.SubjectName 
FROM WorkloadAllocations wa
JOIN Lecturers l ON wa.LecturerID = l.LecturerID
JOIN Subjects s ON wa.SubjectCode = s.SubjectCode;

-- ii) Clubs with their patrons and chairpersons
SELECT c.ClubName, l.LecturerName AS Patron, s.FullName AS Chairperson 
FROM Clubs c
JOIN Lecturers l ON c.PatronID = l.LecturerID
JOIN Students s ON c.ChairpersonID = s.StudentID;

-- iii) Students in a specific class with their hostel details
SELECT s.FullName, h.HostelName, h.RoomNumber 
FROM Students s
JOIN HostelAllocations ha ON s.StudentID = ha.StudentID
JOIN Hostels h ON ha.HostelID = h.HostelID
WHERE s.ClassID = 1;

-- iv) Students attached in the same firm for a specified attachment period
SELECT FirmName, COUNT(StudentID) AS StudentCount 
FROM Attachments 
WHERE PeriodWeeks = 12 
GROUP BY FirmName;


--task5 e
-- i) Total number of students per course
SELECT co.CourseName, COUNT(s.StudentID) AS TotalStudents 
FROM Students s
JOIN Classes cl ON s.ClassID = cl.ClassID
JOIN Courses co ON cl.CourseID = co.CourseID
GROUP BY co.CourseName;

-- ii) Average grades per department in a given term and year
SELECT d.DeptName, AVG(a.CAT1 + a.CAT2 + a.ExamScore) AS AverageMark
FROM Assessments a
JOIN Subjects s ON a.SubjectCode = s.SubjectCode
JOIN Courses c ON s.CourseID = c.CourseID
JOIN Departments d ON c.DeptID = d.DeptID
WHERE a.Term = 1 AND a.Year = 2026
GROUP BY d.DeptName;

-- iii) Determine membership per club per year
SELECT ClubID, YearJoined, COUNT(StudentID) AS TotalMembers 
FROM ClubMemberships 
GROUP BY ClubID, YearJoined;

-- iv) Total marks per subject for a given student in a given term and year
SELECT SubjectCode, (CAT1 + CAT2 + ExamScore) AS TotalMarks 
FROM Assessments 
WHERE StudentID = 1 AND Term = 1 AND Year = 2026;

-- v) List students currently on attachment or internship per department
SELECT d.DeptName, s.FullName 
FROM Students s
JOIN Classes cl ON s.ClassID = cl.ClassID
JOIN Courses co ON cl.CourseID = co.CourseID
JOIN Departments d ON co.DeptID = d.DeptID
WHERE s.EnrollmentStatus = 'on attachment';

-- vi) Summarize attachment completion rates per course
SELECT co.CourseName, 
       SUM(CASE WHEN att.CompletionStatus = 'Completed' THEN 1 ELSE 0 END) * 100 / COUNT(att.AttachmentID) AS CompletionRate
FROM Attachments att
JOIN Students s ON att.StudentID = s.StudentID
JOIN Classes cl ON s.ClassID = cl.ClassID
JOIN Courses co ON cl.CourseID = co.CourseID
GROUP BY co.CourseName;

-- vii) Calculate hostel occupancy rates by term
SELECT Term, Year, COUNT(DISTINCT StudentID) AS TotalOccupants FROM HostelAllocations GROUP BY Term, Year;

-- viii) Analyze club participation trends over multiple years
SELECT YearJoined, COUNT(StudentID) AS JoinedCount FROM ClubMemberships GROUP BY YearJoined;

-- ix) Summarize lecturer workload (number of hours taught per term)
SELECT wa.LecturerID, l.LecturerName, SUM(s.WeeklyHours) AS TotalHoursPerWeek
FROM WorkloadAllocations wa
JOIN Lecturers l ON wa.LecturerID = l.LecturerID
JOIN Subjects s ON wa.SubjectCode = s.SubjectCode
GROUP BY wa.LecturerID, l.LecturerName;


--task 6 a
-- Registrar View
CREATEVIEW V_Registrar AS 
SELECT StudentID, FullName, EnrollmentStatus, FeeBalance FROM Students;
GO

-- HOD View
CREATE VIEW V_HOD AS 
SELECT s.StudentID, s.FullName, c.CourseName, d.DeptID 
FROM Students s
JOIN Classes cl ON s.ClassID = cl.ClassID
JOIN Courses c ON cl.CourseID = c.CourseID
JOIN Departments d ON c.DeptID = d.DeptID;
GO

-- Exam Performance View
CREATE VIEW V_ExamPerformance AS 
SELECT StudentID, SubjectCode, Term, Year, (CAT1 + CAT2 + ExamScore) AS FinalMark, IsSupplementary
FROM Assessments;
GO

-- Accounts View
CREATE VIEW V_Accounts AS 
SELECT StudentID, FullName, FeeBalance FROM Students;
GO
 
 task 6 
 -- i) Students due for next graduation (Completed with clear financial balance)
SELECT * FROM V_Registrar WHERE EnrollmentStatus = 'completed' AND FeeBalance <= 0;

-- ii) Identify students with fee balances above 10,000 per department
SELECT h.CourseName, COUNT(a.StudentID) AS DefaulterCount 
FROM V_Accounts a 
JOIN V_HOD h ON a.StudentID = h.StudentID 
WHERE a.FeeBalance > 10000 
GROUP BY h.CourseName;

-- iii) Evaluate departmental examination averages per course
SELECT CourseName, AVG(FinalMark) AS CourseAvg FROM V_ExamPerformance ep JOIN V_HOD h ON ep.StudentID = h.StudentID GROUP BY CourseName;

-- iv) List students in more than one club in descending order
SELECT StudentID, COUNT(ClubID) AS ClubsCount FROM ClubMemberships GROUP BY StudentID HAVING COUNT(ClubID) > 1 ORDER BY ClubsCount DESC;

-- v) Summarize fees collected (Hypothetical target balance matrix extraction)
SELECT CourseName, SUM(FeeBalance) AS RemainingReceivables FROM V_HOD h JOIN V_Accounts a ON h.StudentID = a.StudentID GROUP BY CourseName;

-- vi) Count students scheduled for supplementary exams
SELECT COUNT(StudentID) AS SuppTargetCount FROM V_ExamPerformance WHERE IsSupplementary = 1;

-- vii) Report the number of students on attachment in the current term
SELECT EnrollmentStatus, COUNT(StudentID) FROM V_Registrar WHERE EnrollmentStatus = 'on attachment' GROUP BY EnrollmentStatus;

-- viii) Generate a student's transcript
SELECT * FROM V_ExamPerformance WHERE StudentID = 1 AND Term = 1 AND Year = 2026;

 -- i) Update/Alter view structure definition to encompass updates elegantly
ALTER VIEW V_ExamPerformance AS 
SELECT StudentID, SubjectCode, Term, Year, (CAT1 + CAT2 + ExamScore) AS FinalMark, IsSupplementary,
       CASE WHEN IsSupplementary = 1 THEN 'SUPP' ELSE 'ORDINARY' END AS ExamType
FROM Assessments;
GO

-- ii) Drop the view
DROP VIEW V_ExamPerformance;
GO

-- iii) Recreate the view completely fresh
CREATE VIEW V_ExamPerformance AS 
SELECT StudentID, SubjectCode, Term, Year, (CAT1 + CAT2 + ExamScore) AS FinalMark, IsSupplementary
FROM Assessments;
GO