extends Node2D

@onready var ground_sprite: Sprite2D = $GroundSprite
@onready var viewport_size := get_viewport_rect().size


func _ready() -> void:
	ground_sprite.position = Vector2(viewport_size.x / 2.0, viewport_size.y - (ground_sprite.texture.get_size().y * ground_sprite.scale.y) / 2.0)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
