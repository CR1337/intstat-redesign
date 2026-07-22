import os
import csv
import mysql.connector
from typing import Dict

INITIAL_DATA_DIRECTORY: str = os.path.join("database_definition", "initial_data")
csv_files = [
    os.path.join(INITIAL_DATA_DIRECTORY, filename)
    for filename in os.listdir(INITIAL_DATA_DIRECTORY)
    if filename.endswith(".csv")
]

connection = mysql.connector.connect(**{
    "host": "127.0.0.1",
    "port": 3306,
    "user": "super",
    "password": "password",
    "database": "intstat2"
})

id_translation: Dict[str, Dict[int, int]] = {}

for csv_file in csv_files:
    table_name = csv_file.split(os.path.sep)[-1].split(".")[0]
    id_translation[table_name] = {}

    with open(csv_file, newline="", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")

        for i, row in enumerate(reader):
            if i == 0:
                continue
            cursor = connection.cursor()

            pseudo_id = row[0]
            values = row[1:]
            arguments = values + [0]
            arguments = [(a if a else "NULL") for a in arguments]

            result = cursor.callproc(f"insert_into_{table_name}", arguments)
            real_id = result[-1]

            id_translation[table_name][pseudo_id] = real_id

            cursor.close()

connection.close()


# TODO
# know what column is a foreign key and perform is translation
# In which order should the tables be filled?