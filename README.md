
##  🚛 Logistics End-to-End Data Warehouse Project

## 🌟 Project Overview

In the logistics industry, a single trip generates multiple data points — drivers, trucks, fuel, routes, maintenance, and delivery events.

This project transforms raw, disconnected CSV files into a **centralized Data Warehouse** designed for accurate analysis and better business decision-making.

🎯 Goal:
Turn messy operational data into a **reliable analytical system (Single Source of Truth)**.

---

## 🏗️ Architecture Overview (ETL Pipeline)

The project follows a complete **End-to-End ETL pipeline**:

### 📥 1. OLTP Modeling
- Designed a relational database (**Logistics_OLTP**) with 14 normalized tables  
- Established relationships using **Primary & Foreign Keys**  
- Simulated a real-world logistics system  

---

### ⚡ 2. Data Ingestion
- Loaded raw CSV data using **BULK INSERT**  
- Preserved original business IDs  

---

### 🧹 3. Data Cleaning & Validation
- Handled missing foreign keys using **Dummy Records**  
  (`DRV_UNKNOWN`, `TR_UNKNOWN`, `TRA_UNKNOWN`)  
- Applied business rules:
  - No negative values (fuel, distance, duration)  
  - Speed outlier detection  
  - Driver age ≥ 18  
- Ensured **data consistency without data loss**

---

### 🏗️ 4. Data Warehouse (OLAP)
Built a **Logistics_DWH** using **Star Schema**:

- **Fact Tables**:
  - FACT_TRIPS  
  - FACT_FUEL  
  - FACT_MAINTENANCE  
  - FACT_INCIDENTS  

- **Dimension Tables**:
  - DIM_DRIVER  
  - DIM_TRUCK  
  - DIM_FACILITY  
  - DIM_DATE  
  - and more  

- Used **Surrogate Keys** for better performance and decoupling  

---

### 📅 5. Date Dimension
- Generated using T-SQL (WHILE LOOP)  
- Covers years 2020 → 2030  
- Includes:
  - Month, Quarter  
  - Day Name  
  - Weekend Flag  

---

### 🚀 6. ETL Transformation Logic
Core transformation layer includes:

- **Aggregation**
  - Combined multiple delivery events into a single trip record  

- **Role-Playing Dimensions**
  - Facility used as Origin and Destination  

- **SCD Type 2**
  - Preserved historical data using `Is_Current = 1`  

---

## 🛠️ Key Features

- Data Cleaning & Validation  
- Referential Integrity Handling  
- Outlier Detection  
- Star Schema Design  
- Historical Tracking (SCD Type 2)  
- Advanced SQL (Joins, CTEs, Aggregations)  

---

## 📂 Repository Structure

```
.
├── scripts/
│   ├── 01_OLTP_Database/
│   ├── 02_Extract_From_CSV/
│   ├── 03_Data_Cleaning_Validation/
│   ├── 04_DWH_Architecture/
│   └── 05_LOAD_FROM_OLTP_INTO_OLAP/
│
├── Sample_Data/
├── Schema/
└── README.md
```

---

## 💡 Business Value

This system enables answering key business questions:

- Which routes are most cost-efficient?  
- What is the on-time delivery rate?  
- How does maintenance affect performance?  

---

## 🛠️ Tech Stack

- Microsoft SQL Server  
- T-SQL  
- Dimensional Modeling (Star Schema)  

---

## 🚀 Next Step

Building interactive dashboards using **Power BI** to visualize insights and support decision-making.
