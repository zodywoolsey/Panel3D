extends Node2D
@onready var rigid_body_2d = $RigidBody2D
@onready var rigid_body_2d_2 = $RigidBody2D2

func _ready():
	for i in 100:
		add_child(rigid_body_2d_2.duplicate())

func _input(event):
	if event is InputEventMouseMotion:
		rigid_body_2d.global_position = event.position
