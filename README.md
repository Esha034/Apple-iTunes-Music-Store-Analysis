# 🎧 Apple iTunes Music Store Analysis 

##  Project Overview
This project performs an end-to-end SQL analysis of the Apple iTunes (Chinook) music store database.  
The goal is to extract actionable business insights about customer behavior, sales performance, music trends, and operational efficiency using pure SQL.

This project was completed as part of an industry-style analytics task focusing on relational database design, data cleaning, and advanced SQL analysis.

---

##  Business Objectives

- Understand customer purchasing behavior
- Identify top-performing artists, tracks, and genres
- Analyze revenue trends across time and regions
- Evaluate employee sales performance
- Perform operational optimization using advanced SQL

---

## Tools & Technologies

- **PostgreSQL**
- SQL (Joins, CTEs, Window Functions, Aggregations)
- CSV-based relational dataset
- pgAdmin for database management

---

## 🗂 Dataset Tables

The dataset contains 11 relational tables:

- Artist
- Album
- Track
- Genre
- Media Type
- Playlist
- Playlist Track
- Customer
- Employee
- Invoice
- Invoice Line

---

## Database Design

A normalized relational schema was created with proper:

- Primary Keys
- Foreign Keys
- Referential Integrity
- Clean data types

### Schema Flow:

    Artist → Album → Track → Invoice_Line → Invoice → Customer → Employee

---

---

## Advanced SQL Concepts Used

- Multi-table JOINs
- Subqueries
- CTEs (WITH clauses)
- Window Functions (LAG)
- Market Basket Analysis
- Time-series aggregation
- Business KPI derivation

---

##  Sample Insights

1. A small group of customers contributes a large portion of total revenue (Pareto effect).

2. Certain genres have high inventory but low sales, indicating content inefficiency.

3. Specific regions show high user base but lower monetization potential.

4. A few artists dominate total revenue generation.

5. Lower-priced tracks show higher purchase frequency.

---

## 📁 Project Structure

    itunes-sql-analysis/
    │
    ├── data/ # Raw CSV datasets
    ├── sql/
    │ └── itunes_analysis.sql
    └── README.md


---

##  How to Run the Project

1. Create a PostgreSQL database
2. Create tables using the provided SQL schema
3. Import CSV files
4. Apply foreign key constraints
5. Run analysis queries in `itunes_analysis.sql`

---

##  Learning Outcomes

- Real-world relational database handling
- Data cleaning and schema alignment
- Writing production-grade SQL queries
- Translating business questions into SQL insights
- Advanced analytical thinking

---

##  Conclusion

This project demonstrates strong SQL proficiency and business-oriented data analysis skills.  
It showcases the ability to transform raw relational data into meaningful insights using structured querying techniques.

---

## Author

**Eshani Banik**  

CSE-AIML

Aspiring Data Analyst 
