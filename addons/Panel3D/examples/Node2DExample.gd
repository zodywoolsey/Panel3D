extends Node2D
@onready var rigid_body_2d = $RigidBody2D

func _input(event):
	if event is InputEventMouseMotion:
		rigid_body_2d.global_position = event.position
