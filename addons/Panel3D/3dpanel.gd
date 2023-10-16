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
	if data.pressed:
		event.pressed = data.pressed
#	event.button_mask = 1
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = mesh.mesh.size
	var mouse_pos3D = to_local(data.position)
	# convert the relative event position from 3D to 2D
	var mouse_pos2D = Vector2(mouse_pos3D.x, mouse_pos3D.z)
	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.
	# Set the event's position and global position.
	event.position = mouse_pos2D
#	event.global_position = mouse_pos2D
	viewport.handle_input_locally = true
	viewport.call_thread_safe("push_input",event,true)
	viewport.handle_input_locally = false

func set_viewport_scene(node):
	viewport.add_child(node)
	ui = node
	tex = viewport.get_texture()
	if node.has_signal('action'):
		node.action.connect(func(data):
			emit_signal('action',data)
			)
	mesh.mesh.surface_get_material(0).albedo_texture = tex

func set_viewport_size(size:Vector2i):
	viewport.size = size
