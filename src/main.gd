extends Control

var part_scene = preload("res://parts/part.tscn")

func _ready():
	pass


func _on_button_pressed():
	var part = part_scene.instantiate()
	part.title = "Test"
	$VB/Schematic.add_part(part)
