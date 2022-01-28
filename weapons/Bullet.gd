extends Area2D

export (int) var speed

var velocity = Vector2()


func _ready():
	$BulletExplosion.hide()


func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(dir)
	

func _process(delta):
	position += velocity * delta
	
	
func explode():
	$Sprite.hide()
	$BulletExplosion.show()
	$BulletExplosion/AnimationPlayer.play("explosion")
	velocity = Vector2()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body.name == "Player":
		body.hurt()
	explode()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
