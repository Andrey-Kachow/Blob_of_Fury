extends Sprite

signal shoot  # godot book, page 214

export (PackedScene) var Bullet
export (float) var fire_rate

enum {IDLE, DOWN, UP, DIAGONAL_UP, DIAGONAL_DOWN, CROUCH}
var state

var anim
var new_anim

var current_muzzle
var current_bullet_direction = 0
var can_shoot = true
var flipped = false
var owner_hurt = false


func _ready():
	change_state(IDLE)
	$GunTimer.wait_time = fire_rate
	set_muzzle_position()
	

func change_state(new_state):
	if new_state != state:
		state = new_state
		match state:
			IDLE:
				new_anim = 'idle'
				current_muzzle = $IdleMuzzle
				current_bullet_direction = PI if flip_h else 0.0
			DOWN:
				new_anim = 'down'
				current_muzzle = $DownMuzzle
				current_bullet_direction = PI / 2
			UP:
				new_anim = 'up'
				current_muzzle = $UpMuzzle
				current_bullet_direction = 3 * PI / 2
			DIAGONAL_UP:
				new_anim = 'diagonal_up'
				current_muzzle = $DUpMuzzle
				current_bullet_direction = 5 * PI / 4 if flip_h else 7 * PI / 4
			DIAGONAL_DOWN:
				new_anim = 'diagonal_down'
				current_muzzle = $DDownMuzzle
				current_bullet_direction = 3 * PI / 4 if flip_h else  PI / 4
			CROUCH:
				new_anim = 'crouch'
				current_muzzle = $CrouchMuzzle
				current_bullet_direction = PI if flip_h else 0.0
				

func _process(delta):
	get_input()
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)
	

func get_input():
	var initial_state = state
	
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	#var jump = Input.is_action_just_pressed("jump")
	var shoot = Input.is_action_pressed("shoot") and not owner_hurt
	var down = Input.is_action_pressed("down")
	var up = Input.is_action_pressed('up')
	#var change_weapon = Input.is_action_just_pressed("change_weapon")
	var stand = Input.is_action_pressed("stand")
	
	if right and left:
		right = false
		left = false
	if up and down:
		up = false
		down = false
	
	if right:
		change_state(IDLE)
		set_flip_h(false)
	if left:
		change_state(IDLE)
		set_flip_h(true)
	if down:
		if stand or not GameManager.player.is_on_floor():
			change_state(DOWN)
		else:
			change_state(CROUCH)
	if not down and state in [CROUCH, DOWN]:
		change_state(IDLE)
	if up:
		change_state(UP)
	if not up and state in [UP, DIAGONAL_DOWN, DIAGONAL_UP]:
		change_state(IDLE)
	if down and (right or left):
		change_state(DIAGONAL_DOWN)
	if up and (right or left):
		change_state(DIAGONAL_UP)
	
	if flipped or initial_state != state:
		set_muzzle_position()
		flipped = false
	if shoot and can_shoot:
		shoot()
		
		
func shoot():
	emit_signal("shoot", Bullet, current_muzzle.global_position, current_bullet_direction)
	can_shoot = false
	$GunTimer.start()
	
	
func set_flip_h(true_or_false):
	if true_or_false != flip_h:
		flipped = true
	var new_state = state
	state = 228   # temporary state value
	change_state(new_state)
	flip_h = true_or_false
	
	
func set_muzzle_position():
	current_muzzle.position.x = 2 * (int(not flip_h) - 0.5) * abs(current_muzzle.position.x)


func _on_GunTimer_timeout():
	can_shoot = true
