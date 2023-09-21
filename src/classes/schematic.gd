class_name Schematic

extends GraphEdit

var circuit

func _ready():
	pass # Replace with function body.


func add_part(part: Part, offset: Vector2):
	add_child(part, true)
	part.position_offset = offset
