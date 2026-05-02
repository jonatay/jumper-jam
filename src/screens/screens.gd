extends CanvasLayer

@onready var btn_toggle_console: TextureButton = $Debug/BtnToggleConsole
@onready var console_log: Control = $Debug/ConsoleLog
@onready var scroll_container: ScrollContainer = $Debug/ConsoleLog/ScrollContainer
@onready var scrollbar = scroll_container.get_v_scroll_bar()

var max_scroll_length = 0 

func _ready() -> void:
	console_log.visible = false
	btn_toggle_console.pressed.connect(_on_btn_toggle_console_pressed)
	scrollbar.changed.connect(handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value

func _on_btn_toggle_console_pressed() -> void:
	console_log.visible = not console_log.visible
	
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value: 
		max_scroll_length = scrollbar.max_value 
	scroll_container.scroll_vertical = max_scroll_length
	
	
