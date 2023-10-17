extends Node3D

func _input(event):
	if event is InputEventMouseMotion:
		var normalized_mouse_position = Vector2(
			event.position.x/get_viewport().size.x,
			event.position.y/get_viewport().size.y)
		rotation.x = lerp_angle(-.3,.3,normalized_mouse_position.y)
		rotation.y = lerp_angle(-.3,.3,normalized_mouse_position.x)
