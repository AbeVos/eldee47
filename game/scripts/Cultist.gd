extends Spatial

export(AudioStream) var voice
export(String) var central_note = "A4"

export var low_sound = -10.0
export var high_sound = 10.0
export var low_energy = 0.5
export var high_energy = 5.0

signal grab(cultist)
signal release(cultist)

var note_scene = preload("res://scenes/Note.tscn")
var current_pitch
var current_note
var uv_offset = Vector3(0, 0, 0)
var viewport
var camera
var raw_pitch_value = 0
var pitch_value = 0.5
var old_pitch_value = 0

var mouse_over = false
var dragging = false

var light_energy = 1
var selected = null

func _ready():
    var mat = $Cultist_model/Skeleton/MOD_Cultist.material_override.duplicate(true)
    $Cultist_model/Skeleton/MOD_Cultist.material_override = mat

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

    light_energy = $Spot.light_energy
    $Spot.light_energy = 1


func _process(delta):
    var screen_dir = get_screen_dir()
    var sensitivity = 1.0 / screen_dir.length()
    screen_dir = screen_dir.normalized()

    var mouse_pos = normalize_screen_space(
        viewport.get_mouse_position(),
        viewport.get_visible_rect().size
    )
    var mouse_dir = sensitivity * (get_screen_pos() - mouse_pos);
    var dot = -mouse_dir.dot(screen_dir);

    if dragging:
        raw_pitch_value += (dot - old_pitch_value)

    old_pitch_value = dot
    pitch_value = clamp(0.5 * (raw_pitch_value + 1), 0 ,1)

    # var position = get_global_transform().origin
    var elevation = 2 * pitch_value - 1

    $Cultist_model.raised_val = elevation

    # make those bois a color
    var mat = $Cultist_model/Skeleton/MOD_Cultist.material_override
    mat.albedo_color = Color(1, float(get_pitch(true)) / (Globals.N_PITCHES - 1), 0)
    $Cultist_model/Skeleton/MOD_Cultist.material_override = mat

    var pitch = get_pitch(true)

    if pitch != current_pitch:
        # Pitch has changed.
        sing(pitch)

    var target_db = 0
    var target_energy = 1

    if selected == null:
        target_db = 0
        # $Spot.light_energy = 1
        target_energy = 1
    elif selected:
        target_db = high_sound
        target_energy = high_energy
    else:
        target_db = low_sound
        target_energy = low_energy

    $Tones/Voice_1.unit_db = lerp($Tones/Voice_1.unit_db, target_db, 2 * delta)
    $Spot.light_energy = lerp($Spot.light_energy, target_energy, 2 * delta)


func _input(event):
    if event is InputEventMouseButton:
        var start_dragging = mouse_over and event.is_pressed()
        if start_dragging and not dragging:
            emit_signal("grab", self)
            dragging = true
        elif not start_dragging and dragging:
            emit_signal("release", self)
            dragging = false

###########
# Signals #
###########
func _on_NoteTimer_timeout():
    var note_inst = note_scene.instance()
    $NotePath.add_child(note_inst)
    note_inst.set_note(current_note)


func _on_Area_mouse_entered():
    mouse_over = true


func _on_Area_mouse_exited():
    mouse_over = false


func normalize_screen_space(point, rect):
    var axis = max(rect.x, rect.y)
    return point / axis


func set_symbol_target(spatial):
    # Set the target spatial for sending particles towards.
    # print("Set target to %s" % spatial)

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
    if not quantize:
        return pitch_value
    else:
        var value = pitch_value * (Globals.N_PITCHES - 1)
        return int(round(value))


func get_screen_pos():
    # Get this object's current position projected on the view.
    return normalize_screen_space(
        camera.unproject_position(transform.origin),
        viewport.get_visible_rect().size
    )


func get_screen_dir():
    # Get this objects vertical axis projected on the view.
    var transform = get_global_transform()
    var up = transform * Vector3.UP;
    var screen_pos = get_screen_pos()
    var screen_top = normalize_screen_space(
        camera.unproject_position(up),
        viewport.get_visible_rect().size
    )
    return screen_top - screen_pos


func get_note():
    return current_note


func lerp(a, b, t):
    return (1 - t) * a + t * b


func sing(pitch):
    print(pitch)
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


func set_selected(active):
    selected = active
