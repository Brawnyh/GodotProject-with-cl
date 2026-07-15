extends Node

var total_targets = 2
var collected = 0
var time_left = 180.0
var game_active = true

var hud_ammo_label: Label
var hud_timer_label: Label
var hud_collected_label: Label
var hud_end_label: Label

func _process(delta):
	if not game_active:
		return
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		lose("¡Se acabó el tiempo!")
	_update_timer_label()

func register_hud(ammo_label, timer_label, collected_label, end_label):
	hud_ammo_label = ammo_label
	hud_timer_label = timer_label
	hud_collected_label = collected_label
	hud_end_label = end_label
	_update_collected_label()
	_update_timer_label()
	

func add_time(seconds):
	time_left += seconds

func collect_item():
	collected += 1
	_update_collected_label()
	if collected >= total_targets:
		win()

func _update_collected_label():
	if hud_collected_label:
		hud_collected_label.text = "Objetos: %d / %d" % [collected, total_targets]

func _update_timer_label():
	if hud_timer_label:
		var m = int(time_left) / 60.0
		var s = int(time_left) % 60
		hud_timer_label.text = "Time: %d:%02d" % [m, s]

func win():
	game_active = false
	if hud_end_label:
		hud_end_label.text = "¡GANASTE!\nRecogiste los 15 objetos"
		hud_end_label.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func lose(reason):
	game_active = false
	if hud_end_label:
		hud_end_label.text = "PERDISTE\n" + reason
		hud_end_label.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
