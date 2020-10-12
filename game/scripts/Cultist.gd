extends Spatial

export(AudioStream) var voice
export(String) var central_note = "A4"

var note_scene = preload("res://scenes/Note.tscn")
var current_pitch
var current_note
var uv_offset = Vector3(0, 0, 0)
var viewport
var camera

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

    viewport = get_viewport()
    camera = viewport.get_camera()

    # var target = get_parent().get_parent().get_parent().get_node("Target")
    # set_symbol_target(target)


func _process(_delta):
    var transform = get_global_transform()
    var up = transform * Vector3.UP;
    var screen_pos = normalize_screen_space(
        camera.unproject_position(transform.origin),
        viewport.get_visible_rect().size
    )
    var screen_top = normalize_screen_space(
        camera.unproject_position(up),
        viewport.get_visible_rect().size
    )
    var screen_dir = (screen_top - screen_pos).normalized();
    var mouse_pos = normalize_screen_space(
        viewport.get_mouse_position(),
        viewport.get_visible_rect().size
    )
    var mouse_distance = mouse_pos.distance_to(screen_pos);
    var mouse_dir = (screen_pos - mouse_pos).normalized();
    var dot = mouse_dir.dot(screen_dir);

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


func normalize_screen_space(point, rect):
    var axis = max(rect.x, rect.y)
    return point / axis


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

        center = 0.5 * target  # Average of target and zero vector.

        # Get a vector pointing from start towards target.
        direction = (target - start).normalized()

        # Project the direction vector onto the XZ plane.
        var projection = Vector3(direction.x, 0, -direction.z)

        offset = (direction).cross(projection).normalized()
        offset *= sign(offset.y)

    var curve = $NotePath.get_curve().duplicate(true)
    curve.clear_points()
    curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)

    if spatial != null:
        var magnitude = 0.5 * center.length()

        curve.add_point(
            center + magnitude * offset,
            - magnitude * direction,
            magnitude * direction
        )

    curve.add_point(target, Vector3.ZERO, Vector3.ZERO)

    $NotePath.curve = curve


func get_pitch(quantize=false):
    # Get the cultist's pitch based on arm height.
    # If quantize is true, the pitch will be an integer
    # in {0, ..., N_PITCHES - 1}, otherwise it will be a real number in
    # [0, 1].
    var transform = get_global_transform()
    var up = transform * Vector3.UP;
    var screen_pos = normalize_screen_space(
        camera.unproject_position(transform.origin),
        viewport.get_visible_rect().size
    )
    var screen_top = normalize_screen_space(
        camera.unproject_position(up),
        viewport.get_visible_rect().size
    )
    var screen_dir = (screen_top - screen_pos).normalized();
    var mouse_pos = normalize_screen_space(
        viewport.get_mouse_position(),
        viewport.get_visible_rect().size
    )
    var mouse_distance = mouse_pos.distance_to(screen_pos);
    var mouse_dir = (screen_pos - mouse_pos).normalized();
    var dot = -screen_dir.dot(mouse_dir);
    dot = 0.5 * (dot + 1)

    if not quantize:
        return dot
    else:
        var value = dot * (Globals.N_PITCHES - 1)
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
