from shiny import App
from ui import app_ui
from server import app_server


app = App(ui=app_ui, server=app_server)
