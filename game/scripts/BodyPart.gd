extends MeshInstance

signal body_part_complete
signal body_part_failed

export(Vector3) var hidden_pos = Vector3(0,-10,0)
export(Vector3) var visible_pos = Vector3(0,0,0)

const PROGRESS_VALUE = 6
const REGRESS_VALUE = 1

onready var body_part_progress = 30
onready var is_active = true

func _ready():
    transform.origin = hidden_pos

func increment_part():
    if (is_active):
        body_part_progress += PROGRESS_VALUE


func update_body_part():
    if (is_active):
        body_part_progress -= REGRESS_VALUE

        if (body_part_progress >= 100):
            emit_signal("body_part_complete")
            is_active = false

        if (body_part_progress <= 0):
            emit_signal("body_part_failed")
            is_active = false
            $Mesh.visible = false

    #print("body_part_progress: ", body_part_progress)


func _on_IncrementTimer_timeout():
    update_body_part()

func _process(_delta):
    # var last_scale = $Mesh.scale
    # var new_scale = Vector3(last_scale.x, body_part_progress / 100.0, last_scale.z)
    # $Mesh.scale = $Mesh.scale.linear_interpolate(new_scale, delta + 0.3)
    transform.origin = hidden_pos.linear_interpolate(visible_pos, body_part_progress/100.0)
