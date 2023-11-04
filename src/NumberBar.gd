extends Label

var bg_color:
	set(c):
		$ColorRect.color = c
	get:
		return $ColorRect.color

var text_color:
	set(c):
		modulate = c
	get:
		return modulate

func resize():
	$ColorRect.size = size
	

# Create groups of 4 bits
func int2bin(x, num_bits):
	var _b = ""
	for n in num_bits:
		if n == 4:
			_b = " " + _b
		_b = str(x % 2) + _b
		x /= 2
	text = _b
	resize()

func int2hex(x):
	text = "%02X" % x
	resize()

func int2dec(x):
	text = str(x)
	resize()
