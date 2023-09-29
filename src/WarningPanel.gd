extends PopupPanel

func open(txt):
	$C/Note.text = "Warning: " + txt
	popup_centered()
	await get_tree().create_timer(3.0).timeout
	hide()
