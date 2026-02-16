import pytest
from tests.conftest import procedure_insert, fetch

pytestmark = pytest.mark.order(3)


def test_user_tracking(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']

    if (
        db_name == "intstat2_wot"
    ):
        pytest.skip(
            f"No user tracking for {db_name}."
        )

    new_id = procedure_insert(connection, table_name)[-1]

    result = fetch(connection, f"SELECT ersteller_nutzer_id FROM view_{table_name}_aktuell WHERE {table_name}_id = {new_id};")

    assert len(result) == 1
    ersteller_nutzer_id = result[0][0]

    result = fetch(connection, f"SELECT nutzer_id FROM view_nutzer_aktuell WHERE nutzer_id = {ersteller_nutzer_id};")

    assert len(result) == 1
    assert result[0][0] == ersteller_nutzer_id
