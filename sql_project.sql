-- Step 0: Create the Database
CREATE DATABASE StudentResultDB;
GO

USE StudentResultDB;
GO


-- Step 1: Create Tables

-- Students Table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50)
);


-- Semesters Table
CREATE TABLE Semesters (
    SemesterID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(20)
);


-- Courses Table
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(100),
    Credits INT
);

-- GradePoints Table (for GPA calculation)
CREATE TABLE GradePoints (
    Grade CHAR(2) PRIMARY KEY,
    Points DECIMAL(3,1)
);

-- Grades Table
CREATE TABLE Grades (
    GradeID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
    CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
    SemesterID INT FOREIGN KEY REFERENCES Semesters(SemesterID),
    Marks INT,
    Grade CHAR(2) FOREIGN KEY REFERENCES GradePoints(Grade)
);


-- GPA Table
CREATE TABLE StudentGPA (
    StudentID INT,
    SemesterID INT,
    GPA DECIMAL(4,2),
    PRIMARY KEY (StudentID, SemesterID)
);

-- Step 2: Insert Reference Data

-- Grade Point Mapping
INSERT INTO GradePoints VALUES 
('A', 4.0),
('B', 3.0),
('C', 2.0),
('D', 1.0),
('F', 0.0);


-- Students
INSERT INTO Students (FirstName, LastName, Department) VALUES
('Alice', 'Smith', 'Computer Science'),
('Bob', 'Johnson', 'Electrical Engineering'),
('Carol', 'Taylor', 'Mechanical Engineering');

-- Semesters
INSERT INTO Semesters (Name) VALUES 
('Spring 2025'),
('Fall 2025');

-- Courses
INSERT INTO Courses (CourseName, Credits) VALUES
('Database Systems', 3),
('Algorithms', 4),
('Mathematics', 3),
('Computer Networks', 3);

-- Step 3: Insert Grades
INSERT INTO Grades (StudentID, CourseID, SemesterID, Marks, Grade) VALUES
(1, 1, 1, 85, 'A'),
(1, 2, 1, 78, 'B'),
(1, 3, 1, 70, 'C'),
(2, 1, 1, 60, 'C'),
(2, 2, 1, 45, 'F'),
(2, 3, 1, 55, 'D'),
(3, 1, 1, 90, 'A'),
(3, 2, 1, 88, 'A'),
(3, 3, 1, 85, 'A');

-- Step 4: GPA Calculation Query
-- (Run manually or let the trigger below automate it)


-- Step 5: Trigger for GPA Calculation
CREATE TRIGGER trg_CalculateGPA
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    MERGE StudentGPA AS target
    USING (
        SELECT
            g.StudentID,
            g.SemesterID,
            SUM(gp.Points * c.Credits) / SUM(c.Credits) AS GPA
        FROM Grades g
        JOIN Courses c ON g.CourseID = c.CourseID
        JOIN GradePoints gp ON g.Grade = gp.Grade
        WHERE g.StudentID IN (SELECT DISTINCT StudentID FROM inserted)
          AND g.SemesterID IN (SELECT DISTINCT SemesterID FROM inserted)
        GROUP BY g.StudentID, g.SemesterID
    ) AS source
    ON target.StudentID = source.StudentID AND target.SemesterID = source.SemesterID
    WHEN MATCHED THEN
        UPDATE SET GPA = source.GPA
    WHEN NOT MATCHED THEN
        INSERT (StudentID, SemesterID, GPA)
        VALUES (source.StudentID, source.SemesterID, source.GPA);
END;
GO

-- Step 6: Pass/Fail Report
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    COUNT(CASE WHEN g.Grade = 'F' THEN 1 END) AS FailedCourses,
    COUNT(*) AS TotalCourses,
    CASE
        WHEN COUNT(CASE WHEN g.Grade = 'F' THEN 1 END) > 0 THEN 'Fail'
        ELSE 'Pass'
    END AS Status
FROM Grades g
JOIN Students s ON g.StudentID = s.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName;

-- Step 7: GPA Report (also stored in StudentGPA)
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    sem.Name AS Semester,
    sg.GPA
FROM StudentGPA sg
JOIN Students s ON s.StudentID = sg.StudentID
JOIN Semesters sem ON sem.SemesterID = sg.SemesterID
ORDER BY Semester, GPA DESC;


-- Step 8: Rank List with Window Function
WITH RankedGPA AS (
    SELECT
        s.StudentID,
        s.FirstName,
        s.LastName,
        sem.Name AS Semester,
        sg.GPA,
        RANK() OVER (PARTITION BY sem.Name ORDER BY sg.GPA DESC) AS Rank
    FROM StudentGPA sg
    JOIN Students s ON sg.StudentID = s.StudentID
    JOIN Semesters sem ON sg.SemesterID = sem.SemesterID
)
SELECT * FROM RankedGPA;


-- Step 9: Semester-wise Grade Report
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    sem.Name AS Semester,
    c.CourseName,
    g.Marks,
    g.Grade
FROM Grades g
JOIN Students s ON g.StudentID = s.StudentID
JOIN Semesters sem ON g.SemesterID = sem.SemesterID
JOIN Courses c ON g.CourseID = c.CourseID
WHERE sem.Name = 'Spring 2025'
ORDER BY s.StudentID;