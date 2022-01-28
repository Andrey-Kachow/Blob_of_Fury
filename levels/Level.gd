extends Node

signal score_increased

const CRATE_DESTRUCTION_SCORE_BONUS = 10

onready var crates = $Crates

var Crate = preload("res://crates/Crate.tscn")


func _ready():
	crates.hide()
	spawn_crates()
	$Player.start($PlayerSpawn.position)
	$Player.connect("weapon_scene_changed", self, "_on_Player_weapon_scene_changed")
	set_camera_limits()
	
	#Temporary
	$EnemiesContainer/Turret.connect("shoot", self, "_on_Turret_shoot")
	
	
func set_camera_limits():
	var map_size = $SolidEnvironment.get_used_rect()
	var cell_size = $SolidEnvironment.cell_size
	var camera = $Player/PlayerCamera
	camera.limit_left = (map_size.position.x) * cell_size.x
	camera.limit_right = (map_size.end.x) * cell_size.x
	camera.limit_top = 0
	camera.limit_bottom = (map_size.end.y) * cell_size.y
	

func spawn_crates():
	for cell in crates.get_used_cells():
		var id = crates.get_cellv(cell)
		var type = crates.tile_set.tile_get_name(id)
		
		var crate_size = 32 if "big" in type else 16
		
		var c = Crate.instance()
		var pos = crates.map_to_world(cell)
		c.init(type, pos + Vector2(crate_size, crate_size))
		$CrateContainer.add_child(c)
		c.connect("destroyed", self, "_on_Crate_destroyed")
		c.connect("item_dropped", self, "_on_Crate_item_dropped")
		

func _on_Crate_destroyed():
	emit_signal("score_increased", CRATE_DESTRUCTION_SCORE_BONUS)
	

func _on_Crate_item_dropped(collectible, pos):
	collectible.init(pos, Vector2(rand_range(-50, 50), rand_range(-70, -140)))
	$CollectibleContainer.call_deferred("add_child", collectible)
	

func _on_Player_weapon_scene_changed(weapon):
	weapon.connect("shoot", self, "_on_Player_shoot")


func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	$BulletContainer.add_child(b)
	
	
func _on_Turret_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	$BulletContainer.add_child(b)
	
	
func _on_Player_dead():
	pass

