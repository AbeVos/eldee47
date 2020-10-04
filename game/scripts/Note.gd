extends PathFollow

export(float) var speed = 1
export(float) var altitude = 1
export(int) var frequency = 1

var random_offset

func _ready():
    random_offset = 0.5 * PI * randf() - 0.25


func _process(delta):
    unit_offset += speed * delta

    if unit_offset >= 1.0:
        unit_offset = 0.0

    h_offset = altitude * cos(frequency * PI * unit_offset + random_offset)
    v_offset = altitude * sin(2 * frequency * PI * unit_offset + random_offset)
