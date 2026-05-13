extends Node2D
class_name Game

signal game_over(score: int, high_score: int)
signal game_paused

@export var player_scene: PackedScene
@export var camera_scene: PackedScene


@onready var platforms: Platforms = $Platforms
@onready var ground_sprite: Sprite2D = $GroundSprite
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var hud: HUD = $UILayer/HUD

var player: Player
var camera: GameCamera

var player_spawn_pos: Vector2
var spawn_pos_y_offset: int = 135

var score: int
var high_score: int
var save_file_path: String = "user://high_score.save"

var new_skin_unlocked: bool = false

func _ready() -> void:
	ground_sprite.position = Vector2(viewport_size.x / 2.0, viewport_size.y - (ground_sprite.texture.get_size().y * ground_sprite.scale.y) / 2.0)
	player_spawn_pos = Vector2(viewport_size.x / 2.0, viewport_size.y - spawn_pos_y_offset)
	hud.hide()
	hud.set_score(0)
	hud.pause_pressed.connect(_on_hud_pause_pressed)
	load_high_score()
	# start_game()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	if player:
		score = max(score, int(viewport_size.y - player.global_position.y))
		if hud && hud.i_score != score:
			hud.set_score(score)
		# print("Score: %s" % score)


func new_game() -> void:
	player = player_scene.instantiate()
	add_child(player)
	player.player_died.connect(on_player_died)
	if new_skin_unlocked:
		player.use_new_skin()

	platforms.player = player
	platforms.start_level_generation()

	camera = camera_scene.instantiate()
	camera.player = player
	add_child(camera)

	start_game()

func start_game() -> void:
	score = 0
	player.ressurect()
	player.position = player_spawn_pos
	camera.reset_camera()
	hud.set_score(0)
	hud.show()
	ground_sprite.show()

func reset_game() -> void:
	platforms.reset_level()
	if player:
		player.queue_free()
		player = null
		platforms.player = null
	if camera:
		camera.queue_free()
		camera = null
	ground_sprite.hide()
	hud.hide()

func on_player_died() -> void:
	hud.hide()
	if score > high_score:
		high_score = score
		save_high_score()
	game_over.emit(score, high_score)

func save_high_score() -> void:
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()

func load_high_score() -> void:
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		high_score = file.get_32()
		file.close()
	else:
		high_score = 0

func _on_hud_pause_pressed() -> void:
	get_tree().paused = true
	game_paused.emit()

func unlock_new_skin() -> void:
	new_skin_unlocked = true
	if player:
		player.use_new_skin()
