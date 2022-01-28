extends Node

var weapons = Array()
var bounties = Array()


func _ready():
	# weapons
	var directory = Directory.new()
	directory.open("res://resources/items/weapons")
	directory.list_dir_begin()
	
	var filename = directory.get_next()
	while filename:
		if not directory.current_is_dir():
			weapons.append(load("res://resources/items/weapons/%s" % filename))
		filename = directory.get_next()
	
	# bounties
	directory = Directory.new()
	directory.open("res://resources/items/bounties")
	directory.list_dir_begin()
	
	filename = directory.get_next()
	while filename:
		if not directory.current_is_dir():
			bounties.append(load("res://resources/items/bounties/%s" % filename))
		filename = directory.get_next()


func get_item(item_name):  # Maybe remove later?
	for item_list in [weapons, bounties]:
		for item in item_list:
			if item.name == item_name:
				return item
	return null
	

func get_weapon(weapon_name):
	for weapon in weapons:
		if weapon.name == weapon_name:
			return weapon
	return null
	
	
func get_bounty(bounty_name):
	for bounty in bounties:
		if bounty.name == bounty_name:
			return bounty
	return null


func get_random_item():  # non-pistol item
	var items = weapons if randi() % 2 else bounties
	var index = randi() % len(items)
	while items[index].name == "Pistol":
		index = randi() % len(items)
	return items[index]
	

func get_random_weapon():  # non-pistol item
	var index = randi() % len(weapons)
	while weapons[index].name == "Pistol":
		index = randi() % len(weapons)
	return weapons[index]
	

func get_random_bounty():
	return bounties[randi() % len(bounties)]
