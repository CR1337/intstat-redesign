import os
import json
from random import random, randint, choice
from string import ascii_letters
import pytest
import json
import mysql.connector
from mysql.connector import Error
from typing import Any, Dict, List

USERNAME: str = "super"

DATABASES: List[Dict[str, str | int]] = [
    {
        "host": "127.0.0.1",
        "port": 3306,
        "user": USERNAME,
        "password": "password",
        "database": "intstat2",
    }
]

USER_TABLE_NAME: str = "nutzer"

TABLE_DEFINITIONS_DIRECTORY: str = os.path.join("database_definition", "tables")

USED_RADNOM_VALUES_FILENAME: str = os.path.join("tests", "tmp", "used_random_values.json")


def pytest_sessionstart(session):
    used_random_values = {
        "INTEGER": [],
        "DATE": [],
        "DOUBLE": [],
        "VARCHAR": [],
        "TINYINT UNSIGNED": []
    }
    with open(USED_RADNOM_VALUES_FILENAME, 'w') as f:
        json.dump(used_random_values, f, indent=4)


def pytest_sessionfinish(session, exitstatus):
    database_config = DATABASES[0]
    connection = mysql.connector.connect(**database_config)

    rows_to_delete = {}

    table_definitions = get_table_definitions()
    for td in table_definitions:
        table_name = td["table_name"]
        if table_name == "nutzer":
            continue
        rows_to_delete[table_name] = []
        view_name = f"tab_{table_name}"

        result = fetch(connection, f"SELECT {table_name}_id, gueltig_seit, ist_aktiv from {view_name};")
        result = sorted(result, key=lambda x: x[1])

        for id_, _, ist_aktiv in result:
            if id_ in rows_to_delete[table_name] and not ist_aktiv:
                rows_to_delete[table_name].remove(id_)
            elif id_ not in rows_to_delete[table_name] and ist_aktiv:
                rows_to_delete[table_name].append(id_)

    for table_name, ids in rows_to_delete.items():
        for id_ in ids:
            cursor = connection.cursor()
            arguments = [id_]
            cursor.callproc(f"delete_from_{table_name}", arguments)
            cursor.close()

    connection.close()


def fetch(connection, statement) -> Any:
    cursor = connection.cursor()
    cursor.execute(statement)
    result = cursor.fetchall()
    cursor.close()
    return result


def run(connection, statement) -> None:
    cursor = connection.cursor()
    cursor.execute(statement)
    cursor.close()


@pytest.fixture(params=DATABASES, ids=[db["database"] for db in DATABASES])
def database_connection(request):
    database_config = request.param
    connection = None

    try:
        connection = mysql.connector.connect(**database_config)
        print(f"Connected to {database_config['database']}.")
    except Error as e:
        print(f"The error {e} occurred for {database_config['database']}.")
        pytest.fail(f"Failed to connect to {database_config['database']}.")

    yield connection, database_config["database"]

    if connection and connection.is_connected():
        connection.close()
        print(f"Connection to {database_config['database']} closed.")


def get_table_definitions():
    filenames = [
        fn for fn in os.listdir(TABLE_DEFINITIONS_DIRECTORY) if fn.endswith(".json")
    ]

    table_definitions = []
    for fn in filenames:
        with open(os.path.join(TABLE_DEFINITIONS_DIRECTORY, fn), "r") as file:
            table_definitions.append(json.load(file))

    return table_definitions


@pytest.fixture(
    params=get_table_definitions(),
    ids=[d["table_name"] for d in get_table_definitions()],
)
def table_definition(request):
    definition = request.param
    yield definition

def get_random_value(type_: str = "INTEGER", quote_text: bool = False) -> Any:
    with open(USED_RADNOM_VALUES_FILENAME, 'r') as f:
        used_random_values = json.load(f)

    result = None

    match type_:
        case "INTEGER":
            while (v := randint(-(2**31), -1)) in used_random_values["INTEGER"]:
                pass
            used_random_values["INTEGER"].append(v)
            result = v

        case "DATE":
            v = None
            while v is None or v in used_random_values["DATE"]:
                year = randint(1970, 2000)
                month = randint(1, 12)
                day = randint(1, 28)
                v = f"{year:04}-{month:02}-{day:02}"
                if quote_text:
                    v = f"'{v}'"
            used_random_values["DATE"].append(v.replace("'", ""))
            result = v

        case "DOUBLE":
            while (v := random()) in used_random_values["DOUBLE"]:
                pass
            used_random_values["DOUBLE"].append(v)
            result = v

        case _ if type_.startswith("VARCHAR(") and type_.endswith(")"):
            v = None
            while v is None or v in used_random_values["VARCHAR"]:
                length = int(type_[8:-1])
                v = "".join(choice(ascii_letters) for _ in range(length))
                if quote_text:
                    v = f"'{v}'"
            used_random_values["VARCHAR"].append(v.replace("'", ""))
            result = v

        case "TINYINT UNSIGNED":
            while (v := randint(0, 255)) in used_random_values["TINYINT UNSIGNED"]:
                pass
            used_random_values["TINYINT UNSIGNED"].append(v)
            result = v

        case "BOOL" | "BOOLEAN":
            result = randint(0, 1)

        case _:
            raise ValueError(f"Unknown type: {type_}")

    with open(USED_RADNOM_VALUES_FILENAME, 'w') as f:
        json.dump(used_random_values, f, indent=4)

    return result


def procedure_insert(connection, table_name, arguments=None) -> List[Any]:
    table_definition = list(
        filter(lambda d: d["table_name"] == table_name, get_table_definitions())
    )[0]

    if arguments is None:
        fk_values = []
        for fk in table_definition["foreign_keys"]:
            if not fk["not_null"]:
                fk_values.append(None)
                continue
            fk_values.append(procedure_insert(connection, fk["references"])[-1])

        table_name = table_definition["table_name"]

        column_values = [
            str(get_random_value(c["type"], quote_text=False))
            for c in table_definition["columns"]
        ]

        arguments = column_values + fk_values + [0]

    cursor = connection.cursor()
    print(f"{arguments=}")
    result = cursor.callproc(f"insert_into_{table_name}", arguments)
    print(f"{result=}")
    cursor.close()

    return result
