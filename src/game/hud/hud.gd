extends Control
class_name HUD

signal pause_pressed

@onready var top_bar_bg: ColorRect = $TopBarBG
@onready var top_bar: Control = $TopBar
@onready var lbl_score: Label = $TopBar/ScoreBox/LblScore

var i_score: int

func _ready() -> void:
	var os_name: String = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		var safe_area: Rect2i = DisplayServer.get_display_safe_area()
		var safe_area_top: int = safe_area.position.y
		#print(DisplayServer.screen_get_scale())		
		top_bar.position.y += safe_area_top
		top_bar_bg.size.y += safe_area_top

		UtlLogger.log_message("os name: " + os_name)
		UtlLogger.log_message("safe area: " + str(safe_area))
		UtlLogger.log_message("top bar position: " + str(top_bar.position))
		UtlLogger.log_message("Window size: " + str(DisplayServer.window_get_size()))

func _on_tbhud_pause_pressed() -> void:
	pause_pressed.emit()


func set_score(score: int) -> void:
	i_score = score
	lbl_score.text = "Score: " + UtlFunc.add_commas_to_number(i_score)
