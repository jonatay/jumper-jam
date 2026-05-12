extends Control
class_name BaseScreen


func _ready() -> void:
	#print(self.name, " ready")
	visible = false
	modulate.a = 0.0

	get_tree().call_group("screen_buttons", "set_disabled", true)
	
func appear():
	visible = true
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self , "modulate:a", 1.0, 0.5)
	return tween

func disappear():
	get_tree().call_group("screen_buttons", "set_disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_property(self , "modulate:a", 0.0, 0.5)
	visible = false
	return tween
