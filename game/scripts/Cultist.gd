extends Spatial

export(int) var n_notes = 5


func _ready():
    var mat = $Body.get_surface_material(0).duplicate(true)
    $Body.set_surface_material(0, mat)


func _process(delta):
    if $Right.locked:
        var position = $Left/Hand.transform.origin
        position.x *= -1
        $Right/Hand.transform.origin = position
    elif $Left.locked:
        var position = $Right/Hand.transform.origin
        position.x *= -1
        $Left/Hand.transform.origin = position

    var mat = $Body.get_surface_material(0)
    # print(get_pitch(), get_pitch(true) / n_notes)
    mat.albedo_color = Color(1, float(get_pitch(true)) / (n_notes - 1), 0)
    $Body.set_surface_material(0, mat)


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
