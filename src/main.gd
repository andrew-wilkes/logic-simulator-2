extends Control

func _ready():
	pass


func _on_button_pressed():
	$VB/Schematic.add_part()


func _on_save_button_pressed():
	$VB/Schematic.save_circuit()


func _on_load_button_pressed():
	$VB/Schematic.load_circuit()
