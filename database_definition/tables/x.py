import os
import json

filenames = [fn for fn in os.listdir(".") if fn.endswith(".json")]

for filename in filenames:
    with open(filename, "r", encoding="utf-8") as f:
        data = json.load(f)

    for column in data["columns"]:
        column["description"] = "TODO"
    for fk in data["foreign_keys"]:
        fk["diagram_description"] = fk["description"]
        fk["description"] = "TODO"

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)
