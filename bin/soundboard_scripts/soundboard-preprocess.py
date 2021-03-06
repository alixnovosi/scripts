#!/usr/bin/env python3
import json

# If you change this be sure to change it everywhere in the main ahk file too.
bank_size = 8

input_file = "soundboard_data.json"
output_file = "soundboard_data.ahk"

def indent(indent_level):
    return (indent_level * 4) * " "


def main():
    with open(input_file) as f:
        data = json.load(f)

    default = data["default"]
    if str(data["version"]) == "1.0.0":
        flat_banks = data["sounds"]
        flat_descriptions = data["bank_descriptions"]

    # 2.0.0+
    else:
        # split multi-list data into single list for easier processing.
        flat_banks = []
        flat_descriptions = []

        for bank in data["banks"]:
            # fix slot ids as well.
            fixed_slots = []
            bi = bank["bank_id"]
            for slot in bank["slots"]:
                rel_id = slot["slot"]
                slot["slot"] = (bank_size * (bi-1)) + rel_id
                fixed_slots.append(slot)

            flat_banks.extend(fixed_slots)
            flat_descriptions.append(bank["description"])

    # format for function injection into autohotkey.
    output = []

    indent_level = 0

    output.append("PlaySound(idx) {")
    indent_level += 1

    output.append(f"{indent(indent_level)} Switch (idx) " + "{")
    indent_level += 1

    # do bank 1 description first and then do others on mod rollover.
    old_bank_idx = 0
    bank_idx = 0
    output.append("")
    output.append(f"{indent(indent_level)}; {flat_descriptions[bank_idx]}")

    # I want to permit out-of-order definitions in the JSON,
    # as well as leaving gaps in the soundboard for later ideas.
    # No promises if you add multiple items with the same slot key.
    for sound in sorted(flat_banks, key=lambda x: x["slot"]):

        slot = sound["slot"]
        old_bank_idx = bank_idx
        bank_idx = slot // bank_size
        if (old_bank_idx != bank_idx) and (bank_idx < len(flat_descriptions)):
                output.append("")
                output.append(f"{indent(indent_level)}; {flat_descriptions[bank_idx]}")

        output.append("")
        output.append(f"{indent(indent_level)}; {sound['description']}")

        output.append(f"{indent(indent_level)}case {slot}:")
        indent_level += 1

        output.append(f"{indent(indent_level)}SoundPlay, {sound['filename']}")
        output.append(f"{indent(indent_level)}return")
        indent_level -= 1

    output.append("")
    output.append(f"{indent(indent_level)}; Default!")
    output.append(f"{indent(indent_level)}default:")
    indent_level += 1

    output.append(f"{indent(indent_level)}SoundPlay, {default['filename']}")
    output.append(f"{indent(indent_level)}return")
    indent_level -= 1

    output.append("")
    output.append(f"{indent(indent_level)}" + "}")
    output.append(f"{indent(indent_level)}return")

    indent_level -= 1
    output.append("")
    output.append(f"{indent(indent_level)}" + "}")

    out = "\n".join(output) + "\n"
    with open(output_file, "w") as f:
        f.write(out)


if __name__ == "__main__":
    main()
