extends MarginContainer

func _ready():
	for col in $HB.get_child_count():
		for n in (col + 1) * 8:
			$HB.get_child(col).get_child(1).add_item("Item" + str(n + 1)) 


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	prints(index, at_position, mouse_button_index)
