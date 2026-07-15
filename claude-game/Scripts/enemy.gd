extends CharacterBody3D

const SPEED = 60
const DETECT_RADIUS = 12.0
const MAX_HEALTH = 3

var health = MAX_HEALTH
var player: Node3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	player = get_tree().get_first_node_in_group("player")

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()

func _physics_process(delta):
	if not GameManager.game_active or not player:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	var dist = global_position.distance_to(player.global_position)
	if dist <= DETECT_RADIUS:
		var dir = (player.global_position - global_position)
		dir.y = 0
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()
