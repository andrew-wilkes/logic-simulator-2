extends MarginContainer

class_name CircuitTree

@onready var tree = $Tree

func _ready():
	if get_parent().name == "root":
		var file_tree = {
			"root": ["aaa"],
			"aaa".hash(): ["xxx", "yyy", "zzz"],
			"xxx".hash(): ["ppp"],
			"yyy".hash(): [],
			"zzz".hash(): [],
			"ppp".hash(): [],
		}
		generate_tree(file_tree)


func generate_tree(file_tree):
	tree.clear()
	var root = tree.create_item()
	tree.hide_root = true
	form_tree(file_tree, root, "root")


func form_tree(file_tree, parent, key):
	for file in file_tree[key]:
		var child = tree.create_item(parent)
		child.set_text(0, file)
		form_tree(file_tree, child, file.hash())
