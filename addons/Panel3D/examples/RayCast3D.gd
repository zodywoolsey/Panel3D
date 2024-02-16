extends RayCast3D

var curr_panel:Panel3D
		
func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_3d()
	global_position = cam.global_position
	target_position = cam.project_ray_normal(get_viewport().get_mouse_position())*10.0
	
	if is_colliding():
		var colliding_obj = get_collider()
		if colliding_obj is Panel3D:
			curr_panel = colliding_obj as Panel3D
		else:
			curr_panel=null
	else:
		curr_panel=null


func _unhandled_input(event: InputEvent) -> void:
	if curr_panel == null:
		return
	
	#if event is InputEventMouseMotion or event is InputEventMouseButton:
	curr_panel.laser_input(event,get_collision_point())

