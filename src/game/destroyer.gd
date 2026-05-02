extends Area2D

@onready var destroyer: Area2D = $"."
@onready var destroyer_shape: CollisionShape2D = $DestroyerShape
@onready var viewport_size := get_viewport_rect().size


func _ready() -> void:
	destroyer.position = Vector2(viewport_size.x / 2.0, viewport_size.y + 20)

	var rs2d := RectangleShape2D.new()
	rs2d.set_size(Vector2(viewport_size.x, 20))
	
	destroyer_shape.shape = rs2d

func _process(_delta: float) -> void:
	var overlapping_areas = destroyer.get_overlapping_areas()
	if overlapping_areas.size() > 0:
		for area in overlapping_areas:
			print("Destroying area: ", area.name)
			area.queue_free()
