import streamlit as st
import init
import db_connection

init.initialize()

with st.sidebar:
    db_connection.render_connection_ui()
