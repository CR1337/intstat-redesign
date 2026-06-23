import os
import json
from random import random, randint, choice
from string import ascii_letters
import pytest
import mysql.connector
from mysql.connector import Error
from typing import Any, Dict, List, Set

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

used_random_values: Dict[str, Set[Any]] = {
    "INTEGER": set(),
    "DATE": set(),
    "DOUBLE": set(),
    "VARCHAR": set(),
    "TINYINT UNSIGNED": set()
}

def get_random_value(type_: str = "INTEGER", quote_text: bool = False) -> Any:
    match type_:
        case "INTEGER":
            while (v := randint(-(2**31), -1)) in used_random_values["INTEGER"]:
                pass
            used_random_values["INTEGER"].add(v)
            return v

        case "DATE":
            v = None
            while v is None or v in used_random_values["DATE"]:
                year = randint(1970, 2000)
                month = randint(1, 12)
                day = randint(1, 28)
                v = f"{year:04}-{month:02}-{day:02}"
                if quote_text:
                    v = f"'{v}'"
            used_random_values["DATE"].add(v)
            return v

        case "DOUBLE":
            while (v := random()) in used_random_values["DOUBLE"]:
                pass
            used_random_values["DOUBLE"].add(v)
            return v

        case _ if type_.startswith("VARCHAR(") and type_.endswith(")"):
            v = None
            while v is None or v in used_random_values["VARCHAR"]:
                length = int(type_[8:-1])
                v = "".join(choice(ascii_letters) for _ in range(length))
                if quote_text:
                    v = f"'{v}'"
            used_random_values["VARCHAR"].add(v)
            return v

        case "TINYINT UNSIGNED":
            while (v := randint(0, 255)) in used_random_values["TINYINT UNSIGNED"]:
                pass
            used_random_values["TINYINT UNSIGNED"].add(v)
            return v

        case "BOOL" | "BOOLEAN":
            return randint(0, 1)

        case _:
            raise ValueError(f"Unknown type: {type_}")


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
