extends TextureButton
class_name ScreenButton

signal clicked(button: TextureButton)

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	on_button_pressed(self )
	
func on_button_pressed(button: TextureButton) -> void:
	clicked.emit(button)
