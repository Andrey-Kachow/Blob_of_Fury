extends CanvasLayer


func _ready():
	GameManager.connect("player_initialised", self, "_on_Player_initialised")
	GameManager.connect("score_changed", self, "_on_GameManager_score_changed")
	
	
func _on_Player_initialised(player):
	player.weapons.connect("weapons_changed", self, "_on_Player_weapons_changed")
	player.connect("weapons_swapped", self, "_on_Player_weapons_swapped")
	player.connect("life_changed", self, "_on_Player_life_changed")
	
	
func _on_Player_weapons_changed(weapons):
	var texture1 = load(weapons.get_weapons()[0].hud_weapon_texture_path())
	var texture2 = load(weapons.get_weapons()[1].hud_weapon_texture_path())
	$MarginContainer/HBoxContainer/Weapons/Weapon1.texture = texture1
	$MarginContainer/HBoxContainer/Weapons/Weapon2.texture = texture2
	

func _on_Player_weapons_swapped(weapon_index):
	var pointer = $MarginContainer/HBoxContainer/Weapons/Pointer
	pointer.rect_position.x = weapon_index * 32
	

func _on_GameManager_score_changed(new_score):
	$MarginContainer/HBoxContainer/ScoreLabel.text = str(new_score)
	

func _on_Player_life_changed():
	$MarginContainer/HBoxContainer/LivesCounter/LivesLabel.text = str(GameManager.player_lives)
