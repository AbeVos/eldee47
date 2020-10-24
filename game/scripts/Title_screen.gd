extends Control

export(String, FILE, "*.tscn,*.scn") var scene_to_load = "res://scenes/IntroCinematic.tscn"

func _process(_delta):
    if (Input.is_action_pressed("ui_accept")):
        SceneChanger.change_scene(scene_to_load, 0.5)