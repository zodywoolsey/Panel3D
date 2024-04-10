extends HSlider

@onready var panel_3d = $"../../Panel3D3"

func _value_changed(new_value):
	panel_3d.viewport_size.x = new_value
