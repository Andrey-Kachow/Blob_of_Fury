extends Area2D

signal shoot
signal destroyed

export (PackedScene) var Bullet
export (int) var health = 7
export (float) var rotation_speed = PI / 2

var target = null
var can_shoot = true
var turret_destroyed = false

onready var muzzles = [$Muzzle01, $Muzzle02]


func _ready():
	$Explosion.hide()
	GameManager.connect("player_initialised", self, "_on_Player_initialised")
	rotation = 0.69
	

func _process(delta):
	if target and not turret_destroyed:
		var target_dir = target.global_position - global_position
		target_dir = target_dir.rotated(0).angle()
		if target_dir - 0.1 < rotation and rotation < target_dir + 0.1 and can_shoot:
			shoot_pulse()
		else:
			rotation = rotation + rotation_speed * delta * sign(target_dir - rotation)
	
	
func shoot_pulse():
	var current_muzzle = randi() % 2
	for idx in range(3 + randi() % 2):
		shoot(current_muzzle)
		current_muzzle = (current_muzzle + 1) % 2
		$PulseDelayTimer.start()
		yield($PulseDelayTimer, "timeout")
	
	
func shoot(muzzle):
	emit_signal("shoot", Bullet, muzzles[muzzle].global_position, rotation)
	can_shoot = false
	$GunTimer.start()
	

func take_damage(value):
	health -= value
	if health <= 0:
		turret_destroyed = true
		explode()
		
	
func explode():
	$Sprite.hide()
	$CollisionShape2D.queue_free()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	emit_signal("destroyed")
	
	
func _on_Player_initialised(player):
	target = player
	

func _on_GunTimer_timeout():
	can_shoot = true


func _on_Turret_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage(1)
		area.explode()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
