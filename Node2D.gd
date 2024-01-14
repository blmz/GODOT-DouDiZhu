extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print(int(float(600)/360))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func 计算角度(current_angle: float, target_angle: float):
	var angle_difference = target_angle - current_angle
	if angle_difference < -180:
		return 360 + angle_difference
	elif angle_difference > 180:
		return -360 + angle_difference
	else:
		return angle_difference
