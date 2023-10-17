extends Node3D

@export var SPEED := 2.0

@onready var camera_3d = $Camera3D
@onready var rigid_body_3d = $RigidBody3D
@onready var up = $Control/VBoxContainer/HBoxContainer/up
@onready var down = $Control/VBoxContainer/HBoxContainer/down
@onready var left = $Control/VBoxContainer/HBoxContainer2/left
@onready var right = $Control/VBoxContainer/HBoxContainer2/right

func _process(delta):
	camera_3d.look_at(rigid_body_3d.global_position)
	if left.button_pressed:
		rigid_body_3d.apply_central_force( ( (camera_3d.basis*Vector3(-5,0,0))*Vector3(1,0,1) ).normalized()*SPEED )
	if right.button_pressed:
		rigid_body_3d.apply_central_force( ( (camera_3d.basis*Vector3(5,0,0))*Vector3(1,0,1) ).normalized()*SPEED )
	if up.button_pressed:
		rigid_body_3d.apply_central_force( ( (camera_3d.basis*Vector3(0,0,-5))*Vector3(1,0,1) ).normalized()*SPEED )
	if down.button_pressed:
		rigid_body_3d.apply_central_force( ( (camera_3d.basis*Vector3(0,0,5))*Vector3(1,0,1) ).normalized()*SPEED )

