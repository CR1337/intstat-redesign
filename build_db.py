import os
import time as t
from typing import List

import mysql.connector
from mysql.connector.errors import OperationalError
from mysql.connector.abstracts import MySQLConnectionAbstract

from variants import Variant, VARIANTS


CREATE_STATEMENT_DIRECTORY: str = "create_statements"


def create_connection(variant: Variant) -> MySQLConnectionAbstract:
    connected = False
    connection = None
    while not connected:
        try:
            connection = mysql.connector.connect(
                host="127.0.0.1",
                port=3306,
                user="user",
                password="password",
                database=f"intstat2_{variant.short_name}"
            )
        except OperationalError:
            print("Waiting for DB server...")
            t.sleep(2)
        else:
            connected = True

    assert isinstance(connection, MySQLConnectionAbstract)
    return connection


def run_statement(
    connection: MySQLConnectionAbstract, 
    statement: str
):
    try:
        cursor = connection.cursor()
    except mysql.connector.OperationalError as error:
        return False, error
    
    try:
        cursor.execute(statement)
        result = cursor.fetchall()
        return True, result
    except mysql.connector.Error as error:
        return False, error
    finally:
        cursor.close()


def load_create_statements(variant: Variant) -> List[str]:
    filename = os.path.join(CREATE_STATEMENT_DIRECTORY, f"create_{variant.name}.sql")
    with open(filename, 'r') as file:
        raw_statements = file.read()
    statements = [
        s.strip()
        for s in raw_statements.split("-- $$")
    ]
    return statements


def main() -> None:
    for variant in VARIANTS:
        print(f"### Buidling database {variant.name}...")
        print()
        connection = create_connection(variant)

        create_statements = load_create_statements(variant)
        for statement in create_statements:
            name = statement.split("\n")[0]
            print(f"RUNNING({variant.short_name}): {name} ...")
            success, result = run_statement(connection, statement)

            if success:
                print(f"Successfully ran {name}.")
            else:
                print(f"ERROR running {name}:")
                print(result)
                exit(1)
            
            print()

        connection.close()


if __name__ == "__main__":
    main()
