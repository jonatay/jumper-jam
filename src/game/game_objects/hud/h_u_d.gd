extends Control

@onready var top_bar_bg: ColorRect = $TopBarBG
@onready var top_bar: Control = $TopBar

func _ready() -> void:
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y
		#print(DisplayServer.screen_get_scale())		
		top_bar.position.y += safe_area_top
		top_bar_bg.size.y += safe_area_top

		UtlLogger.log_message("os name: " + os_name)
		UtlLogger.log_message("safe area: " + str(safe_area))
		UtlLogger.log_message("top bar position: " + str(top_bar.position))
		UtlLogger.log_message("Window size: " + str(DisplayServer.window_get_size()))

func _on_tbhud_pause_pressed() -> void:
	pass # Replace with function body.
