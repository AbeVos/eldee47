extends Node

signal body_part_complete
signal body_part_failed

const PROGRESS_VALUE = 5
const REGRESS_VALUE = 2

onready var body_part_progress = 20
onready var is_active = true

func _ready():
	pass # Replace with function body.

func increment_part():
	body_part_progress += PROGRESS_VALUE


func _process(delta):
	body_part_progress -= REGRESS_VALUE

	if (body_part_progress >= 100):
		emit_signal("body_part_complete")
		is_active = false

	if (body_part_progress <= 0):
		emit_signal("body_part_failed")
		is_active = false

	print("body_part_progress: %f", body_part_progress)
