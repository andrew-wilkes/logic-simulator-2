class_name Clock

extends Part

var fps = 0
var tick = false
var cycle_limit := 0
var turbo_on = false
var clock: CircuitInput
var inv_clock: CircuitInput
var reset_out: CircuitInput
var clock_pulse: CircuitInput
var clock_pulse_inv: CircuitInput

func _init():
	category = UTILITY
	order = 88


func _ready():
	super()
	if show_display:
		display_update_timer = Timer.new()
		get_child(-1).add_child(display_update_timer)
		display_update_timer.timeout.connect(update_cycle_count)
		display_update_timer.start(0.1)


func setup():
	# Now name is set after adding to scene tree
	clock_pulse = CircuitInput.new()
	clock_pulse.name = name
	clock_pulse.port = OUT
	clock_pulse_inv = CircuitInput.new()
	clock_pulse_inv.name = name
	clock_pulse_inv.port = 2
	clock = CircuitInput.new()
	clock.name = name
	clock.port = OUT
	clock.level = true
	inv_clock = CircuitInput.new()
	inv_clock.name = name
	inv_clock.port = 2
	reset_out = CircuitInput.new()
	reset_out.name = name
	reset_out.port = 1


func _on_rate_value_changed(value):
	fps = value
	if fps > 0.5:
		%ResetButton.toggle_mode = false
		$Timer.start(1 / fps)
	else:
		%ResetButton.toggle_mode = true


func _on_timer_timeout():
	tick = not tick
	output_clock(tick)
	if fps > 0.5:
		$Timer.start(1 / fps)


func _on_pulse_button_button_down():
	if cycle_limit > 0:
		%CycleLimit.value = 0
	output_clock(true)


func _on_pulse_button_button_up():
	output_clock(false)
	update_cycle_count()


func _on_reset_button_button_down():
	if fps > 0.5:
		update_reset_output(true)


func _on_reset_button_button_up():
	if fps > 0.5:
		update_reset_output(false)


func output_clock(level):
	if cycle_limit > 0 and clock.cycles >= cycle_limit:
		$Rate.value = 0
		return
	update_clock_output(level)
	if not level:
		controller.mutex.lock()
		clock.cycles += 1
		controller.mutex.unlock()


func update_cycle_count():
	%CycleCount.text = str(clock.cycles)
	if turbo_on and cycle_limit > 0 and clock.cycles >= cycle_limit:
		$Rate.value = 0
		%TurboButton.button_pressed = false


func update_clock_output(level):
	clock_pulse.level = level
	clock_pulse_inv.level = not level
	controller.inject_circuit_input(clock_pulse)
	controller.inject_circuit_input(clock_pulse_inv)


func _on_reset_button_toggled(button_pressed):
	# This allows for resetting when manually pulsing the clock
	if fps <= 0.5:
		update_reset_output(button_pressed)


func update_reset_output(level):
	reset_out.level = level
	controller.inject_circuit_input(reset_out)


func apply_power():
	update_clock_output(false)
	update_reset_output(false)


func _on_reset_cycle_count_pressed():
	reset_cycle_count()


func reset_cycle_count():
	controller.mutex.lock()
	clock.cycles = 0
	inv_clock.cycles = 0
	controller.mutex.unlock()


func _on_cycle_limit_value_changed(value):
	cycle_limit = int(value)
	reset_cycle_count()


func _on_turbo_button_toggled(toggled_on):
	turbo_on = toggled_on
	if toggled_on:
		clock.cycle_limit = cycle_limit
		inv_clock.cycle_limit = cycle_limit
		controller.add_clock(clock)
		controller.add_clock(inv_clock)
	else:
		controller.remove_clock(clock)
		controller.remove_clock(inv_clock)


func _on_tree_exited():
	clock.free()
	inv_clock.free()
	reset_out.free()
	clock_pulse.free()
	clock_pulse_inv.free()
