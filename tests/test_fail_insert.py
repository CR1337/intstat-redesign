import pytest
from mysql.connector.errors import DatabaseError
from tests.conftest import USER_TABLE_NAME, get_random_value, run

pytestmark = pytest.mark.order(1)


def test_fail_insert(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']
    
    if (
        db_name == "intstat2_wot" 
        and table_name == USER_TABLE_NAME
    ):
        pytest.skip(
            f"No table {table_name} to test in {db_name}."
        )

    column_values = [
        str(get_random_value(c['type'], quote_text=True))
        for c in table_definition['columns']
    ]
    print(column_values)
    fk_values = [
        str(get_random_value(quote_text=True))
        for _ in table_definition['foreign_keys']
    ]

    with pytest.raises(DatabaseError) as exc_info:
        run(connection, "".join([
            f"INSERT INTO tab_{table_name}(",
            ",".join(c['name'] for c in table_definition["columns"]),
            "," if len(table_definition['foreign_keys']) and len(table_definition['columns']) else "",
            ",".join(f"{fk['name']}_id" for fk in table_definition["foreign_keys"]),
            ") VALUES (",
            ",".join(column_values),
            "," if len(table_definition['foreign_keys']) and len(table_definition['columns']) else "",
            ",".join(fk_values),
            ");"
        ]))

    assert "Einfügen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!" in str(exc_info.value)
    assert exc_info.value.sqlstate == '45000'
