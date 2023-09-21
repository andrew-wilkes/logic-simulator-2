extends Control


func _ready():
	pass


func _on_button_pressed():
	var part = Part.new()
	part.position_offset = Vector2(100, 100) + $VB/Schematic.scroll_offset / $VB/Schematic.zoom
	part.title = "Test"
	$VB/Schematic.add_part(part)
