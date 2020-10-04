extends CanvasLayer

signal scene_changed()

onready var animation_player = $AnimationPlayer
onready var black = $Control/Black


func change_scene(path, delay=0.5):
    yield(get_tree().create_timer(delay), "timeout")

    animation_player.play("fade")
    yield(animation_player, "animation_finished")

    assert(get_tree().change_scene(path) == OK)

    animation_player.play_backwards("fade")
    emit_signal("scene_changed")


func get_music_progress():
    return $AudioTimer.wait_time - $AudioTimer.time_left
