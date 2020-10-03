extends Spatial

const CultistResource = preload("res://scenes/Cultist.tscn")

var notes = []


func _on_Metronome_timeout():
    notes = []

    for cultist in $Cultists.get_children():
        notes.append(cultist.get_pitch(true))

    print(notes)
