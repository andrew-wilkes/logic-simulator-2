class_name CustomPopup

extends PanelContainer

signal left_button_pressed()

var sizing_x = false
var sizing_y = false
var initial_mouse_position = Vector2.ZERO
var initial_panel_position = Vector2.ZERO
@onready var text_area = $M/VB/RichTextLabel

func _ready():
	set_text("")


func open():
	position = (get_window().size - Vector2i(size)) / 2
	show()


func set_title(title):
	$M/VB/Title.text = title


func set_text(text):
	text_area.text = text


func _on_close_button_pressed():
	hide()


func _on_margin_container_mouse_entered():
	sizing_x = false
	sizing_y = false
	if get_local_mouse_position().x > size.x - $M.get("theme_override_constants/margin_right"):
		mouse_default_cursor_shape = CURSOR_HSIZE
		sizing_x = true
	elif get_local_mouse_position().y > size.y - $M.get("theme_override_constants/margin_bottom"):
		mouse_default_cursor_shape = CURSOR_VSIZE
		sizing_y = true


func _on_margin_container_mouse_exited():
	mouse_default_cursor_shape = CURSOR_ARROW


func _on_margin_container_gui_input(event):
	if event is InputEventMouseMotion and event.button_mask == 1:
		if sizing_x:
			size.x = event.position.x
		if sizing_y:
			size.y = event.position.y


func _on_title_mouse_entered():
	mouse_default_cursor_shape = CURSOR_CROSS


func _on_title_mouse_exited():
	# This causes crashes if placed here:
	# mouse_default_cursor_shape = CURSOR_ARROW
	initial_mouse_position = Vector2.ZERO


func _on_title_gui_input(event):
	if event is InputEventMouseMotion and event.button_mask == 1:
		if initial_mouse_position == Vector2.ZERO:
			initial_mouse_position = get_global_mouse_position()
			initial_panel_position = position
		position = initial_panel_position + get_global_mouse_position() - initial_mouse_position


func _on_open_button_pressed():
	emit_signal("left_button_pressed")
