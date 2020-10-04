extends PathFollow

const NOTE_GRID_ROWS = 2
const NOTE_GRID_COLS = 2

export(float) var speed = 1
export(float) var altitude = 1
export(int) var frequency = 1

var random_offset
var current_note
var material

func _ready():
    random_offset = 0.5 * PI * randf() - 0.25

    material = $NoteParticle.material_override.duplicate(true)
    $NoteParticle.material_override = material


func _process(delta):
    unit_offset += speed * delta

    if unit_offset >= 1.0:
        queue_free()

    h_offset = altitude * cos(frequency * PI * unit_offset + random_offset)
    v_offset = altitude * sin(2 * frequency * PI * unit_offset + random_offset)


func set_note(note):
    current_note = note
    var index = Globals.NOTES[note]

    index = index % (NOTE_GRID_ROWS * NOTE_GRID_COLS)

    # Change note sprite.
    var col = index % NOTE_GRID_ROWS
    var row = (index - col) / NOTE_GRID_COLS

    var u = float(row) / NOTE_GRID_ROWS
    var v = float(col) / NOTE_GRID_COLS
    var uv_offset = Vector3(u, v, 0)

    material.uv1_offset = uv_offset
    $NoteParticle.material_override = material
