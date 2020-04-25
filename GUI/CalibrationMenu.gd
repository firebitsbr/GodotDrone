extends Control


onready var label_action = $VBoxContainer/LabelAction

var calibration_step = -1
var axes = []
var throttle = []
var yaw = []
var pitch = []
var roll = []

var calibration_done = false

signal calibration_done
signal back


func _ready():
	$VBoxContainer/ButtonCancel.connect("pressed", self, "_on_cancel_pressed")
	connect("calibration_done", self, "_on_calibration_done")
	
	go_to_next_step()


func _process(delta):
	var next_step_ready = true
	if calibration_step == 0 and axes.size() == 4:
		for i in range(4):
			if abs(Input.get_joy_axis(0, i)) < 0.5:
				next_step_ready = false
				break
	elif calibration_step == 1:
		for i in range(4):
			if abs(Input.get_joy_axis(0, i)) > 0.2:
				next_step_ready = false
				break
	else:
		next_step_ready = false
	if next_step_ready:
		go_to_next_step()


func _input(event):
	if event is InputEventJoypadMotion:
		if calibration_step == 0:
			if abs(event.axis_value) > 0.9:
				if axes.find(event.axis) < 0:
					axes.append(event.axis)
		elif calibration_step == 2:
			# Throttle axis
			if axes.find(event.axis) >= 0 and abs(event.axis_value) > 0.9:
				throttle.append(event.axis)
				throttle.append(event)
				go_to_next_step()
		elif calibration_step == 3:
			if event.axis == throttle[0]:
				if abs(event.axis_value + throttle[1].axis_value) < 0.2:
					throttle.append(event)
					go_to_next_step()
		elif calibration_step == 4:
			if event.axis == throttle[0] and abs(event.axis_value) < 0.2:
				go_to_next_step()
		elif calibration_step == 5:
			# Yaw axis
			if axes.find(event.axis) >= 0 and abs(event.axis_value) > 0.9:
				yaw.append(event.axis)
				yaw.append(event)
				go_to_next_step()
		elif calibration_step == 6:
			if event.axis == yaw[0]:
				if abs(event.axis_value + yaw[1].axis_value) < 0.2:
					yaw.append(event)
					go_to_next_step()
		elif calibration_step == 7:
			if event.axis == yaw[0] and abs(event.axis_value) < 0.2:
				go_to_next_step()
		elif calibration_step == 8:
			# Pitch axis
			if axes.find(event.axis) >= 0 and abs(event.axis_value) > 0.9:
				pitch.append(event.axis)
				pitch.append(event)
				go_to_next_step()
		elif calibration_step == 9:
			if event.axis == pitch[0]:
				if abs(event.axis_value + pitch[1].axis_value) < 0.2:
					pitch.append(event)
					go_to_next_step()
		elif calibration_step == 10:
			if event.axis == pitch[0] and abs(event.axis_value) < 0.2:
				go_to_next_step()
		elif calibration_step == 11:
			# Roll axis
			if axes.find(event.axis) >= 0 and abs(event.axis_value) > 0.9:
				roll.append(event.axis)
				roll.append(event)
				go_to_next_step()
		elif calibration_step == 12:
			if event.axis == roll[0]:
				if abs(event.axis_value + roll[1].axis_value) < 0.2:
					roll.append(event)
					go_to_next_step()
		elif calibration_step == 13:
			if event.axis == roll[0] and abs(event.axis_value) < 0.2:
				go_to_next_step()


func go_to_next_step():
	calibration_step += 1
	
	match calibration_step:
		0:
			label_action.text = "Move sticks to corners"
		1:
			label_action.text = "Center sticks"
		2:
			label_action.text = "Move throttle up"
		3:
			label_action.text = "Move throttle down"
		4:
			label_action.text = "Center throttle"
		5:
			label_action.text = "Move yaw left"
		6:
			label_action.text = "Move yaw right"
		7:
			label_action.text = "Center yaw"
		8:
			label_action.text = "Move pitch up"
		9:
			label_action.text = "Move pitch down"
		10:
			label_action.text = "Center pitch"
		11:
			label_action.text = "Move roll left"
		12:
			label_action.text = "Move roll right"
		13:
			label_action.text = "Center roll"
		_:
			label_action.text = "Calibration successful"
			emit_signal("calibration_done")


func _on_calibration_done():
	calibration_done = true
	InputMap.action_erase_events("throttle_up")
	InputMap.action_erase_events("throttle_down")
	InputMap.action_add_event("throttle_up", throttle[1])
	InputMap.action_add_event("throttle_down", throttle[2])
	InputMap.action_erase_events("yaw_left")
	InputMap.action_erase_events("yaw_right")
	InputMap.action_add_event("yaw_left", yaw[1])
	InputMap.action_add_event("yaw_right", yaw[2])
	InputMap.action_erase_events("pitch_down")
	InputMap.action_erase_events("pitch_up")
	InputMap.action_add_event("pitch_down", pitch[1])
	InputMap.action_add_event("pitch_up", pitch[2])
	InputMap.action_erase_events("roll_left")
	InputMap.action_erase_events("roll_right")
	InputMap.action_add_event("roll_left", roll[1])
	InputMap.action_add_event("roll_right", roll[2])
	save_input_map()
	
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("back")


func save_input_map():
	var path = "user://InputMap.cfg"
	var config = ConfigFile.new()
	var err = config.load(path)
	print(err)
	if err == OK or err == ERR_FILE_NOT_FOUND:
		config.set_value("controls", "throttle_up", throttle[1])
		config.set_value("controls", "throttle_down", throttle[2])
		config.set_value("controls", "yaw_left", yaw[1])
		config.set_value("controls", "yaw_right", yaw[2])
		config.set_value("controls", "pitch_down", pitch[1])
		config.set_value("controls", "pitch_up", pitch[2])
		config.set_value("controls", "roll_left", roll[1])
		config.set_value("controls", "roll_right", roll[2])
		config.save(path)


func reset_calibration():
	calibration_step = 0


func _on_cancel_pressed():
	reset_calibration()
	emit_signal("back")