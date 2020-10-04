extends Spatial

signal monster_done
signal monster_failed
signal monster_partial

onready var results = []
onready var is_active = true

func _on_Choir_send_assignments(group_key, assignment):
    print("Group key: ", group_key, " Assignment: ", assignment)
    var total 
    match group_key:
        1:
            for i in range(3):

                if (assignment[i] == null):
                    return
            
            $Head.increment_part()
        2:
            for i in range(3):
                if (assignment[i] == null):
                    return
            
            $Claw_left.increment_part()
        3:
            for i in range(3):
                if (assignment[i] == null):
                    return
            
            $Claw_right.increment_part()

func _process(delta):
    if (is_active and results.size() >= 3):
        is_active = false
        var total = 0
        for i in range(results.size()):
            total += i
        if (total >= results.size()):
            emit_signal("monster_done")
        elif (total > 0):
            emit_signal("monster_partial")
        else: 
            emit_signal("monster_failed")

        print("We zijn klaar met een totaal van: ", total)


func _on_IncrementTimer_timeout():
    #$Head.update_body_part()
    #$Claw_left.update_body_part()
    #$Claw_right.update_body_part()
    pass


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
