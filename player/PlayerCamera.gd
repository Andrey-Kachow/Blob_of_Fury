extends Camera2D

const LOOK_AHEAD_FACTOR = 0.1
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 2.0
const VERTICAL_LOOK_AHEAD = 100

var facing = 0
var target_y_pos = 0
var timer_started = false

onready var prev_camera_pos = get_camera_position()


func _process(delta):
	_check_facing()
	prev_camera_pos = get_camera_position()
	look_up_if_nessesary()
		
		
func look_up_if_nessesary():
	if Input.is_action_pressed("stand"):
		var up = Input.is_action_pressed("up")
		var down = Input.is_action_pressed("down")
		if up and down:
			up = false
			down = false
		if up:
			set_target_pos(-VERTICAL_LOOK_AHEAD)
		elif down:
			set_target_pos(VERTICAL_LOOK_AHEAD)
		else:
			return_vertically()
	else:
		return_vertically()


func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	if new_facing != 0 and facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * facing * LOOK_AHEAD_FACTOR
		$ShiftTween.interpolate_property(
			self, "position:x", position.x, target_offset,
			SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE
		)
		$ShiftTween.start()
		

func return_vertically():
	target_y_pos = 0
	position.y = 0.0


func _on_Player_grounded_updated(is_grounded):
	drag_margin_v_enabled = not is_grounded


func set_target_pos(pos_y):
	if target_y_pos != pos_y:
		$Timer.stop()
		target_y_pos = pos_y
		$Timer.start()


func _on_Timer_timeout():
	position.y = target_y_pos
