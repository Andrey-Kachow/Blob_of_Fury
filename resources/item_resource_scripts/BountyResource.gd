extends Resource
class_name BountyResource

export var name : String
export var score_bonus : int


func collectible_scene_path():
	return "res://collectibles/bounties/%s.tscn" % name.capitalize()


#const editor = preload("res://utility_scripts/string_editor.gd")


#func collectible_scene_path():
#	return "res://collectibles/weapons/Collectible%s.tscn" % editor.pascal_case(name)
	
	
#func weapon_scene_path():
#	return "res://weapons/%s/%s.tscn" % [editor.snake_case(name), editor.pascal_case(name)]


#func hud_weapon_texture_path():
#	return "res://assets/ui/hud_weapons/hud_%s.png" % editor.snake_case(name)

