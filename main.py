from tkinter import *

root = Tk()
root.title('OMOP DB Migration')
root.geometry("500x550")

def myClick():
    #hello = "Password is  " + Password.get()
    #myLabel = Label(root, text=hello)
    #Password.delete(0, 'end')
    myLabel.pack(pady=10)

Label(root, text="Server name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
ServerName = Entry(root, width=50, font=('Times New Roman', 12))
ServerName.pack(padx=50, pady=10, anchor="w")

Label(root, text="DB name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
DBname = Entry(root, width=50, font=('Times New Roman', 12))
DBname.pack(padx=50, pady=10, anchor="w")

Label(root, text="Schema name:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Schema = Entry(root, width=50, font=('Times New Roman', 12))
Schema.pack(padx=50, pady=10, anchor="w")

Label(root, text="Port:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Port = Entry(root, width=50, font=('Times New Roman', 12))
Port.pack(padx=50, pady=10, anchor="w")


Label(root, text="Username:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Username = Entry(root, width=50, font=('Times New Roman', 12))
Username.pack(padx=50, pady=10, anchor="w")

Label(root, text="Password:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
Password = Entry(root, width=50, show="*",font=('Times New Roman', 12))
Password.pack(padx=50, pady=10, anchor="w")

# Radiobutton – single choice from a set
Label(root, text="RDBMS:", font=("Times New Roman", 10, "bold")).pack(anchor="w",padx=50)
radio_var = StringVar(value="Option 1")
rb1 = Radiobutton(root, text="PostgreSQL", variable=radio_var, value="Option 1")
rb2 = Radiobutton(root, text="Microsoft SQL Server", variable=radio_var, value="Option 2")
rb3 = Radiobutton(root, text="MYSQL", variable=radio_var, value="Option 3")
rb1.pack(anchor="w",padx=50)
rb2.pack(anchor="w",padx=50)
rb3.pack(anchor="w",padx=50)

myButton = Button(root, text="Start...", command=myClick)
myButton.pack(pady=20, anchor="w",padx=50)

root.mainloop()