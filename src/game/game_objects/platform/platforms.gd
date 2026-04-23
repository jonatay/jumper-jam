extends Node2D
class_name Platforms

@export var player: Player
@export var platform_scenes: Array[PackedScene]
@export var y_platform_spacing: int = 150
@export var platform_x_range: int = 200
@export var level_size: int = 50

@onready var viewport_size := get_viewport_rect().size
@onready var start_platform_y: float = viewport_size.y - (y_platform_spacing * 2.0)

var platform_width: int = 134
var platform_counter: int = 0
var levels_counter: int = 0
var level_idx: int = 0

func _ready() -> void:
	assert(player != null, "Player node must be assigned.")
	assert(platform_scenes.size() > 0, "At least one platform scene must be assigned.")
	generate_ground_platforms(level_idx)
	generate_level_platforms(level_idx)

func _process(_delta: float) -> void:
	if player.position.y < start_platform_y - (levels_counter * y_platform_spacing * level_size) + viewport_size.y:
		level_idx += 1
		if level_idx >= platform_scenes.size():
			level_idx = 0
		generate_level_platforms(level_idx)

func generate_ground_platforms(platform_idx: int) -> void:
	for x in range(- (platform_width + 2), int(viewport_size.x) + (platform_width + 2), platform_width + 2):
		create_platform(platform_idx, Vector2(x, viewport_size.y - 62))

func generate_level_platforms(platform_idx: int) -> void:
	for i in range(level_size):
		var platform_x: float = randf_range(0.0, viewport_size.x - platform_width)
		var platform_y: float = start_platform_y - ((i + (levels_counter * level_size)) * y_platform_spacing)
		create_platform(platform_idx, Vector2(platform_x, platform_y))
	levels_counter += 1


func create_platform(platform_idx: int, platform_position: Vector2) -> void:
	assert(platform_idx >= 0 and platform_idx < platform_scenes.size(), "Platform index out of range.")
	var platform_instance = platform_scenes[platform_idx].instantiate()
	platform_instance.position = platform_position
	add_child(platform_instance)
	platform_counter += 1
