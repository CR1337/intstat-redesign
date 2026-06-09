from __future__ import annotations
import streamlit as st
import db_connection
import init
import pandas as pd
from dataclasses import dataclass
from typing import Tuple


@dataclass
class Thema:
    @classmethod
    def empty(cls) -> Thema:
        return cls("", "", (0, 0, 0))

    name_de: str
    name_en: str
    farbe: Tuple[int, int, int]

    @staticmethod
    def farbe_to_hex(farbe: Tuple[int, int, int]) -> str:
        code = hex(farbe[0] << 16 + farbe[1] << 8 + farbe[0])[2:]
        while len(code) < 6:
            code = "0" + code
        return f"#{code}"

    @staticmethod
    def hex_to_farbe(hex_string: str) -> Tuple[int, int, int]:
        return (
            int(hex_string[1:][0:2], 16),
            int(hex_string[1:][2:4], 16),
            int(hex_string[1:][4:6], 16),
        )


def render_themen_editor(thema: Thema) -> Thema:
    name_de = st.text_input("Deutscher Name:", thema.name_de)
    name_en = st.text_input("Englischer Name:", thema.name_en)
    farbe = Thema.hex_to_farbe(
        st.color_picker("Farbe:", Thema.farbe_to_hex(thema.farbe))
    )
    return Thema(name_de, name_en, farbe)


def render() -> None:
    if not db_connection.is_connected():
        db_connection.render_not_connected_ui()
        return

    themen_df = db_connection.get_themen()
    st.data_editor(themen_df)

    render_themen_editor(Thema.empty())


init.initialize()
render()
