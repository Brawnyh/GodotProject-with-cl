extends Area3D

enum Type { MONSTER, AMMO, TIME }
@export var type: Type = Type.MONSTER
@export var time_bonus: float = 20.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "Player":
		return
	match type:
		Type.MONSTER:
			GameManager.collect_item()
		Type.AMMO:
			body.ammo = body.MAX_AMMO
			body._update_ammo_label()
		Type.TIME:
			GameManager.add_time(time_bonus)
	queue_free()
