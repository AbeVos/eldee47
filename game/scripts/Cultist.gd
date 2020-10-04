extends Spatial

export var notes = {
    0: 0.749,
    1: 1.0,
    2: 1.335,
}

var n_notes
var current_pitch


func _ready():
    var mat = $Body.get_surface_material(0).duplicate(true)
    $Body.set_surface_material(0, mat)

    n_notes = len(notes)

    current_pitch = get_pitch(true)


func _process(_delta):
    if $Right.locked:
        var position = $Left/Hand.transform.origin
        position.x *= -1
        $Right/Hand.transform.origin = position
    elif $Left.locked:
        var position = $Right/Hand.transform.origin
        position.x *= -1
        $Left/Hand.transform.origin = position

    var mat = $Body.get_surface_material(0)
    mat.albedo_color = Color(1, float(get_pitch(true)) / (n_notes - 1), 0)
    $Body.set_surface_material(0, mat)

    if get_pitch(true) != current_pitch:
        sing()


###########
# Signals #
###########
func _on_Left_grabbed():
    $Right.locked = true


func _on_Right_grabbed():
    $Left.locked = true


func _on_Left_released():
    $Right.locked = false


func _on_Right_released():
    $Left.locked = false


func get_pitch(quantize=false):
    # Get the cultist's pitch based on arm height.
    # If quantize is true, the pitch will be an integer
    # in {0, ..., n_notes - 1}, otherwise it will be a real number in
    # [0, 1].
    if not quantize:
        return ($Left.value + $Right.value) / 2
    else:
        var value = get_pitch(false) * (n_notes - 1)
        return int(round(value))


func sing():
    var pitch = get_pitch(true)

    # Change pitch.
    $Tones/Voice_1.pitch_scale = notes[pitch]

    current_pitch = pitch
