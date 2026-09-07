# 🚨 RedFlag — The Fraud Files

## 📌 Project Overview

**RedFlag — The Fraud Files** is a SQL-based fraud detection project designed to identify suspicious and potentially fraudulent transaction patterns in a fictional digital payment system.

The project uses **MySQL and advanced SQL queries** to analyze transaction data and detect different types of fraudulent behavior such as unusual transaction velocity, card testing, mule accounts, refund abuse, merchant collusion, geographic impossibility, and other suspicious patterns.

The main goal is to transform raw transaction data into meaningful **fraud indicators and suspect lists** using SQL-based analytical techniques.

---

## 🎯 Project Objective

The objectives of this project are to:

* Analyze large-scale transaction data using SQL.
* Identify suspicious transaction behavior.
* Detect multiple predefined fraud patterns.
* Generate lists of potentially suspicious users and merchants.
* Apply SQL aggregation, filtering, joins, subqueries, CTEs, and window functions.
* Build a reusable SQL-based fraud detection engine.
* Present the findings in a clear and professional format.

---

## 🏦 Project Scenario

The project is based on a fictional Indian payment aggregator called **PayFast**.

PayFast processes a large number of digital transactions. The objective of the fraud detection system is to identify users, merchants, and transaction activities that show characteristics associated with fraudulent behavior.

The system analyzes transaction history and searches for predefined **red-flag patterns**.

---

## 📊 Dataset

The project uses a transaction dataset containing approximately:

| Attribute    | Details                         |
| ------------ | ------------------------------- |
| Transactions | 200,000                         |
| Users        | Approximately 14,500            |
| Merchants    | 800                             |
| Time Period  | January 1, 2024 – June 30, 2024 |
| Database     | MySQL                           |
| Main Table   | `transactions`                  |

### Transaction Attributes

The dataset contains information such as:

* Transaction ID
* User ID
* Merchant ID
* Transaction amount
* Transaction timestamp
* Transaction status
* Payment mode
* City
* Transaction type

---

## 🔍 Fraud Detection Patterns

The project detects **12 major fraud patterns**.

### 1. ⚡ Velocity Fraud

Identifies users making an unusually high number of transactions on the same calendar day.

**Detection rule:**
30 or more transactions by the same user on the same day.

---

### 2. 💰 Round-Amount Clustering

Identifies users who repeatedly make transactions using common round amounts.

**Detection amounts:**

* ₹100
* ₹200
* ₹500
* ₹1,000
* ₹2,000
* ₹5,000
* ₹10,000

**Detection rule:**
15 or more transactions using these exact amounts.

---

### 3. 💳 Card Testing

Identifies possible card-testing activity through repeated very small transactions.

**Detection rule:**
30 or more transactions below ₹10 by the same user on the same day.

---

### 4. ❌➡️✅ Failed-Then-Succeeded

Identifies suspicious transaction behavior where a failed transaction is followed by a successful transaction for the same amount within a short period.

**Detection rule:**

* Same user
* Same transaction amount
* Failed transaction followed by successful transaction
* Within 2 minutes

---

### 5. 🌙 Odd-Hour Concentration

Identifies users whose transaction activity is heavily concentrated during unusual hours.

**Suspicious period:**
02:00 AM – 05:00 AM

**Detection rule:**

* At least 30 transactions
* At least 80% occurring between 02:00 AM and 05:00 AM

---

### 6. 🐴 Mule Accounts

Identifies accounts that receive money and quickly transfer a large portion of that money out.

**Detection rule:**

* CREDIT transaction followed by DEBIT
* Within 30 minutes
* Debit amount is at least 70% of the credited amount

---

### 7. 🔄 Refund Abuse

Identifies users with an unusually high proportion of refunded transactions.

**Detection rule:**

* At least 20 total transactions
* More than 40% of transactions are refunds

---

### 8. 🤝 Merchant Collusion

Identifies merchants where a small group of users contributes a disproportionately large percentage of the merchant's transaction value.

**Detection rule:**

The top 5 users account for more than 60% of the merchant's total transaction value.

---

### 9. 🎯 Just-Under-Threshold

Identifies repeated transactions just below a significant transaction threshold.

**Detection rule:**
10 or more transactions exactly equal to ₹9,999.

---

### 10. 💤 Dormant-Then-Active

Identifies accounts that remain inactive for a long period and then suddenly become highly active.

**Detection rule:**

* At least a 90-day transaction gap
* Followed by at least 15 transactions

---

### 11. 📈 Velocity Spike

Identifies users whose transaction activity suddenly increases significantly compared with their normal monthly activity.

**Detection rule:**

* Peak monthly transaction count ≥ 20
* Peak month is at least 5× the user's average monthly transaction count

---

### 12. 🌍 Geographic Impossibility

Identifies potentially impossible travel or location behavior.

**Detection rule:**

The same user performs transactions from different cities within 60 minutes.

This can indicate:

* Account sharing
* Credential compromise
* Automated fraud
* Suspicious account activity

---

## 🛠️ Technologies Used

* **MySQL**
* **SQL**
* **MySQL Workbench**
* **GitHub**

### SQL Concepts Used

The project makes use of:

* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* Aggregate functions
* `JOIN`
* `EXISTS`
* Subqueries
* Common Table Expressions (CTEs)
* Window functions
* `ROW_NUMBER()`
* `LAG()`
* Date and time functions
* Conditional aggregation
* `CASE`
* `TIMESTAMPDIFF()`

---

## 📁 Project Structure

```text
RedFlag-Fraud-Detection/
│
├── RedFlag_Prerana.sql
├── README.md
│
└── screenshots/
    ├── P8_Merchant_Collusion.png
    ├── P11_Velocity_Spike.png
    └── P12_Geographic_Impossibility.png
```

> **Note:** The original dataset file is used locally for database setup and is not included in the GitHub repository.

---

## 🗄️ Database Structure

The primary table used in the project is:

```text
transactions
```

Main columns include:

```text
txn_id
user_id
merchant_id
amount
txn_time
status
payment_mode
city
txn_type
```

---

## 🔄 Project Workflow

```text
Raw Transaction Data
        ↓
MySQL Database
        ↓
Data Exploration
        ↓
Fraud Detection Queries
        ↓
12 Fraud Patterns
        ↓
Suspicious Users / Merchants
        ↓
Fraud Findings & Analysis
```

---

## 📌 Detection Results

The following section will contain the actual results obtained after executing the fraud detection queries.

| Pattern | Detection                | Suspects Found |
| ------- | ------------------------ | -------------: |
| P1      | Velocity Fraud           |            TBD |
| P2      | Round-Amount Clustering  |            TBD |
| P3      | Card Testing             |            TBD |
| P4      | Failed-Then-Succeeded    |            TBD |
| P5      | Odd-Hour Concentration   |            TBD |
| P6      | Mule Accounts            |            TBD |
| P7      | Refund Abuse             |            TBD |
| P8      | Merchant Collusion       |            TBD |
| P9      | Just-Under-Threshold     |            TBD |
| P10     | Dormant-Then-Active      |            TBD |
| P11     | Velocity Spike           |            TBD |
| P12     | Geographic Impossibility |            TBD |

> The `TBD` values should be replaced with the actual counts obtained from MySQL after running and validating the queries.

---

## 📸 Project Screenshots

Screenshots of important SQL query results will be added here.

### Merchant Collusion

*Add screenshot of the P8 query result here.*

### Velocity Spike

*Add screenshot of the P11 query result here.*

### Geographic Impossibility

*Add screenshot of the P12 query result here.*

---

## 💡 Key Learning Outcomes

Through this project, I gained practical experience in:

* Working with large transaction datasets.
* Writing complex SQL queries.
* Performing fraud-oriented data analysis.
* Using aggregation and grouping techniques.
* Working with date and time data.
* Using joins and subqueries.
* Applying CTEs and window functions.
* Identifying patterns in transactional behavior.
* Presenting analytical findings using GitHub.

---

## 🚀 Future Scope

The project can be extended into a more advanced fraud detection system by adding:

* Real-time transaction monitoring
* Automated fraud alerts
* Fraud risk scoring
* Machine learning-based fraud prediction
* Customer behavior profiling
* Interactive fraud detection dashboards
* Real-time geographic monitoring
* Automated reporting
* Integration with payment systems

---




