@tool
extends EditorScript

func _run():
	var a = [1,2,3]
	var b = [4,5,6]
	var c = a + [7]
	prints(a,b,c)
