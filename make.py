from __future__ import annotations
import os
import json
from uuid import uuid4
from typing import Any, Dict, List

from jinja2 import Environment, PackageLoader, select_autoescape

from variants import Variant, VARIANTS


TABLE_DEFINITION_DIRECTORY: str = "table_definitions"
SQL_DIRECTORY: str = "sql"
SQL_TEMPLATE_DIRECTORY: str = os.path.join("templates", SQL_DIRECTORY)
DOCUMENTATION_FILENAME: str = os.path.join("doc", "documentation.md")
USER_TABLE_NAME: str = "nutzer"

CREATE_STATEMENT_DIRECTORY: str = "create_statements"
ORDERED_CREATE_STATEMENT_TYPES: List[str] = [
    "functions",
    "tables",
    "foreign_keys",
    "indices",
    "views",
    "triggers",
    "procedures"
]
ORDERED_TABLE_NAMES: List[str] = [
    USER_TABLE_NAME,
    "quellen", "themen", "einheiten", "laendernamen", "kontinente", "laendergruppen",
    "indikatoren", "laender",
    "daten", "laendergruppenzuordnungen"
]


def get_all_table_definitions() -> Dict[str, Dict[str, Any]]:
    json_filenames = [
        filename
        for filename 
        in os.listdir(TABLE_DEFINITION_DIRECTORY)
        if filename.endswith(".json")
    ]

    definitions = {}

    for filename in json_filenames:
        with open(os.path.join(TABLE_DEFINITION_DIRECTORY, filename), 'r') as file:
            definition = json.load(file)
        
        definitions[definition['table_name']] = definition

    return definitions


def make_create_statement(
    env: Environment, 
    table_definitions: Dict[str, Dict[str, Any]], 
    variant: Variant
) -> str:
    statements = []

    for statement_type in ORDERED_CREATE_STATEMENT_TYPES:
        per_db_directory = os.path.join(
            SQL_TEMPLATE_DIRECTORY,
            statement_type, 
            "per_db"
        )
        per_table_directory = os.path.join(
            SQL_TEMPLATE_DIRECTORY,
            statement_type, 
            "per_table"
        )
        per_fk_directory = os.path.join(
            SQL_TEMPLATE_DIRECTORY,
            statement_type, 
            "per_fk"
        )
        per_column_directory = os.path.join(
            SQL_TEMPLATE_DIRECTORY,
            statement_type, 
            "per_column"
        )

        per_db_filenames = [
            fn 
            for fn in os.listdir(per_db_directory) 
            if fn.endswith(".jinja2")
        ]
        per_table_filenames = [
            fn 
            for fn in os.listdir(per_table_directory) 
            if fn.endswith(".jinja2")
        ]
        per_fk_filenames = [
            fn 
            for fn in os.listdir(per_fk_directory) 
            if fn.endswith(".jinja2")
        ]
        per_column_filenames = [
            fn 
            for fn in os.listdir(per_column_directory) 
            if fn.endswith(".jinja2")
        ]

        per_db_directory = os.path.join(*per_db_directory.split(os.path.sep)[1:])
        per_table_directory = os.path.join(*per_table_directory.split(os.path.sep)[1:])
        per_fk_directory = os.path.join(*per_fk_directory.split(os.path.sep)[1:])
        per_column_directory = os.path.join(*per_column_directory.split(os.path.sep)[1:])

        for filename in per_db_filenames:
            template = env.get_template(os.path.join(per_db_directory, filename))
            parameters = {
                "user_tracking": variant.user_tracking
            }
            statement = template.render(parameters)
            statements.append(statement)

        for filename in per_table_filenames:
            template = env.get_template(os.path.join(per_table_directory, filename))
            parameters = {
                "user_tracking": variant.user_tracking
            }
            for table_name in ORDERED_TABLE_NAMES:
                table_definition = table_definitions[table_name]
                parameters |= table_definition
                statement = template.render(parameters)
                statements.append(statement)

        for filename in per_fk_filenames:
            template = env.get_template(os.path.join(per_fk_directory, filename))
            parameters = {
                "user_tracking": variant.user_tracking
            }
            for table_name in ORDERED_TABLE_NAMES:
                table_definition = table_definitions[table_name]
                parameters |= table_definition
                for fk in table_definition["foreign_keys"]:
                    parameters |= {"fk": fk}
                    statement = template.render(parameters)
                    statements.append(statement)

        for filename in per_column_filenames:
            template = env.get_template(os.path.join(per_column_directory, filename))
            parameters = {
                "user_tracking": variant.user_tracking
            }
            for table_name in ORDERED_TABLE_NAMES:
                table_definition = table_definitions[table_name]
                parameters |= table_definition
                columns = [
                    {"name": c["name"], "type": c["type"]}
                    for c in table_definition["columns"]
                ] + [
                    {"name": fk["name"], "type": "INTEGER"}
                    for fk in table_definition["foreign_keys"]
                ]
                for column in columns:
                    parameters |= {"column": column}
                    statement = template.render(parameters)
                    statements.append(statement)

    statements = [s for s in statements if "DO 1;" not in s]
    result = "\n\n-- $$\n\n".join(statements)
    return result


def make_diagram(
    env: Environment, 
    table_definitions: Dict[str, Dict[str, Any]], 
    variant: Variant
) -> str:
        template = env.get_template("diagram.mermaid.jinja2")
        parameters = {
            "tables": table_definitions.values(),
            "user_tracking": variant.user_tracking
        }
        diagram = template.render(parameters)
        return diagram


def make_documentation(
    env: Environment,
    diagrams: Dict[Variant, str],
    table_definitions: Dict[str, Dict[str, Any]]
) -> str:
    template = env.get_template("documentation.md.jinja2")
    parameters = {
        "tables": table_definitions.values()
    } | {
        f"diagram_{variant.name}": diagram
        for variant, diagram in diagrams.items()
    }
    documentation = template.render(parameters)
    return documentation


def main() -> None:
    env = Environment(
        loader=PackageLoader("make"),
        autoescape=select_autoescape(),
        trim_blocks=True,
        lstrip_blocks=True
    )
    env.globals.update(uuid = lambda: "".join(s for s in str(uuid4()).split("-")[:-1]))

    table_definitions = get_all_table_definitions()

    for variant in VARIANTS:
        create_statement = make_create_statement(env, table_definitions, variant)
        output_filename = os.path.join(
            CREATE_STATEMENT_DIRECTORY,
            f"create_{variant.name}.sql"
        )
        with open(output_filename, 'w') as file:
            file.write(create_statement)

    diagrams = {
        variant: make_diagram(
            env,
            table_definitions,
            variant
        )
        for variant in VARIANTS
    }

    documentation = make_documentation(
        env,
        diagrams,
        table_definitions
    )

    with open(DOCUMENTATION_FILENAME, 'w') as file:
        file.write(documentation)

    


if __name__ == "__main__":
    main()
