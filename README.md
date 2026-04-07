
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
│   └── 06_Analytical_Queries/
│
├── Sample_Data/
├── Logistics_Dashboard_&_Analysis/
|   ├── LOGISTIC DASHBOARD.png
|   ├── DRIVERS &TRUCKS DASHBOARD.png
|   ├── TRIPS DASHBOARD.png
|   ├── Logistics_Dashboard EXCEL FILE
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

## 📊 Analytical Layer (Business Queries & Insights)

After building the Data Warehouse, I developed a set of **analytical SQL queries** to extract actionable business insights and simulate real-world decision-making scenarios.

### 📌 Key Analysis Areas

#### 🚚 Operational KPIs

* Total number of trips
* Total revenue
* Total shipped pieces
* Total weight transported

---

#### ⏱️ Driver Performance Analysis

* Top 5 drivers based on **On-Time Delivery Rate**
* Evaluation of driver performance trends using:

  * `LAG` / `LEAD` functions
* Identification of performance improvement or decline over time

---

#### ⛽ Fuel Efficiency & Cost Analysis

* Detection of **least fuel-efficient routes (low MPG)**
* Comparison of driver fuel performance against state averages
* Identification of high fuel consumption patterns

---

#### 🛠️ Maintenance & Risk Analysis

* Correlation between **maintenance cost and incident frequency**
* Detection of trucks requiring frequent maintenance within short periods
* Cumulative maintenance cost tracking using window functions

---

#### 🌍 Regional Performance Insights

* Revenue and trip distribution across states
* Top-performing drivers per state using:

  * `DENSE_RANK()`
* Identification of high-performing regions

---

#### 🧠 Advanced SQL Techniques Used

* Window Functions (`LAG`, `LEAD`, `SUM OVER`)
* Ranking Functions (`ROW_NUMBER`, `RANK`, `DENSE_RANK`)
* CTEs (Common Table Expressions)
* PIVOT for quarterly revenue analysis
* Subqueries & Aggregations

---

💡 These queries represent the transition from **Data Engineering → Data Analysis**, where raw data is transformed into **business insights that support decision-making**.

---

---

## 🧠 Key Business Insights (Data Storytelling)

After performing the analytical queries and building dashboards, several critical insights were identified:

---

### ⚠️ 1. Operational Reliability Issue

* On-Time Delivery Rate = **29.8%**
* Significantly below expected industry standards

💡 Insight:
Despite stable financial performance, the company suffers from a **major operational reliability problem**, directly impacting customer satisfaction.

---

### 📉 2. Efficiency Decline 

* Total trips increased
* Average revenue per trip decreased

💡 Insight:
The company is **handling more operations but generating less value per trip**, indicating inefficiencies in pricing, routing, or trip utilization.

---

### ⏱️ 3. High Detention Time (Root Cause Indicator)

* Average detention time ≈ **183 minutes per trip (~3 hours)**

💡 Insight:
This is a strong indicator behind delivery delays, possibly caused by:

* Warehouse inefficiencies
* Loading/unloading delays
* Poor route planning

---

### 💰 4. High Profitability vs Hidden Risk

* Profit growth > Revenue growth
* Profitability ratio (PPR) ≈ **67%**

💡 Insight:
Indicates strong cost control — but may also suggest:

* Missing cost components
* Or incomplete cost allocation

---

### 🚛 5. Fleet Utilization vs Performance

* Volvo trucks are the most used

💡 Insight:
High usage does not necessarily mean best performance —
further analysis is required to evaluate **efficiency vs utilization**.

---

### 🌍 6. Regional Revenue Concentration

* Texas and Washington generate the highest revenue

💡 Insight:
Revenue concentration may be driven by **trip volume rather than profitability**, requiring deeper margin analysis per route.

---

### 🚨 7. Risk & Incident Analysis

* 60 incidents → $840K+ in damages
* Mix of accidents and compliance violations

💡 Insight:
Indicates operational risk requiring:

* Driver training
* Stronger compliance and monitoring systems

---

## 🎯 Final Conclusion

This analysis reveals a realistic business scenario:

✔️ Financial performance is stable
✔️ Operational efficiency is improving

❗ However:
The company is facing a **critical gap in service reliability**

---

💡 Key Takeaway:

> This is not a revenue problem —
> it is an **operational efficiency and reliability problem**

---

🚀 This section demonstrates the transition from:
**Data → Information → Insight → Decision**

---
