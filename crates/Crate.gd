extends Area2D

signal destroyed
signal item_dropped

var health = 5
var is_big_crate = false
var crate_destroyed = false
var content = Array()
var region_rects = {
	'crate_big_yellow': Rect2(0, 0, 64, 64),
	'crate_big_red': Rect2(64, 0, 64, 64),
	'crate_big_blue': Rect2(128, 0, 64, 64),
	'crate_yellow': Rect2(192, 0, 32, 32),
	'crate_green': Rect2(224, 0, 32, 32),
	'crate_blue': Rect2(192, 32, 32, 32),
	'crate_red': Rect2(224, 32, 32, 32),	
}


func _ready():
	$Explosion.hide()
	content = [
		load(ItemDatabase.get_random_item().collectible_scene_path()),
		load(ItemDatabase.get_random_bounty().collectible_scene_path()),
	]
	for _idx in range(randi() % 2 + 1):
		content.append(load(ItemDatabase.get_random_bounty().collectible_scene_path()))


func init(type, pos):
	$Sprite.region_rect = region_rects[type]
	if "big" in type:
		$AreaShape.queue_free()
		$Top/TopShape.queue_free()
		is_big_crate = true
		content.append(load(ItemDatabase.get_random_weapon().collectible_scene_path()))
		for _idx in range(randi() % 2 + 1):
			content.append(load(ItemDatabase.get_random_bounty().collectible_scene_path()))
	else:
		$Explosion.scale = Vector2(0.5, 0.5)
		$BigAreaShape.queue_free()
		$Top/BigTopShape.queue_free()
	position = pos
	
	
func spawn_content():
	for scene in content:
		var collectible = scene.instance()
		emit_signal('item_dropped', collectible, position)
		
	
func explode():
	$Sprite.hide()
	cut_collision_shapes()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	emit_signal("destroyed")
	spawn_content()
	
	
func cut_collision_shapes():
	$Top.queue_free()
	if is_big_crate:
		$BigAreaShape.queue_free()
	else:
		$AreaShape.queue_free()
	

func hurt():
	if not crate_destroyed:
		health -= 1
		if health <= 0:
			crate_destroyed = true
			explode()
		

func _on_Crate_area_entered(area):
	if area.is_in_group('bullets'):
		area.explode()
		hurt()
		

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
