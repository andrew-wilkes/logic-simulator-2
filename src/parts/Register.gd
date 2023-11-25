class_name Register

extends Part

var value = 0

func _init():
	order = 80
	category = SYNC


func _ready():
	super()
	reset()


func evaluate_output_level(side, port, level):
	if side == LEFT:
		if port == 2: # clk
			if level:
				if pins[[side, 1]]: # load
					value = pins[[side, 0]]
					$Value.text = "0x%04X" % [value]
			else:
				update_output_value(RIGHT, OUT, value)


func evaluate_bus_output_value(_side, _port, _value):
	# Don't let the load value immediately go to the output
	pass


func reset():
	value = 0
	$Value.text = "0x%04X" % [value]
	pins = { [0, 0]: 0, [0, 1]: false }
