import pytest
from mysql.connector.errors import DatabaseError
from tests.conftest import USER_TABLE_NAME, procedure_insert

pytestmark = pytest.mark.order(8)


def test_restrict_duplicates(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']

    if (
        table_name == USER_TABLE_NAME
    ):
        pytest.skip(
            f"No INSERT procedure for {table_name}."
        )

    results = procedure_insert(connection, table_name)
    with pytest.raises(DatabaseError) as exc_info:
        procedure_insert(connection, table_name, arguments=results)

    assert "Einfuegen (INSERT) von Duplikaten (" in str(exc_info.value)
    assert exc_info.value.sqlstate == '45000'
    