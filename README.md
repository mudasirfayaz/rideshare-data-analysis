# 🚗 Rideshare Analytics — SQL + Power BI Project

An end-to-end data analytics project exploring **2.5 years of rideshare operations data** using MySQL for analysis and Power BI for visualization.

---

## 📌 Project Overview

As a data analyst for a fictional rideshare company, I investigated key business questions around revenue performance, driver quality, rider behaviour, trip operations, and payment trends — across **20,000 trips** from January 2022 to June 2024.

---

## 🗃️ Dataset

| Table | Rows | Description |
|---|---|---|
| trips | 20,000 | Core fact table — one row per ride request |
| drivers | 400 | Driver profiles, vehicles, and ratings |
| riders | 1,600 | Rider profiles and lifetime stats |
| users | 2,000 | Shared user records for drivers and riders |
| locations | 40 | Zone definitions with lat/lon and type |
| payments | 16,827 | Payment record per completed trip |
| reviews | 15,136 | Ratings and comments per trip |
| cancellations | 2,966 | Cancellation details |

**Source:** [Kaggle](https://www.kaggle.com/datasets/rockyt07/uber-sql-database).

---

## ❓ Business Questions

| # | Question | Status |
|---|---|---|
| 1 | How is monthly revenue trending, and how volatile is it? | ✅ Done |
| 2 | When is demand highest — by hour and day of week? | 🔄 In progress |
| 3 | Who are the top-performing drivers, and who is underperforming? | ⏳ Pending |
| 4 | Who are our most valuable riders, and are we retaining them? | ⏳ Pending |
| 5 | Are payments completing successfully, and which methods dominate? | ⏳ Pending |

---

## 💡 Key Findings (so far)

### Q1 — Revenue Trend
- **Revenue is volatile** — 13 out of 29 months showed a month-over-month decline (45% of the time)
- **No sustained growth trend** — revenue has oscillated between ~$17k and ~$22k with no clear upward trajectory over 2.5 years
- **November 2022** was the worst single month — a drop of $4,348 from the prior month

### Q2 — Peak Hours & Days
- **Demand is evenly spread across all 7 days** — no dramatic weekend/weekday split (2,347–2,459 trips per day)
- **Friday has the highest avg fare ($41.85)** — 43% more expensive than Sunday ($29.26) despite similar trip volumes
- **Busiest hour is 6pm (754 trips)** — classic evening commute
- **Highest fares occur at 7am ($54.03), 8am ($53.27), and 7pm ($57.76)** — surge pricing activates during commute hours and late night, not just on volume alone
- **Operations insight:** driver availability should be prioritised at 7am, 8am, 6pm, and 7pm for maximum revenue impact
 

---

## 🛠️ Tools Used

- **MySQL** — data exploration and analytical queries
- **Power BI Desktop** — dashboard and visualizations *(in progress)*
- **DAX** — calculated measures in Power BI *(in progress)*

---

## 📁 Repository Structure

```
rideshare-analytics/
│
├── data/
│   └── rideshare.db
│
├── sql/
│   ├── 01_exploration.sql
│   ├── 02_revenue_trend.sql
│   ├── 03_peak_hours_days.sql
│   └── ...
│
├── powerbi/
│   └── rideshare_dashboard.pbix
│
└── README.md
```

---

## 📊 Dashboard Preview

*Coming soon — Power BI dashboard screenshots will be added here.*

---

## 🚀 How to Run

1. Clone the repo
2. Import `data/rideshare.db` into MySQL or run `data/schema.sql` file in MySQL
3. Run the SQL files in the `sql/` folder in order
4. Open `powerbi/rideshare_dashboard.pbix` in Power BI Desktop

---

*Project is actively in progress — updated regularly as new questions are answered.*
