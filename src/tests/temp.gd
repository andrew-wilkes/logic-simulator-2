@tool
extends EditorScript

func _run():
	var a = [1,2,3]
	var b = [4,5,6]
	var c = a + [7]
	prints(a,b,c)
	
	var x = a
	x[0] = 8
	prints(a, x)
	
	var d = { "arr": a }
	mod_arr(d.arr)
	print(d)


func mod_arr(arr):
	arr[0] = -1
