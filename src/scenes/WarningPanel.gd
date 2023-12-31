extends PopupPanel

func open(txt, prefix = "Warning: ", bg_color = Color(0xda6806ff)):
	$C/Note.text = prefix + txt
	get("theme_override_styles/panel").bg_color = bg_color
	popup_centered()
	await get_tree().create_timer(3.0).timeout
	hide()
