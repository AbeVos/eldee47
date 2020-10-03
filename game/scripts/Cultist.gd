extends Spatial


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
    mat.albedo_color = Color(1, $Right.value, 0)
    $Body.set_surface_material(0, mat)


func _on_Left_grabbed():
    $Right.locked = true

func _on_Right_grabbed():
    $Left.locked = true

func _on_Left_released():
    $Right.locked = false

func _on_Right_released():
    $Left.locked = false
