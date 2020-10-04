extends Spatial

export(AudioStream) var voice
export(String) var central_note = "A4"

var note_scene = preload("res://scenes/Note.tscn")
var current_pitch
var current_note
var uv_offset = Vector3(0, 0, 0)


func _ready():
    var mat = $Body.get_surface_material(0).duplicate(true)
    $Body.set_surface_material(0, mat)

    current_pitch = null
    current_note = null

    assert(voice != null)
    $Tones/Voice_1.stream = voice
    $Tones/Voice_1.playing = true

    # Make sure the note symbols float upwards.
    set_symbol_target(null)

    var note_inst = note_scene.instance()
    $NotePath.add_child(note_inst)
    note_inst.set_note(central_note)


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
    mat.albedo_color = Color(
        1, float(get_pitch(true)) / (Globals.N_PITCHES - 1), 0
    )
    $Body.set_surface_material(0, mat)

    var pitch = get_pitch(true)

    if pitch != current_pitch:
        # Pitch has changed.
        sing(pitch)


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


func _on_NoteTimer_timeout():
    var note_inst = note_scene.instance()
    $NotePath.add_child(note_inst)
    note_inst.set_note(current_note)


func set_symbol_target(spatial):
    # Set the target spatial for sending particles towards.
    print("Set target to %s" % spatial)

    var start = get_global_transform().origin

    var target
    var center
    var offset
    var direction

    if spatial == null:
        target = 3 * Vector3.UP
    else:
        target = spatial.get_global_transform()
        target = (global_transform.inverse() * target).origin

        center = 0.5 * (start + target)

        # Get a vector pointing from start towards target.
        direction = (target - start).normalized()

        # Project the direction vector onto the XZ plane.
        var projection = Vector3(direction.x, 0, -direction.z).normalized()

        offset = (direction).cross(projection).normalized()

    var curve = $NotePath.get_curve().duplicate(true)
    curve.clear_points()
    curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)

    if spatial != null:
        curve.add_point(
            center + 2 * offset,
            -direction,
            direction
        )

    curve.add_point(target, Vector3.ZERO, Vector3.ZERO)

    $NotePath.curve = curve


func get_pitch(quantize=false):
    # Get the cultist's pitch based on arm height.
    # If quantize is true, the pitch will be an integer
    # in {0, ..., N_PITCHES - 1}, otherwise it will be a real number in
    # [0, 1].
    if not quantize:
        return ($Left.value + $Right.value) / 2
    else:
        var value = get_pitch(false) * (Globals.N_PITCHES - 1)
        return int(round(value))


func get_note():
    return current_note


func sing(pitch):
    # Change pitch.
    $Tones/Voice_1.pitch_scale = Globals.PITCH_SCALES[pitch]

    var note_idx = Globals.NOTES.keys().find(central_note);
    assert(note_idx >= 0)

    # Collect the notes based on semitone distance from the central note.
    var notes = [
        Globals.NOTES.keys()[note_idx - Globals.SEMITONES],
        central_note,
        Globals.NOTES.keys()[note_idx + Globals.SEMITONES],
    ]

    current_pitch = pitch
    current_note = notes[pitch]

    # var note_inst = note_scene.instance()
    # $NotePath.add_child(note_inst)
    # note_inst.set_note(notes[pitch])
