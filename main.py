import psycopg2
import os
from tkinter import *
from tkinter import ttk

root = Tk()
root.title('OMOP DB Migration')
root.geometry("500x550")

notebook = ttk.Notebook(root)
notebook.pack(fill='both', expand=True, padx=10, pady=10)

backup_tab = Frame(notebook)
restore_tab = Frame(notebook)

notebook.add(backup_tab, text="Backup")
notebook.add(restore_tab, text="Restore")


def start_backup():
    # ---- Get values from fields ----
    host = ServerName.get()
    db = DBname.get()
    schema = Schema.get()
    port = int(Port.get())
    user = Username.get()
    password = Password.get()

    try:
        # ---- Connect to PostgreSQL ----
        conn = psycopg2.connect(
            host=host,
            dbname=db,
            user=user,
            password=password,
            port=port
        )
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

        # Setup progress bar
        progress['maximum'] = len(tables)
        progress['value'] = 0

        # Export tables
        for i, table in enumerate(tables, start=1):
            table_name = table[0]

            result_label.config(text=f"Exporting {table_name}...")
            root.update_idletasks()

            with open(f"{db}/{table_name}.csv", "w") as f:
                cursor.copy_expert(
                    f'COPY "{schema}"."{table_name}" TO STDOUT WITH CSV HEADER',
                    f
                )

            progress['value'] = i
            root.update_idletasks()

        result_label.config(text="✅ Backup completed successfully!")
        progress['value'] = 0
        conn.close()

    except Exception as e:
        result_label.config(text=f"❌ Error: {e}")

#--------------------------------User interface----------------------------------------------------
Label(backup_tab, text="Server name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
ServerName = Entry(backup_tab, width=50, font=('Times New Roman', 12))
ServerName.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="DB name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
DBname = Entry(backup_tab, width=50, font=('Times New Roman', 12))
DBname.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="Schema name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Schema = Entry(backup_tab, width=50, font=('Times New Roman', 12))
Schema.pack(padx=50, pady=10, anchor="w")

Label(backup_tab, text="Port:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Port = Entry(backup_tab, width=50, font=('Times New Roman', 12))
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

myButton = Button(backup_tab, text="Start...", command=start_backup)
myButton.pack(pady=20, anchor="w",padx=50)

result_label = Label(backup_tab, text="", font=("Times New Roman", 10))
result_label.pack(anchor="w", padx=50)
root.mainloop()