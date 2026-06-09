import streamlit as st
from typing import Optional
import pandas as pd
from streamlit.connections.sql_connection import SQLConnection
from sqlalchemy import text


def initialize() -> None:
    if st.session_state.get("db_connection_available") is None:
        st.session_state["db_connection_available"] = False
        st.session_state["db_connection"] = None
        st.session_state["db_connection_failed"] = False
        st.session_state["db_connection_username"] = None


def connection_failed() -> bool:
    return st.session_state["db_connection_failed"]


def is_connected() -> bool:
    return st.session_state["db_connection_available"]


def get_username() -> Optional[str]:
    return st.session_state["db_connection_username"]


def get_connection() -> SQLConnection:
    return st.session_state["db_connection"]


def connect(username: str, password: str) -> None:
    try:
        st.session_state["db_connection"] = st.connection(
            "db_connection",
            type="sql",
            url=f"mysql://{username}:{password}@127.0.0.1:3306/intstat2",
        )
    except Exception:
        st.session_state["db_connection_available"] = False
        st.session_state["db_connection_failed"] = True
        raise
    else:
        st.session_state["db_connection_available"] = True
        st.session_state["db_connection_failed"] = False
        st.session_state["db_connection_username"] = username


def disconnect() -> None:
    del st.session_state["db_connection_available"]
    del st.session_state["db_connection"]
    del st.session_state["db_connection_failed"]
    del st.session_state["db_connection_username"]


def render_connection_ui() -> None:
    if is_connected():
        st.badge(
            f"Benutzername: {get_username()}", icon=":material/check:", color="green"
        )
        if st.button("Abmelden"):
            disconnect()
            st.rerun()
    else:
        username = st.text_input(label="Benutzername:")
        password = st.text_input(label="Passwort:", type="password")
        if connection_failed():
            st.badge("Fehler beim Anmelden", icon=":material/close:", color="red")
        if st.button("Anmelden"):
            connect(username, password)
            st.rerun()


def render_not_connected_ui() -> None:
    st.badge("Bitte anmelden!", width="stretch", icon=":material/close:", color="red")


def get_themen() -> pd.DataFrame:
    with get_connection().session as s:
        result = s.execute(text("SELECT * FROM view_themen_aktuell;"))
        df = pd.DataFrame.from_records(result.fetchall(), columns=result.keys())  # type: ignore
        return df
