import pytest
from tests.conftest import USER_TABLE_NAME, procedure_insert, fetch

pytestmark = pytest.mark.order(2)


def test_procedure_insert(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']

    if (
        table_name == USER_TABLE_NAME
    ):
        pytest.skip(
            f"No INSERT procedure for {table_name}."
        )

    result = fetch(connection, f"SELECT * from tab_{table_name};")
    result_length_pre = len(result)

    procedure_insert(connection, table_name)

    result = fetch(connection, f"SELECT * from tab_{table_name};")
    result_length_post = len(result)

    assert result_length_post == result_length_pre + 1
    