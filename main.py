import psycopg2
import os
import threading
import logging
from tkinter import *
from tkinter import ttk


logging.basicConfig(
    filename="log.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

root = Tk()
root.title('OMOP DB Migration')
root.geometry("500x700")

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

#--------------------------------User interface----------------------------------------------------
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
Label(restore_tab, text="Restore functionality coming soon!", font=("Times New Roman", 12, "bold")).pack(pady=20)

root.mainloop()