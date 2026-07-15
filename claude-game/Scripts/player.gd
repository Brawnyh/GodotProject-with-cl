extends CharacterBody3D

const WALK_SPEED = 40
const RUN_SPEED = 60
const JUMP_VELOCITY = 25
const ACCEL = 10.0
const MOUSE_SENS = 0.003
const MAX_AMMO = 8
const MAX_HITS = 5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")*3
var ammo = MAX_AMMO
var hits_taken = 0
var reloading = false

@onready var camera_pivot = $CameraPivot
@onready var shoot_ray = $CameraPivot/Camera3D/ShootRay
@onready var hurtbox = $Hurtbox

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	GameManager.register_hud($"../HUD/AmmoLabel", $"../HUD/TimerLabel", $"../HUD/CollectedLabel", $"../HUD/EndLabel")
	_update_ammo_label()
	add_to_group("player")

func _unhandled_input(event):
	if not GameManager.game_active:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENS)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(15))
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()
	if event is InputEventKey and event.keycode == KEY_R and event.pressed:
		reload()

func shoot():
	if reloading or not GameManager.game_active:
		return
	if ammo <= 0:
		reload()
		return
	ammo -= 1
	_update_ammo_label()
	if shoot_ray.is_colliding():
		var collider = shoot_ray.get_collider()
		if collider and collider.name == "HeadHitbox":
			collider.get_parent().take_damage(999)
		elif collider and collider.name == "BodyHitbox":
			collider.get_parent().take_damage(1)

func reload():
	if reloading:
		return
	reloading = true
	await get_tree().create_timer(1.2).timeout
	ammo = MAX_AMMO
	reloading = false
	_update_ammo_label()

func _update_ammo_label():
	if GameManager.hud_ammo_label:
		GameManager.hud_ammo_label.text = "Ammo: %d / %d" % [ammo, MAX_AMMO]

func _on_hurtbox_area_entered(area):
	if area.name == "AttackArea" and GameManager.game_active:
		hits_taken += 1
		if hits_taken >= MAX_HITS:
			GameManager.lose("¡Los enemigos te atraparon!")

func _physics_process(delta):
	if not GameManager.game_active:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var speed = RUN_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, ACCEL * delta * speed)
		velocity.z = move_toward(velocity.z, direction.z * speed, ACCEL * delta * speed)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta * speed)
		velocity.z = move_toward(velocity.z, 0, ACCEL * delta * speed)
	move_and_slide()
