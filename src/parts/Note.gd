class_name Note

extends Part

var panel: PopupPanel

func _init():
	category = UTILITY
	order = 0
	data = {
		"file": "",
		"size": [300, 200],
		"text": ""
	}


func _ready():
	super()
	panel = $C/Panel
	panel.hide()
	panel.size = Vector2(data.size[0], data.size[1])
	panel.position = get_global_position() + Vector2(120, 0)
	$C/Panel/TextEdit.text = data.text


func _on_view_button_pressed():
	$ViewButton.disabled = true
	panel.popup(Rect2i(panel.position, panel.size))
	$C/Panel/TextEdit.grab_focus()


func _on_panel_size_changed():
	if panel and panel.visible:
		data.size = [panel.size.x, panel.size.y]


func _on_panel_popup_hide():
	$ViewButton.disabled = false


func _on_text_edit_text_changed():
	data.text = $C/Panel/TextEdit.text
	changed()
