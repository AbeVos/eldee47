extends Spatial

signal grabbed
signal released

export var hand_radius = 0.0005
export var arm_radius = 1

var viewport
var camera
var mouse_over = false
var dragging = false

var locked = false
var value = 0


func _ready():
	viewport = get_viewport()
	camera = viewport.get_camera()

	var mat = $Hand/Highlight.get_surface_material(0).duplicate(true)
	$Hand/Highlight.set_surface_material(0, mat)


func _process(delta):
	var view_rect = viewport.get_visible_rect().size
	var mouse_pos = viewport.get_mouse_position()
	var mouse_pos_norm = normalize_screen_space(mouse_pos, view_rect)

	var arm_pos = $Hand.global_transform.origin
	var screen_pos = camera.unproject_position(arm_pos)
	screen_pos = normalize_screen_space(screen_pos, view_rect)

	var distance = screen_pos.distance_squared_to(mouse_pos_norm)

	if distance <= hand_radius:
		# $Hand/Highlight.visible = true
		var material = $Hand/Highlight.get_surface_material(0)
		material.albedo_color = Color(1, 0, 0)
		$Hand/Highlight.set_surface_material(0, material)

		mouse_over = true
	elif not dragging:
		# $Hand/Highlight.visible = false
		var material = $Hand/Highlight.get_surface_material(0)
		material.albedo_color = Color(0, 1, 0)
		$Hand/Highlight.set_surface_material(0, material)

		mouse_over = false

	if dragging:
		var z_depth = global_transform.origin.distance_to(
			camera.get_camera_transform().origin
		)
		var mouse_world_pos = camera.project_position(mouse_pos, z_depth)

		$Hand.global_transform.origin = mouse_world_pos

	if $Hand.transform.origin.distance_to(Vector3(0, 0, 0)) >= arm_radius:
		var direction = $Hand.transform.origin.normalized()

		$Hand.transform.origin = direction * arm_radius

	var height = $Hand.transform.origin.y
	value = (height + arm_radius) / (2 * arm_radius)


func _input(event):
	if event is InputEventMouseButton:
		if mouse_over and not locked:
			if dragging:
				dragging = false
				emit_signal("released")
			else:
				dragging = true
				emit_signal("grabbed")


func normalize_screen_space(point, rect):
	var axis = max(rect.x, rect.y)
	return point / axis
