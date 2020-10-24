extends Control

export(String, FILE, "*.tscn,*.scn") var scene_to_load = "res://scenes/Main.tscn"
export(float) var scrollspeed = 10
export(float) var fadespeed = 0.7

var top
var bottom
var is_done = false

func _ready():
    top = $Background/TextScroll.margin_top
    bottom = $Background/TextScroll.margin_bottom

func _process(delta):
    top -= scrollspeed * delta
    bottom -= scrollspeed * delta
    $Background/TextScroll.margin_top = top
    $Background/TextScroll.margin_bottom = bottom

    if (bottom <= 0 && !is_done):
        is_done = true
        SceneChanger.change_scene(scene_to_load, fadespeed)
