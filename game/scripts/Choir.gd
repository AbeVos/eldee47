extends Spatial

signal send_assignments(group_key, assignment)

const CultistResource = preload("res://scenes/Cultist.tscn")

export var groups = {
    0: [0, 1, 2],
    1: [1, 3, 5],
    2: [2, 4, 6],
}
export var tones = ["C", "E", "G"]

func _ready():
    hat_colors()


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

    print("symbols: ", symbols)
    print("assignments: ", assignments)


func _on_Monster_set_target(cultist_index, target):
    print("AAAHHH")
    $Cultists.get_children()[cultist_index].set_symbol_target(target)


func assign_symbols(symbols):
    # Go through each singer's symbol and assign them to the first group
    # that has no singer assigned for that group.
    var assignments = init_group_assignments()
    #print("init_group_assignments: ", assignments)

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


func hat_colors():
    var colors = ["#E8ECFB", "#B997C7", "#824D99", "#4E78C4", "#57A2AC", "#7EB875", "#D0B541","#E67F33", "#CE2220", "#521A13"]
    for i in range(0, $Cultists.get_child_count()):
        var hat = $Cultists.get_child(i).get_node("Hat")

        var mat = hat.get_surface_material(0).duplicate(true)
        mat.albedo_color = colors[i]
        hat.set_surface_material(0, mat)
