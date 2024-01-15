extends TabContainer

func add_text(txt):
	%Text.text += txt + "\n"


func clear():
	%Text.text = ""


func _on_clear_button_pressed():
	clear()
	close()


func _on_ok_button_pressed():
	close()


func close():
	get_parent().hide()
