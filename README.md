# OMOP DB Migration Tool
The OMOP DB Migration Tool is a desktop application used to migrate data from a PostgreSQL database into Microsoft SQL Server.

The application performs the migration in two stages:

**1. Backup:** 
	- Exports PostgreSQL tables into CSV files.

**2. Restore:** 
	- Creates SQL Server tables.
	- Imports CSV data into SQL Server.
	- Applies indexes and constraints.

## System Requirements

Before using the application, ensure the following software is installed.

**Required Software**

**Python**

Python 3.8 or later is recommended.

*Download*

https://www.python.org/downloads/

**PostgreSQL**
Access to a PostgreSQL source database.

*Download:*

https://www.postgresql.org/download/

**Microsoft SQL Server**

Access to a SQL Server destination database.

*Download*

https://www.microsoft.com/en-gb/sql-server/

**ODBC Driver for SQL Server**

Install:

	- ODBC Driver 17 for SQL Server
	
Download:

https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver17

**Required Python Packages**

Install the required libraries:

pip install psycopg2 pyodbc

Connects to PostgreSQL and exports every base table in the chosen schema to a CSV file.

<img src="doc/2.1.png" width="400">

**1.** Only real tables are exported.

**2.** Views are ignored.

**3.** Each table is saved as CSV with a header row.

**4.** Output files are stored in a folder named after the database, for example:

		your_project/
		│
		├── main.py
		├── Log.log
		├── doc/
		├── ddl/
		│
		└── dbname/
			├── person.csv
			├── visit_occurrence.csv
			└── condition_occurrence.csv