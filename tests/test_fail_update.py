import pytest
from mysql.connector.errors import DatabaseError
from tests.conftest import USER_TABLE_NAME, run

pytestmark = pytest.mark.order(4)


def test_fail_update(database_connection, table_definition):
    connection, db_name = database_connection
    table_name = table_definition['table_name']
    
    if (
        db_name == "intstat2_wot" 
        and table_name == USER_TABLE_NAME
    ):
        pytest.skip(
            f"No table {table_name} to test in {db_name}."
        )

    with pytest.raises(DatabaseError) as exc_info:
        run(connection, f"UPDATE tab_{table_name} SET ist_aktiv = FALSE;")

    assert "Aktualisieren (UPDATE) von Einträgen ist nicht erlaubt!" in str(exc_info.value)
    assert exc_info.value.sqlstate == '45000'
