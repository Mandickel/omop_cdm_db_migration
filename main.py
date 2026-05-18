import psycopg2
import pyodbc
import os
import threading
import logging
import re
from tkinter import *
from tkinter import ttk, messagebox

# ---------------- LOGGING ----------------
logging.basicConfig(
    filename="Log.log",
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    filemode="a"
)

# ---------------- HELPERS ----------------
def validate_identifier(name):
    if not re.match(r'^[A-Za-z0-9_]+$', name):
        raise ValueError(f"Invalid identifier: {name}")
    return name

def build_sql_server_name(host, port):
    host = host.strip()
    if "\\" in host or "," in host:
        return host
    if port:
        return f"{host},{port}"
    return host


# ---------------- MAIN APP ----------------
class MigrationApp:

    def __init__(self, root):
        self.root = root
        self.root.title('OMOP DB Migration')
        self.root.geometry("500x600")
        self.setup_ui()

    # ---------------- UI ----------------
    def setup_ui(self):
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill='both', expand=True, padx=10, pady=10)

        self.backup_tab = Frame(notebook)
        self.restore_tab = Frame(notebook)

        notebook.add(self.backup_tab, text="Backup")
        notebook.add(self.restore_tab, text="Restore")

        self.build_backup_ui()
        self.build_restore_ui()

    def create_field(self, parent, label, default):
        Label(parent, text=label).pack(anchor="w", padx=50)
        combo = ttk.Combobox(parent, values=[default], width=47)
        combo.set(default)
        combo.pack(padx=50, pady=5)
        return combo

    def create_entry(self, parent, label, show=None):
        Label(parent, text=label).pack(anchor="w", padx=50)
        entry = Entry(parent, width=50, show=show)
        entry.pack(padx=50, pady=5)
        return entry

    def log_and_update(self, message):
        logging.info(message)
        self.root.after(0, lambda: self.result_label_r.config(text=message))

    # ---------------- BACKUP ----------------
    def build_backup_ui(self):
        Label(self.backup_tab, text="OMOP CDM Backup", font=("Arial", 12, "bold")).pack(pady=10)

        self.ServerName = self.create_field(self.backup_tab, "Server:", "localhost")
        self.DBname = self.create_field(self.backup_tab, "Database:", "cdm_synthea")
        self.Schema = self.create_field(self.backup_tab, "Schema:", "public")
        self.Port = self.create_field(self.backup_tab, "Port:", "5432")

        self.Username = self.create_entry(self.backup_tab, "Username:")
        self.Password = self.create_entry(self.backup_tab, "Password:", show="*")

        self.start_button = Button(self.backup_tab, text="Start Backup", command=self.start_backup_thread)
        self.start_button.pack(pady=20)

        self.progress = ttk.Progressbar(self.backup_tab, length=450)
        self.progress.pack(pady=10)

        self.result_label = Label(self.backup_tab, text="")
        self.result_label.pack()

    def start_backup_thread(self):
        self.start_button.config(state="disabled")
        threading.Thread(target=self.start_backup).start()

    def start_backup(self):
        failed_tables = []

        try:
            conn = psycopg2.connect(
                host=self.ServerName.get(),
                dbname=validate_identifier(self.DBname.get()),
                user=self.Username.get(),
                password=self.Password.get(),
                port=int(self.Port.get())
            )
            cursor = conn.cursor()

            db = self.DBname.get()
            schema = validate_identifier(self.Schema.get())

            os.makedirs(db, exist_ok=True)

            # ONLY real tables (not views)
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables
                WHERE table_schema = %s
                AND table_type = 'BASE TABLE'
                ORDER BY table_name
            """, (schema,))

            tables = cursor.fetchall()

            logging.info(f"Found {len(tables)} tables")

            self.root.after(0, lambda: self.progress.config(maximum=len(tables)))

            for i, (table,) in enumerate(tables, 1):
                try:
                    logging.info(f"Starting export: {table}")

                    self.root.after(0, lambda t=table: self.result_label.config(text=f"Exporting {t}..."))

                    with open(f"{db}/{table}.csv", "w", encoding="utf-8") as f:
                        cursor.copy_expert(
                            f'COPY "{schema}"."{table}" TO STDOUT WITH CSV HEADER',
                            f
                        )

                    logging.info(f"SUCCESS: {table}")

                except Exception as table_error:
                    logging.error(f"FAILED: {table} | {table_error}")
                    failed_tables.append(table)

                finally:
                    self.root.after(0, lambda v=i: self.progress.config(value=v))

            conn.close()

            # FINAL STATUS
            if failed_tables:
                msg = f"Backup completed with errors ({len(failed_tables)} failed)"
                logging.warning(msg)
                logging.warning(f"Failed tables: {failed_tables}")
            else:
                msg = "Backup completed successfully"
                logging.info(msg)

            self.root.after(0, lambda: self.result_label.config(text=msg))

        except Exception as e:
            logging.error(f"FATAL ERROR: {e}")
            self.root.after(0, lambda err=e: messagebox.showerror("Error", str(err)))

        finally:
            self.root.after(0, lambda: self.start_button.config(state="normal"))
            
    # ---------------- RESTORE ----------------
    def build_restore_ui(self):
        Label(self.restore_tab, text="OMOP CDM Restore", font=("Arial", 12, "bold")).pack(pady=10)

        self.ServerName_r = self.create_field(self.restore_tab, "Server:", "localhost")
        self.DBname_r = self.create_field(self.restore_tab, "Database:", "cdm_synthea")
        self.Schema_r = self.create_field(self.restore_tab, "Schema:", "dbo")
        self.Port_r = self.create_field(self.restore_tab, "Port:", "")

        self.Username_r = self.create_entry(self.restore_tab, "Username:")
        self.Password_r = self.create_entry(self.restore_tab, "Password:", show="*")

        self.start_button_r = Button(self.restore_tab, text="Start Restore", command=self.start_restore_thread)
        self.start_button_r.pack(pady=20)

        self.progress_r = ttk.Progressbar(self.restore_tab, length=450)
        self.progress_r.pack(pady=10)

        self.result_label_r = Label(self.restore_tab, text="")
        self.result_label_r.pack()

    def start_restore_thread(self):
        self.start_button_r.config(state="disabled")
        threading.Thread(target=self.start_restore).start()

    def start_restore(self):
        try:
            server = build_sql_server_name(self.ServerName_r.get(), self.Port_r.get())
            db = validate_identifier(self.DBname_r.get())
            schema = validate_identifier(self.Schema_r.get())

            user = self.Username_r.get()
            pwd = self.Password_r.get()

            conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={db};"
            conn_str += f"UID={user};PWD={pwd};" if user else "Trusted_Connection=yes;"

            conn = pyodbc.connect(conn_str, autocommit=False)
            cursor = conn.cursor()

            ddl_folder = "ddl"
            data_folder = db

            # ---- STEP 1 ----
            self.log_and_update("STEP 1: Creating tables...")
            self.create_tables(cursor, ddl_folder, db, schema)
            conn.commit()

            # ---- STEP 2 ----
            self.log_and_update("STEP 2: Loading data...")
            self.load_data(cursor,  conn, data_folder, schema)
            conn.commit()

            # ---- STEP 3 ----
            self.log_and_update("STEP 3: Creating PK + indexes...")
            self.create_pk_indexes(cursor, ddl_folder, db, schema)
            conn.commit()

            # ---- STEP 4 ----
            self.log_and_update("STEP 4: Creating foreign keys...")
            self.create_foreign_keys(cursor, ddl_folder, db, schema)
            conn.commit()

            conn.close()
            self.root.after(0, lambda: self.result_label_r.config(text="Restore complete"))

        except Exception as e:
            logging.error(str(e))
            try:
                conn.rollback()
            except:
                pass
            self.root.after(0, lambda: messagebox.showerror("Error", str(e)))

        finally:
            self.root.after(0, lambda: self.start_button_r.config(state="normal"))

    # ---------------- STEPS ----------------
    def create_tables(self, cursor, folder, db, schema):
        files = [f for f in os.listdir(folder) if "table" in f.lower()]
        for file in files:
            self.log_and_update(f"Creating tables from {file}")
            self.execute_sql_file(cursor, os.path.join(folder, file), db, schema)

    def create_pk_indexes(self, cursor, folder, db, schema):
        files = [f for f in os.listdir(folder) if "pk" in f.lower() or "index" in f.lower()]
        for file in files:
            self.log_and_update(f"Creating PK/index from {file}")
            self.execute_sql_file(cursor, os.path.join(folder, file), db, schema)

    def create_foreign_keys(self, cursor, folder, db, schema):
        files = [f for f in os.listdir(folder) if "fk" in f.lower()]
        for file in files:
            self.log_and_update(f"Creating FK from {file}")
            self.execute_sql_file(cursor, os.path.join(folder, file), db, schema)

    def load_data(self, cursor, conn, folder, schema):
        files = sorted([f for f in os.listdir(folder) if f.lower().endswith(".csv")])
        total = len(files)

        self.root.after(0, lambda: self.progress_r.config(maximum=total, value=0))

        for i, file in enumerate(files, 1):
            table = os.path.splitext(file)[0]
            path = os.path.abspath(os.path.join(folder, file))

            self.log_and_update(f"[{i}/{total}] Loading {table}...")

            cursor.execute(f"""
                BULK INSERT [{schema}].[{table}]
                FROM '{path}'
                WITH (FORMAT='CSV', FIRSTROW=2, CODEPAGE='65001', TABLOCK)
            """)
            conn.commit()
            logging.info(f"Loaded {table}")
            self.root.after(0, lambda v=i: self.progress_r.config(value=v))

    def execute_sql_file(self, cursor, path, db, schema):
        logging.info(f"Executing {path}")
        with open(path, "r", encoding="utf-8") as f:
            sql = f.read()

        sql = sql.replace("$(DBNAME)", db).replace("$(SCHEMA)", schema)
        statements = re.split(r'^\s*GO\s*$', sql, flags=re.MULTILINE)

        for i, stmt in enumerate(statements, 1):
            if stmt.strip():
                cursor.execute(stmt)
                logging.info(f"{path} - statement {i} executed")

# ---------------- RUN ----------------
root = Tk()
app = MigrationApp(root)
root.mainloop()