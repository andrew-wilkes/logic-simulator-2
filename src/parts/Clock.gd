class_name Clock

extends Part

var fps = 0
var tick = false
var race_counter_reset_counter: = 0
var cycles := 0
var cycle_limit := 0
var turbo_off = true

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
	if tick:
		update_cycle_count()
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
	if cycle_limit > 0 and cycles >= cycle_limit:
		$Rate.value = 0
		return
	if race_counter_reset_counter == 0:
		controller.reset_race_counters()
	race_counter_reset_counter += 1
	if race_counter_reset_counter > 3:
		race_counter_reset_counter = 0
	update_clock_output(level)
	if not level:
		cycles += 1


func update_cycle_count():
	%CycleCount.text = str(cycles)


func update_clock_output(level):
	update_output_level_with_color(OUT, level)
	update_output_level_with_color(2, not level)


func _on_reset_button_toggled(button_pressed):
	# This allows for resetting when manually pulsing the clock
	if fps <= 0.5:
		update_reset_output(button_pressed)


func update_reset_output(level):
	update_output_level_with_color(1, level)


func apply_power():
	update_clock_output(false)
	update_reset_output(false)


func _on_reset_cycle_count_pressed():
	reset_cycle_count()


func reset_cycle_count():
	cycles = 0


func _on_cycle_limit_value_changed(value):
	cycle_limit = int(value)
	reset_cycle_count()


func _on_turbo_button_toggled(toggled_on):
	if toggled_on:
		turbo_off = false
		controller.thread.start(fast_clock, Thread.PRIORITY_NORMAL)
	else:
		turbo_off = true
		controller.thread.wait_to_finish()


func fast_clock():
	var level = true
	while not turbo_off:
		controller.reset_race_counters()
		controller.output_level_changed_handler(self, OUT, level)
		level = !level
		controller.reset_race_counters()
		controller.output_level_changed_handler(self, 2, level)
		cycles += 1
