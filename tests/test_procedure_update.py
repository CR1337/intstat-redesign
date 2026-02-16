import pytest
from tests.conftest import USER_TABLE_NAME, get_random_value, fetch

pytestmark = pytest.mark.order(6)


def test_procedure_update(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']

    if (
        table_name == USER_TABLE_NAME
    ):
        pytest.skip(
            f"No updates for {table_name}."
        )

    columns = table_definition['columns']
    if len(columns) == 0:
        pytest.skip("No columns to test.")
    column = columns[0]
    print(f"{column=}")

    result = fetch(connection, f"SELECT {table_name}_id FROM view_{table_name}_aktuell LIMIT 1;")
    id_ = result[0][0]
    new_value = get_random_value(column['type'], False)

    result_pre = fetch(connection, f"SELECT gueltig_seit, ist_aktiv FROM tab_{table_name} WHERE {table_name}_id = {id_} ORDER BY gueltig_seit DESC;")
    result_length_pre = len(result_pre)

    arguments = [id_, new_value]
    cursor = connection.cursor()
    cursor.callproc(f"update_value_{table_name}_{column['name']}", arguments)
    cursor.close()

    result_post = fetch(connection, f"SELECT gueltig_seit, ist_aktiv FROM tab_{table_name} WHERE {table_name}_id = {id_} ORDER BY gueltig_seit DESC;")
    result_length_post = len(result_post)

    assert result_length_post == result_length_pre + 1
    assert result_post[0][0] > result_pre[0][0]
    assert bool(result_post[0][1])



   
    