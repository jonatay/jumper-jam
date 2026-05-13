extends Node2D

@onready var layer_1: Parallax2D = $Layer1
@onready var futherest_bg: Sprite2D = $Layer1/FutherestBG
@onready var layer_2: Parallax2D = $Layer2
@onready var middle_bg: Sprite2D = $Layer2/MiddleBG
@onready var layer_3: Parallax2D = $Layer3
@onready var foreground_bg: Sprite2D = $Layer3/ForegroundBG
@onready var viewport_size: Vector2 = get_viewport_rect().size

func _ready() -> void:
	futherest_bg.scale = get_px_sprite_scale(futherest_bg)
	layer_1.repeat_size = Vector2(0, futherest_bg.texture.get_size().y * futherest_bg.scale.y)
	middle_bg.scale = get_px_sprite_scale(middle_bg)
	layer_2.repeat_size = Vector2(0, middle_bg.texture.get_size().y * middle_bg.scale.y)
	foreground_bg.scale = get_px_sprite_scale(foreground_bg)
	layer_3.repeat_size = Vector2(0, foreground_bg.texture.get_size().y * foreground_bg.scale.y)


func get_px_sprite_scale(sprite: Sprite2D) -> Vector2:
	var tex: Texture2D = sprite.get_texture()
	var width: int = tex.get_width()
	var res: float = viewport_size.x / width
	return Vector2(res, res)
