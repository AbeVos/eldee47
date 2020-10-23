extends Spatial

var skeleton
var shoulder_l_id
var shoulder_r_id

export(float) var raised_val = 0

func _ready():
    skeleton = get_node("Skeleton")
    shoulder_l_id = skeleton.find_bone("joint_l_shoulder")
    shoulder_r_id = skeleton.find_bone("joint_r_shoulder")
    set_process(true)

# geniet van dit mooie stukje gejate code
func remap_range(input, minInput, maxInput, minOutput, maxOutput):
    return(input - minInput) / (maxInput - minInput) * (maxOutput - minOutput) + minOutput


func calculate_arm(input):
    # map 0..1 to -1..1
    input = clamp(input, 0, 1)+ 0.00001
    return (input * 2) -1


func _process(_delta):
    var new_l = skeleton.get_bone_pose( shoulder_l_id)
    var new_r = skeleton.get_bone_pose( shoulder_r_id)
    
    # Get z-axis
    new_l = new_l.rotated(Vector3(0.0, 0.0, 1.0), calculate_arm(raised_val))
    new_r = new_r.rotated(Vector3(0.0, 0.0, 1.0), calculate_arm(raised_val))
    
    #print("New pose", new_l)
    skeleton.set_bone_pose( shoulder_l_id, new_l)
    skeleton.set_bone_pose( shoulder_r_id, new_r)
