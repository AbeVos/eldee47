extends Spatial

signal set_target(cultist_index, target)  # Target for particles.
signal monster_done
signal monster_failed
signal monster_partial

onready var results = []
onready var is_active = true

func _on_Choir_send_assignments(group_key, assignment):
	print("Group key: ", group_key, " Assignment: ", assignment)

	var body_parts = [
		$Head, $Claw_left, $Claw_right,
	]

	for cultist_idx in assignment:
		if cultist_idx == null:
			continue

		emit_signal("set_target", cultist_idx, body_parts[group_key])

	if not null in assignment:
		if (is_active):
			body_parts[group_key].increment_part()


func _process(_delta):
	if (is_active and results.size() >= 3):
		is_active = false
		var total = 0
		for i in range(results.size()):
			total += i
		if (total >= results.size()):
			emit_signal("monster_done")
			SceneChanger.change_scene("res://scenes/WinScene.tscn", 0.5)
		elif (total > 0):
			emit_signal("monster_partial")
			SceneChanger.change_scene("res://scenes/FailScene.tscn", 0.5)
		else:
			emit_signal("monster_failed")
			SceneChanger.change_scene("res://scenes/FailScene.tscn", 0.5)


func _on_IncrementTimer_timeout():
	$Head.update_body_part()
	$Claw_left.update_body_part()
	$Claw_right.update_body_part()


func _on_Head_body_part_failed():
	results.append(0)


func _on_Claw_left_body_part_failed():
	results.append(0)


func _on_Claw_right_body_part_failed():
	results.append(0)


func _on_Head_body_part_complete():
	results.append(1)


func _on_Claw_left_body_part_complete():
	results.append(1)


func _on_Claw_right_body_part_complete():
	results.append(1)
