@tool
class_name Panel3D
extends StaticBody3D
var viewport : SubViewport
var viewport_container : SubViewportContainer
var mesh : MeshInstance3D
var colshape : CollisionShape3D
var material : StandardMaterial3D

var ui : Node
var tex:ViewportTexture

## PackedScene of the scene you want to load into the panel (you can also use the "set_viewport_scene(Node)")
@export var _auto_load_ui : PackedScene
## Sets the panel to transparent (Panel3Ds are automatically opaque on Android and Web)
@export var transparent : bool = true
## Sets the viewport size (panel size is automatically .0005 meters * number of pixels)
@export var viewport_size:Vector2i=Vector2i(1024,1024)

func _init():
	viewport_container = SubViewportContainer.new()
	viewport_container.visibility_layer = 0
	viewport_container.light_mask = 0
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	mesh = MeshInstance3D.new()
	mesh.mesh = PlaneMesh.new()
	colshape = CollisionShape3D.new()
	colshape.shape = BoxShape3D.new()
	material = StandardMaterial3D.new()
	mesh.mesh.surface_set_material(0,material)

func _ready():
	add_child(viewport_container)
	viewport_container.add_child(viewport,false,Node.INTERNAL_MODE_FRONT)
	add_child(mesh,false,Node.INTERNAL_MODE_FRONT)
	add_child(colshape,false,Node.INTERNAL_MODE_FRONT)
	material.albedo_texture = viewport.get_texture()
	material.metallic_specular = 0.0
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.mesh.material.albedo_texture = viewport.get_texture()
	if viewport_size:
		set_viewport_size(viewport_size)
	if transparent and OS.get_name() != "Android" and OS.get_name() != 'Web':
		viewport.transparent_bg = true
	else:
		viewport.transparent_bg = false
#	viewport.gui_focus_changed.connect(func(node):
#		LocalGlobals.player_state = LocalGlobals.PLAYER_STATE_TYPING
#		)
#	LocalGlobals.playerreleaseuifocus.connect(func():
#		viewport.gui_release_focus()
#		)
#	colShape.position.y = -colShape.shape.size.y/2.0
	if _auto_load_ui:
		set_viewport_scene(_auto_load_ui.instantiate())

func _process(delta):
	mesh.mesh.size.x = .0005*viewport.size.x
	mesh.mesh.size.y = .0005*viewport.size.y
	colshape.shape.size = Vector3(mesh.mesh.size.x,.001,mesh.mesh.size.y)

func laser_input(data:Dictionary):
	var event
	# Setup event
	match data.action:
		"hover":
			event = InputEventMouseMotion.new()
		"scrollup":
			event = InputEventMouseButton.new()
			event.button_index = 4
		"scrolldown":
			event = InputEventMouseButton.new()
			event.button_index = 5
		"click":
			event = InputEventMouseButton.new()
			event.button_index = 1
		"custom":
			# Use this to pass a different event type or add event strings below
			event = data.event
	# Set event pressed value (should be false if not explicitly changed)
	if data.pressed:
		event.pressed = data.pressed
	# Get the size of the quad mesh we're rendering to
	var quad_size = mesh.mesh.size
	# Convert GLOBAL collision point from to be in local space of the panel
	var mouse_pos3D = to_local(data.position) # data.position must be global
	var mouse_pos2D = Vector2(mouse_pos3D.x, mouse_pos3D.z)
	# Translate the 2D mouse position to the center of the quad
	#	by adding half of the quad size to both x and y coordinates.
	mouse_pos2D.x += quad_size.x / 2
	mouse_pos2D.y += quad_size.y / 2
	# Normalize the mouse position to be within the quad size
	mouse_pos2D.x = mouse_pos2D.x / quad_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_size.y
	# Convert the 2D mouse position to viewport coordinates
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	# Sets the position of the event to the calculated mouse position in 2D space.
	event.position = mouse_pos2D
	# Set the event to be handled locally (workaround for Godot 4.x bug)
	#	The bug causes the viewport to not consistently receive input events
	viewport.handle_input_locally = true
	# Push the event to the viewport
	viewport.call_thread_safe("push_input",event,true)
	viewport.handle_input_locally = false

func set_viewport_scene(node):
	# Adds a child node to the viewport and sets it as the UI
	#	Then, gets the texture of the viewport.
	viewport.add_child(node)
	ui = node
	tex = viewport.get_texture()
	# Connects the 'action' signal of the given node to the 'action' signal of this node.
	if node.has_signal('action'):
		node.action.connect(func(data):
			emit_signal('action',data)
		)
	mesh.mesh.surface_get_material(0).albedo_texture = tex

func set_viewport_size(size:Vector2i):
	viewport.size = size
