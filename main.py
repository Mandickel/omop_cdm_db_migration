import psycopg2
import pyodbc
import os
import threading
import logging
import csv
from tkinter import *
from tkinter import ttk
import re


logging.basicConfig(
    filename="log.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

root = Tk()
root.title('OMOP DB Migration')
root.geometry("500x750")

notebook = ttk.Notebook(root)
notebook.pack(fill='both', expand=True, padx=10, pady=10)

backup_tab = Frame(notebook)
restore_tab = Frame(notebook)

notebook.add(backup_tab, text="Backup")
notebook.add(restore_tab, text="Restore")

# ---------------- FUNCTIONS ----------------

def update_ui(i, table_name):
    result_label.config(text=f"Exporting {table_name}...")
    progress['value'] = i

def backup_complete():
    result_label.config(text="Backup completed successfully!")
    progress['value'] = 0
    start_button.config(state="normal")

def backup_error(msg):
    result_label.config(text=f"Error: {msg}")
    start_button.config(state="normal")

def start_backup():
    # ---- Get values from fields ----
    host = ServerName.get()
    db = DBname.get()
    schema = Schema.get()
    port = int(Port.get())
    user = Username.get()
    password = Password.get()

    logging.info(f"Starting backup for DB: {db} on {host}")

    try:
        # ---- Connect to PostgreSQL ----
        conn = psycopg2.connect(
            host=host,
            dbname=db,
            user=user,
            password=password,
            port=port
        )
        logging.info("Database connection established")
        cursor = conn.cursor()

        

        # ---- Create backup folder ----
        os.makedirs(db, exist_ok=True)

        # ---- Get tables ----
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = %s
        """, (schema,))

        tables = cursor.fetchall()
        logging.info(f"Found {len(tables)} tables in schema '{schema}'")

        root.after(0, lambda: progress.config(maximum=len(tables)))

        # Export tables
        for i, table in enumerate(tables, start=1):
            table_name = table[0]
            
            logging.info(f"Exporting {table_name}")
            
            root.after(0, update_ui, i, table_name)
            #result_label.config(text=f"Exporting {table_name}...")
            #root.update_idletasks()

            with open(f"{db}/{table_name}.csv", "w", encoding="utf-8", newline="\r\n") as f:
                cursor.copy_expert(
                    f'COPY "{schema}"."{table_name}" TO STDOUT WITH CSV HEADER',
                    f
                )
        conn.close()
        logging.info("Backup completed successfully")
        root.after(0, backup_complete)
            #progress['value'] = i
            #root.update_idletasks()

        
    except Exception as e:
        logging.error(str(e))
        root.after(0, backup_error, str(e))


def start_backup_thread():
    start_button.config(state="disabled")
    thread = threading.Thread(target=start_backup)
    thread.start()
# ==================================================
#  RESTORE (CSV → SQL Server)
# ==================================================
def update_ui_restore(i, table_name):
    result_label_b.config(text=f"Restoring {table_name}...")
    progress_b['value'] = i

def process_complete():
    result_label_b.config(text="Restore completed successfully!")
    progress_b['value'] = 0
    start_button_b.config(state="normal")

def process_error(msg):
    result_label_b.config(text=f"Error: {msg}")
    start_button_b.config(state="normal")
    
def execute_sql_file(cursor, file_path, db_name, schema_name):
    """Execute a SQL file with $(DBNAME) and $(SCHEMA) replaced, splitting on GO statements"""
    with open(file_path, "r", encoding="utf-8") as f:
        sql = f.read()

    sql = sql.replace("$(DBNAME)", db_name)
    sql = sql.replace("$(SCHEMA)", schema_name)
    
    statements = re.split(r'^\s*GO\s*$', sql, flags=re.MULTILINE | re.IGNORECASE)

    for stmt in statements:
        stmt = stmt.strip()
        if stmt:
            print("Executing:", stmt[:100])  # DEBUG
            cursor.execute(stmt)

def start_restore():
    host = ServerName_r.get()
    db = DBname_r.get()
    schema = Schema_r.get()
    user = Username_r.get()
    password = Password_r.get()

    ddl_folder = "ddl"
    data_folder = db

    try:
        # ---------------- STEP 1: CREATE DATABASE ----------------
        conn = pyodbc.connect(
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={host};"
            f"DATABASE=master;"
            f"Trusted_Connection=yes;"
        )
        cursor = conn.cursor()
        
        cursor.execute(f"""
        IF DB_ID('{db}') IS NULL
            CREATE DATABASE [{db}]
        """)
        conn.commit()
        conn.close()
        
        logging.info("Connected to SQL Server")
        
        # ---------------- STEP 2: CONNECT TO TARGET DB ----------------      
        conn = pyodbc.connect(
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={host};"
            f"DATABASE={db};"
            f"Trusted_Connection=yes;"
        )
        cursor = conn.cursor()
         
        # ---------------- STEP 3: CREATE SCHEMA ----------------
        cursor.execute(f"""
        IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema}')
        BEGIN
            EXEC('CREATE SCHEMA [{schema}]')
        END
        """)
        conn.commit()       
        # ---------------- CREATE TABLES ----------------
        files = os.listdir(ddl_folder)
        # Ensure tables.sql runs first
        files.sort(key=lambda x: (x != "tables.sql", x))
        for file in files:
            if file.endswith(".sql") and "index" not in file.lower():
                execute_sql_file(cursor, os.path.join(ddl_folder, file), db, schema)
                #print(cursor.fetchall())
        conn.commit()
    
        # DEBUG: confirm tables exist
        cursor.execute("SELECT name FROM sys.tables")
        logging.info(f"Tables: {cursor.fetchall()}")
        
        # ---------------- LOAD DATA ----------------
        files = [f for f in os.listdir(data_folder) if f.endswith(".csv")]
        root.after(0, lambda: progress_b.config(maximum=len(files)))

        for i, file in enumerate(files, start=1):
            table_name = file.replace(".csv", "")
            filepath = os.path.abspath(os.path.join(data_folder, file))

            root.after(0, update_ui_restore, i, table_name)

            bulk_sql = f"""
            BULK INSERT [{schema}].[{table_name}]
            FROM '{filepath}'
            WITH (
                FORMAT = 'CSV',
                FIRSTROW = 2,
                CODEPAGE = '65001'
            )
            """
            logging.info(f"Loaded {table_name}")
            cursor.execute(bulk_sql)
            conn.commit()

        # ---------------- CREATE INDEXES ----------------
        for file in os.listdir(ddl_folder):
            if "index" in file.lower():
                execute_sql_file(cursor, os.path.join(ddl_folder, file), db, schema)

        conn.commit()
        conn.close()

        root.after(0, process_complete)

    except Exception as e:
        logging.error(str(e))
        root.after(0, process_error, str(e))

def start_restore_thread():
    start_button_b.config(state="disabled")
    threading.Thread(target=start_restore).start()
    
# ----------------- BACKUPP TAB UI -----------------
Label(backup_tab, text="OMOP CDM Backup", font=("Times New Roman", 12, "bold")).pack(pady=10)
Label(backup_tab, text="Server name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Server_options = ["localhost"]
ServerName = ttk.Combobox(backup_tab, values=Server_options, width=47, font=('Times New Roman', 12))
ServerName.set("localhost")  # default value
ServerName.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="DB name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
DBname_options = ["cdm_synthea"]
DBname = ttk.Combobox(backup_tab, values=DBname_options, width=47, font=('Times New Roman', 12))
DBname.set("cdm_synthea")  # default value
DBname.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="Schema name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Schema_options = ["public", "result", "temp"]
Schema = ttk.Combobox(backup_tab, values=Schema_options, width=47, font=('Times New Roman', 12))
Schema.set("public")  # default value
Schema.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="Port:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
# Predefined port options
port_options = ["5432", "5433", "5434"]
Port = ttk.Combobox(backup_tab, values=port_options, width=47, font=('Times New Roman', 12))
Port.set("5432")  # default value
Port.pack(padx=50, pady=10, anchor="w")


Label(backup_tab, text="Username:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Username = Entry(backup_tab, width=50, font=('Times New Roman', 12))
Username.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="Password:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Password = Entry(backup_tab, width=50, show="*",font=('Times New Roman', 12))
Password.pack(padx=50, pady=10, anchor="w")

# Radiobutton – single choice from a set
Label(backup_tab, text="RDBMS:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
radio_var = StringVar(value="PostgreSQL")
rb1 = Radiobutton(backup_tab, text="PostgreSQL", variable=radio_var, value="PostgreSQL")
rb2 = Radiobutton(backup_tab, text="Microsoft SQL Server", variable=radio_var, value="Microsoft SQL Server")
rb3 = Radiobutton(backup_tab, text="MYSQL", variable=radio_var, value="MYSQL")
rb1.pack(anchor="w",padx=50)
rb2.pack(anchor="w",padx=50)
rb3.pack(anchor="w",padx=50)

# Start button
start_button = Button(backup_tab, text="Start Backup", command=start_backup_thread)
start_button.pack(pady=20, anchor="w", padx=50)

# Progress bar
progress = ttk.Progressbar(backup_tab, orient="horizontal", length=450, mode="determinate")
progress.pack(padx=50, pady=10, anchor="w")

# Result label
result_label = Label(backup_tab, text="", font=("Times New Roman", 10))
result_label.pack(anchor="w", padx=50, pady=(5, 20))


# ----------------- RESTORE TAB UI -----------------
Label(restore_tab, text="OMOP CDM Restoration", font=("Times New Roman", 12, "bold")).pack(pady=10)
Label(restore_tab, text="Server name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Server_options = ["localhost"]
ServerName_r = ttk.Combobox(restore_tab, values=Server_options, width=47, font=('Times New Roman', 12))
ServerName_r.set("localhost")  # default value
ServerName_r.pack(padx=50, pady=10, anchor="w")

Label(restore_tab, text="DB name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
DBname_options = ["cdm_synthea"]
DBname_r = ttk.Combobox(restore_tab, values=DBname_options, width=47, font=('Times New Roman', 12))
DBname_r.set("cdm_synthea")  # default value
DBname_r.pack(padx=50, pady=10, anchor="w")

Label(restore_tab, text="Schema name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Schema_options = ["dbo", "public", "result", "temp"]
Schema_r = ttk.Combobox(restore_tab, values=Schema_options, width=47, font=('Times New Roman', 12))
Schema_r.set("dbo")  # default value
Schema_r.pack(padx=50, pady=10, anchor="w")

Label(restore_tab, text="Port:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
# Predefined port options
port_options = ["5432", "5433", "5434"]
Port_r = ttk.Combobox(restore_tab, values=port_options, width=47, font=('Times New Roman', 12))
Port_r.set("5432")  # default value
Port_r.pack(padx=50, pady=10, anchor="w")


Label(restore_tab, text="Username:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Username_r = Entry(restore_tab, width=50, font=('Times New Roman', 12))
Username_r.pack(padx=50, pady=10, anchor="w")

Label(restore_tab, text="Password:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Password_r = Entry(restore_tab, width=50, show="*",font=('Times New Roman', 12))
Password_r.pack(padx=50, pady=10, anchor="w")

# Radiobutton – single choice from a set
Label(restore_tab, text="RDBMS:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
radio_var = StringVar(value="Microsoft SQL Server")
rb1 = Radiobutton(restore_tab, text="PostgreSQL", variable=radio_var, value="PostgreSQL")
rb2 = Radiobutton(restore_tab, text="Microsoft SQL Server", variable=radio_var, value="Microsoft SQL Server")
rb3 = Radiobutton(restore_tab, text="MYSQL", variable=radio_var, value="MYSQL")
rb1.pack(anchor="w",padx=50)
rb2.pack(anchor="w",padx=50)
rb3.pack(anchor="w",padx=50)

# Start button
start_button_b = Button(restore_tab, text="Start Restore", command=start_restore_thread)
start_button_b.pack(pady=20, anchor="w", padx=50)

# Progress bar
progress_b = ttk.Progressbar(restore_tab, orient="horizontal", length=450, mode="determinate")
progress_b.pack(padx=50, pady=10, anchor="w")

# Result label
result_label_b = Label(restore_tab, text="", font=("Times New Roman", 10))
result_label_b.pack(anchor="w", padx=50, pady=(5, 20))

root.mainloop()