extends RayCast3D

var prevHover
var pressed := false

var clicked := false

func _process(delta):
	var cam = get_viewport().get_camera_3d()
	global_position = cam.global_position
	target_position = cam.project_ray_normal(get_viewport().get_mouse_position())*10.0
	if Input.get_mouse_button_mask() == MOUSE_BUTTON_LEFT and !clicked:
		click()
		clicked = true
	if Input.get_mouse_button_mask() == 0:
		release()
		clicked = false

func _physics_process(delta):
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			if prevHover and prevHover != tmpcol:
				prevHover.laser_input({
					'hovering': false,
					'pressed': false,
					'position': get_collision_point(),
					"action": "hover"
				})
			else:
				tmpcol.laser_input({
					'hovering': true,
					'pressed': false,
					"position": get_collision_point(),
					"action": "hover"
				})
			prevHover = tmpcol
		else:
			if prevHover and prevHover.has_method("laser_input"):
				prevHover.laser_input({
					'hovering': false,
					'pressed': false,
					'position': get_collision_point(),
					"action": "hover"
				})
	else:
		if prevHover and prevHover.has_method("laser_input") and prevHover.has_method('laser_input'):
			prevHover.laser_input({
				'hovering': false,
				'pressed': false,
				'position': get_collision_point(),
				'action': 'hover'
			})
			if pressed and prevHover.has_method('laser_input'):
				prevHover.laser_input({
					"position": get_collision_point(),
					"pressed": false,
					'action': 'click'
					})
			prevHover = null
#	print(currentAction)

func scrollup():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrollup"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrollup"
				})

func scrolldown():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				"action": "scrolldown"
				})
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				"action": "scrolldown"
				})

func click():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": true,
				'action': 'click'
				})
			pressed = true

func release():
	if is_colliding():
		var tmpcol = get_collider()
		if tmpcol.has_method("laser_input"):
			tmpcol.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
			pressed = false
	elif prevHover:
		if prevHover.has_method("laser_input"):
			prevHover.laser_input({
				"position": get_collision_point(),
				"pressed": false,
				'action': 'click'
				})
