extends Spatial

signal send_assignments(group_key, assignment)

const CultistResource = preload("res://scenes/Cultist.tscn")

export var groups = {
    1: [0, 1, 2],
    2: [1, 3, 5],
    3: [2, 4, 6],
}
export var tones = ["C", "E", "G"]


func _on_Metronome_timeout():
    # Collect symbols.
    var symbols = []

    for cultist in $Cultists.get_children():
        symbols.append(cultist.get_pitch(true))

    # Assign symbols to groups.
    var assignments = assign_symbols(symbols)

    # Notify group managers.
    for group_key in groups:
        emit_signal("send_assignments", group_key, assignments[group_key])

    print(symbols)
    print(assignments)


func assign_symbols(symbols):
    # Go through each singer's symbol and assign them to the first group
    # that has no singer assigned for that group.
    var assignments = init_group_assignments()

    for symbol_idx in range(len(symbols)):
        var symbol = symbols[symbol_idx]

        for group_key in groups:
            var group = groups[group_key]

            # Flag to check if the symbol has been assigned.
            var found = false

            for group_symbol_idx in range(len(group)):
                if assignments[group_key][group_symbol_idx] != null:
                    continue

                if symbol == group[group_symbol_idx]:
                    assignments[group_key][group_symbol_idx] = symbol_idx
                    found = true
                    break

            if found:
                break

    return assignments


func init_group_assignments():
    # Create an empty nested array M.
    # The value M[i][j] for group i and group component j is the index
    # of the singer.
    var assignments = {}

    for group_key in groups:
        var group = groups[group_key]
        assignments[group_key] = []

        for symbol in group:
            assignments[group_key].append(null)

    return assignments
