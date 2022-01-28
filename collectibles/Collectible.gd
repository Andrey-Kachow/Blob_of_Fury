extends RigidBody2D

signal pickup

enum collectible_type {NONE, WEAPON, BOUNTY}

export (collectible_type) var type
export (String) var _name  # name of the weapon


func _ready():
	GameManager.connect("player_initialised", self, "_on_Player_initialised")
	if GameManager.player:
		connect("pickup", GameManager.player, "_on_Collectible_pickup")
	
	
func _on_Player_initialised(player):
	connect("pickup", GameManager.player, "_on_Collectible_pickup") # maybe later put somethere else


func init(pos, vel):
	position = pos
	linear_velocity = vel
	angular_velocity = rand_range(-5, 5)
	

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		emit_signal('pickup', self)
		queue_free()
