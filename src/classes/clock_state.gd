extends RefCounted

class_name ClockState

var source = false # Will be set by a clocked input
var eval = false # Signals to clocked part to evaluate its inputs

func _to_string():
	return str({ "source": source, "eval": eval })
