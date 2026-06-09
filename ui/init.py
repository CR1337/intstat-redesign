import streamlit as st
import db_connection


def initialize() -> None:
    db_connection.initialize()
