extends Area2D
class_name Platform

var bounce_count: int = 0

func _ready() -> void:
	body_entered.connect(_body_entered)

func _body_entered(body: Node) -> void:
	if (body is Player) && (body.velocity.y > 0):
		(body as Player).jump()
		# bounce_count += 1
		if bounce_count > 1:
			queue_free()
