extends Camera2D

@export var player: Player

@onready var vp_rect := get_viewport_rect()
@onready var y_offset: float = vp_rect.size.y / 2

var y_min: float = 0.0

func _ready() -> void:
	assert(player != null, "Player node must be assigned to the camera.")
	global_position.x = 0
	
func _physics_process(_delta: float) -> void:
	#manually impose y limit
	global_position.y = min(player.global_position.y - y_offset, y_min)
	#ensure camera is climbing with player
	if global_position.y < y_min + y_offset:
		y_min = global_position.y
