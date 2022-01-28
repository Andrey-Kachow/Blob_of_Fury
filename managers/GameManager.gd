extends Node

signal player_initialised
signal score_changed

var player
var level

var player_lives = null
var num_levels = 1 # CHANGE IT
var current_level = 1
var _score = 0 setget set_score, get_score

var game_scene = 'res://Main.tscn'
var title_screen = 'res://ui/TitleScreen.tscn'


func _ready():
	randomize()


func _process(delta):
	if not player:
		initialise_player()
		return
	if not level:
		initialise_level()
		return

func initialise_player():
	#player = get_tree().get_root().get_node("/root/Main/Level%s/Player" % current_level_name())
	player = get_tree().get_root().get_node("/root/Level%s/Player" % current_level_pad_zeroes())
	if not player:
		return
		
	emit_signal("player_initialised", player)
	player.weapons.connect("weapons_changed", self, "_on_Player_weapons_changed")
	
	#var existing_weapons = load("user://weapons.tres")
	#if existing_weapons:
	#	player.weapons.set_weapons(existing_weapons.get_weapons())
	#else:
	player.weapons.set_default_weapons()
	#player_lives = 5
	player.emit_signal("life_changed")
	

func initialise_level():
	#level = get_tree().get_root().get_node("/root/Main/Level%s" % current_level_pad_zeroes())
	level = get_tree().get_root().get_node("/root/Level%s" % current_level_pad_zeroes())
	level.connect("score_increased", self, "_on_Level_score_increased")
	
	
func _on_Player_weapons_changed(weapons):
	ResourceSaver.save("user://weapons.tres", weapons)
	

func _on_Level_score_increased(addition_to_score):
	increase_score(addition_to_score)
	

func current_level_pad_zeroes():
	return str(current_level).pad_zeros(2)
	

func get_score():
	return _score
	

func set_score(value):
	_score = value
	emit_signal("score_changed", _score)
	

func increase_score(addition_to_score):
	set_score(get_score() + addition_to_score)	


#func restart():
#	current_level = 1
#	get_tree().change_scene(title_screen)


#func next_level():
#	current_level += 1
#	if current_level <= num_levels:
#		get_tree().reload_current_scene()
#	else:
#		restart()
