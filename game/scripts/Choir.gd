extends Spatial

const CultistResource = preload("res://scenes/Cultist.tscn")

export var groups = [
    [0, 1, 2],
    [1, 3, 5],
    [2, 4, 6],
]
export var tones = ["C", "E", "G"]


func _on_Metronome_timeout():
    # Collect symbols.
    var symbols = []

    for cultist in $Cultists.get_children():
        symbols.append(cultist.get_pitch(true))

    assign_symbols(symbols)


func assign_symbols(symbols):
    # Go through each singer's symbol and assign them to the first group
    # that has no singer assigned for that group.
    var assignments = init_group_assignments()

    for symbol_idx in range(len(symbols)):
        var symbol = symbols[symbol_idx]

        for group_idx in range(len(groups)):
            var group = groups[group_idx]

            # Flag to check if the symbol has been assigned.
            var found = false

            for group_symbol_idx in range(len(group)):
                if assignments[group_idx][group_symbol_idx] != null:
                    continue

                if symbol == group[group_symbol_idx]:
                    assignments[group_idx][group_symbol_idx] = symbol_idx
                    found = true
                    break

            if found:
                break

    return assignments


func init_group_assignments():
    # Create an empty nested array M.
    # The value M[i][j] for group i and group component j is the index
    # of the singer.
    var assignments = []

    for group_idx in range(len(groups)):
        var group = groups[group_idx]
        assignments.append([])

        for symbol in group:
            assignments[group_idx].append(null)

    return assignments
