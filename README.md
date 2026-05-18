# OMOP DB Migration Tool
This program is a small desktop application for moving a PostgreSQL database into Microsoft SQL Server by using a two-step process:
**1. Backup:** export each PostgreSQL table to a CSV file.
**2. Restore:** create the SQL Server schema and bulk-load the CSV files into SQL Server.

## What the program does
The app has two tabs:
**Backup tab**
![](../doc/2.1.png)