extends Spatial

export(int) var n_notes = 3

var current_pitch
var path_length


func _ready():
    var mat = $Body.get_surface_material(0).duplicate(true)
    $Body.set_surface_material(0, mat)

    current_pitch = get_pitch(true)

    var target = get_parent().get_parent().get_parent().get_node("Target")
    _on_Monster_set_target(target)


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

    if get_pitch(true) != current_pitch:
        sing()

    $NotePath/Note.offset += delta * path_length

    if $NotePath/Note.offset >= path_length:
        $NotePath/Note.offset = 0


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


func _on_Monster_set_target(spatial):
    var target = spatial.get_global_transform()
    target = global_transform.inverse() * target

    var curve = $NotePath.get_curve().duplicate(true)
    curve.clear_points()
    curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.UP)
    curve.add_point(target.origin, Vector3.UP, Vector3.ZERO)
    print(curve.get_baked_points())

    path_length = curve.get_baked_length()

    $NotePath.curve = curve
    $NotePath/Note.offset = $NotePath.get_curve().get_baked_length() - 0.9


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

    var tones = $Tones.get_children()

    tones[current_pitch].stop()
    tones[pitch].play(0.0)
    current_pitch = pitch
