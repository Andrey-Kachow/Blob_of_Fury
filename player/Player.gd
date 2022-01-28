extends KinematicBody2D

signal life_changed
signal dead
signal weapons_swapped
signal weapon_scene_changed
signal grounded_updated(is_grounded)

export (int) var run_speed
export (int) var jump_speed
export (int) var gravity

const SNAP_DISTANCE = 5
const JUMP_DOWN_PLATFORMS_BIT = 1
const INITIAL_LIVES = 5

enum {
	IDLE, RUN, JUMP, HURT, CROUCH,
	DOWN, UP, DIAGONAL_UP, DIAGONAL_DOWN
}
var state

var anim
var new_anim
var weapon_shifter_anim
var new_weapon_shifter_anim
var velocity = Vector2()
var current_flip_h = false
var snap = false
var invulnerable = false
var dead = false
var is_grounded

var weapons_resource = load("res://player/PlayerWeapons.gd")
var weapons = weapons_resource.new()
var current_weapon = 0  # 0 or 1 only
var weapon_node = null


func _ready():
	change_state(IDLE)
	weapons.connect("weapons_changed", self, "_on_Player_weapons_changed")
	weapon_node = $WeaponContainer.get_children()[0]
	

func change_state(new_state):  # Make damage system like in contra
	if state != new_state:
		state = new_state
		if state != CROUCH:
			$CollisionShape.set_deferred("disabled", false)
			$CrouchShape.set_deferred("disabled", true)
		match state:
			IDLE:
				new_anim = 'idle'
			RUN:
				new_anim = 'run'
			HURT:
				player_hide()
				$PlayerDeath.show()
				$PlayerDeath/AnimationPlayer.play("bloodsplash")
				weapons.set_weapon(current_weapon, "Pistol")
				set_weapon_cannot_shoot(true)
				$Sprite.material.set_shader_param("invulnerable", true)
				invulnerable = true
				GameManager.player_lives -= 1
				emit_signal('life_changed')
				if GameManager.player_lives <= 0:
					emit_signal("dead")
					var dead = true
				else:
					yield(get_tree().create_timer(3), "timeout")
					recover(GameManager.player_lives)	
			JUMP:
				new_anim = 'jump'
			CROUCH:
				new_anim = 'crouch'
				$CrouchShape.disabled = false
				$CollisionShape.disabled = true
				position.y -= SNAP_DISTANCE
			DOWN:
				new_anim = 'down'
			UP:
				new_anim = 'up'
			DIAGONAL_UP:
				new_anim = 'diagonal_up'
			DIAGONAL_DOWN:
				new_anim = 'diagonal_down'
				

#func _process(_delta):
	#print(sign(0))
	#weapons.print_weapon_names()

	
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	
	if new_anim != anim:
		anim = new_anim
		$AnimationPlayer.play(anim)
	if new_weapon_shifter_anim != weapon_shifter_anim:
		weapon_shifter_anim = new_weapon_shifter_anim
		$WeaponShifter.play(weapon_shifter_anim)
		
	var snap_vector = Vector2(0, SNAP_DISTANCE) if snap else Vector2()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2(0, -1), true)
	if not is_on_floor():
		snap = true
	
	var was_grounded = is_grounded	
	is_grounded = is_on_floor()
	
	if was_grounded == null or is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
	
	if state == HURT:
		return
	#for idx in range(get_slide_count()):
		#var collision = get_slide_collision(idx)
		#if collision.collider.name == 'Danger':
		#	hurt()
		#if collision.collider.is_in_group('enemies'):
		#	pass
	#if position.y > 1000:
	#	change_state(DEAD)
	
	
func get_input():
	if state == HURT:
		if is_on_floor():
			velocity.x = 0
		return
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	#var shoot = Input.is_action_just_pressed("shoot")
	var down = Input.is_action_pressed("down")
	var up = Input.is_action_pressed('up')
	var change_weapon = Input.is_action_just_pressed("change_weapon")
	var stand = Input.is_action_pressed("stand")
	
	if right and left:
		right = false
		left = false
	if up and down:
		up = false
		down = false
	
	velocity.x = 0
	if right:
		velocity.x += run_speed
		set_flip_h(false)
	if left:
		velocity.x -= run_speed
		set_flip_h(true)
	if jump and is_on_floor() and state != CROUCH:
		change_state(JUMP)  # this might be redundant
		velocity.y = jump_speed
		snap = false
	if down and is_on_floor() and not stand:
		change_state(CROUCH)
		if jump:
			set_collision_mask_bit(JUMP_DOWN_PLATFORMS_BIT, false)
	if not down and state == CROUCH:
		change_state(IDLE)
	if up and is_on_floor():
		change_state(UP)
	if not up and state == UP:
		change_state(IDLE)
	if stand:
		velocity.x = 0
		if up and (right or left):
			change_state(DIAGONAL_UP)
		elif up:
			change_state(UP)
		elif down and (right or left):
			change_state(DIAGONAL_DOWN)
		elif down:
			change_state(DOWN)
		else:
			change_state(IDLE)
	if change_weapon and not invulnerable:
		swap_weapons()
	
	if state in [IDLE, CROUCH, UP] and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if not (state in [HURT, JUMP]) and not is_on_floor():
		change_state(JUMP)
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if state != RUN:
		new_weapon_shifter_anim = "idle"
		
	
func start(pos):
	if not GameManager.player_lives:
		GameManager.player_lives = INITIAL_LIVES
		emit_signal("life_changed")
	position = pos
	show()
	change_state(IDLE)
	

func hurt():
	if state != HURT and not invulnerable:
		change_state(HURT)
	
		
func player_hide():
	$Sprite.hide()
	$WeaponContainer.hide()


func player_show():
	$Sprite.show()
	$WeaponContainer.show()
		

func recover(lives=INITIAL_LIVES):
	GameManager.player_lives = lives
	emit_signal("life_changed")
	change_state(IDLE)
	dead = false
	$Sprite.flip_h = weapon_node.flip_h
	player_show()
	weapon_node.material.set_shader_param("invulnerable", true)
	$InvulnerabilityTimer.start()
	
	
func set_flip_h(true_or_false):
	if true_or_false != current_flip_h:
		current_flip_h = true_or_false
		$Sprite.flip_h = true_or_false
		position.y -= 1
		$CollisionShape.position.x = 2 + (-4) * int(true_or_false)
		$CrouchShape.position.x = 2 + (-4) * int(true_or_false)
		$AnimationPlayer.stop()
		$AnimationPlayer.play(anim)
	if state == RUN:
		new_weapon_shifter_anim = "left" if current_flip_h else "right"
		

func set_weapon_cannot_shoot(true_or_false):
	weapon_node.owner_hurt = true_or_false
	

func swap_weapons():
	current_weapon = (current_weapon + 1) % 2
	change_weapon_scene(weapons)
	emit_signal("weapons_swapped", current_weapon)
	

func _on_Collectible_pickup(collectible):
	if collectible.type == 1:  # 1 is WEAPON type
		weapons.set_weapon(current_weapon, collectible._name)
	else:
		GameManager.increase_score(ItemDatabase.get_item(collectible._name).score_bonus)
		pass  # add score
		
		
func _on_Player_weapons_changed(_weapons):
	change_weapon_scene(_weapons)
	
	
func change_weapon_scene(_weapons):
	weapon_node.queue_free()
	var weapon = load(weapons.get_weapons()[current_weapon].weapon_scene_path())
	weapon = weapon.instance()
	weapon.flip_h = $Sprite.flip_h
	$WeaponContainer.add_child(weapon)
	weapon_node = weapon
	emit_signal("weapon_scene_changed", weapon)
	
	
func _on_Feet_body_exited(body):
	set_collision_mask_bit(JUMP_DOWN_PLATFORMS_BIT, true)


func _on_InvulnerabilityTimer_timeout():
	invulnerable = false
	$Sprite.material.set_shader_param("invulnerable", false)
	weapon_node.material.set_shader_param("invulnerable", false)
	set_weapon_cannot_shoot(false)


func _on_AnimationPlayer_animation_finished(anim_name):
	$PlayerDeath.hide()
