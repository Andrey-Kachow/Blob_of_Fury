extends Resource
class_name PlayerWeapons

signal weapons_changed

export var _weapons = Array() setget set_weapons, get_weapons


func set_weapons(new_weapons):
	_weapons = new_weapons
	emit_signal("weapons_changed", self)
	
	
func get_weapons():
	return _weapons
	
	
func set_weapon(index, new_weapon):
	var weapons = get_weapons()
	weapons[index] = ItemDatabase.get_weapon(new_weapon)
	set_weapons(weapons)


func get_item(index):
	return _weapons[index]
	

func set_default_weapons():
	set_weapons([ItemDatabase.get_weapon("Pistol"), ItemDatabase.get_weapon("Pistol")])
	

func print_weapon_names():
	print(get_weapons()[0].name, " ", get_weapons()[1].name)
