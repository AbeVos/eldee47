extends PathFollow

export(float) var speed = 1
export(float) var altitude = 1
export(int) var frequency = 1


func _process(delta):
    unit_offset += speed * delta

    var offset = altitude * sin(frequency * PI * unit_offset)

    h_offset = offset
    v_offset = offset
