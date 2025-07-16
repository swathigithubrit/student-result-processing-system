# student-result-processing-system
A SQL Server–based system to manage student grades, GPA calculation, pass/fail statistics, rank lists, and semester-wise result summaries. Includes schema design, data insertion scripts, GPA logic with triggers, and advanced reporting queries using window functions.

🎓 Student Result Processing System

> A mini-project to manage student grades, GPA/CGPA calculation, ranking, and semester-wise results using SQL Server.

---

📑 Objective

Build a complete SQL Server–based system to:
- Manage student records
- Store courses, semesters, and grades
- Calculate GPA automatically
- Generate pass/fail statistics
- Produce rank lists with window functions
- Export semester-wise result summaries

---

🛠️ Tools Used

- Microsoft SQL Server 2019+ (or Azure SQL)
- SQL Server Management Studio (SSMS)

---

📂 Database Schema

The system consists of the following tables:

1. Students
| Column     | Type         | Description                |
|------------|--------------|---------------------------|
| StudentID  | INT (PK)     | Auto-increment ID         |
| FirstName  | NVARCHAR(50) | Student's first name      |
| LastName   | NVARCHAR(50) | Student's last name       |
| Department | NVARCHAR(50) | Department enrolled       |

---

2. Semesters
| Column     | Type         | Description         |
|------------|--------------|--------------------|
| SemesterID | INT (PK)     | Auto-increment ID  |
| Name       | NVARCHAR(20) | Semester name      |

---

3. Courses
| Column     | Type         | Description         |
|------------|--------------|--------------------|
| CourseID   | INT (PK)     | Auto-increment ID  |
| CourseName | NVARCHAR(100)| Course title       |
| Credits    | INT          | Number of credits  |

---

4. GradePoints
| Column | Type         | Description            |
|--------|--------------|-----------------------|
| Grade  | CHAR(2) (PK) | Letter grade (A–F)    |
| Points | DECIMAL(3,1) | Grade point value     |

✅ Used to map letter grades to GPA points.

---

5. Grades
| Column     | Type         | Description                   |
|------------|--------------|------------------------------|
| GradeID    | INT (PK)     | Auto-increment ID            |
| StudentID  | INT (FK)     | References Students          |
| CourseID   | INT (FK)     | References Courses           |
| SemesterID | INT (FK)     | References Semesters         |
| Marks      | INT          | Numeric marks scored         |
| Grade      | CHAR(2) (FK) | References GradePoints table |

---

6. StudentGPA
| Column     | Type         | Description                   |
|------------|--------------|------------------------------|
| StudentID  | INT (PK, FK) | References Students          |
| SemesterID | INT (PK, FK) | References Semesters         |
| GPA        | DECIMAL(4,2) | Computed GPA value           |

✅ Holds per-semester GPA, maintained via trigger.

---

Features

✅ Design relational schema with foreign key constraints  
✅ Insert sample students, semesters, courses, and grades  
✅ GPA calculation using GradePoints mapping  
✅ Automatic GPA update via AFTER INSERT/UPDATE trigger  
✅ Pass/Fail statistics for students  
✅ Rank list generation using SQL Server window functions  
✅ Semester-wise detailed grade reports  

---

