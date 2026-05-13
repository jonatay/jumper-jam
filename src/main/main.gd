extends Node
class_name Main

@onready var screens: Screens = $Screens
@onready var game: Game = $Game
@onready var iap_manager: Node = $IAPManager

func _ready() -> void:
	DisplayServer.window_set_window_event_callback(_on_window_event)

	screens.new_game.connect(game.new_game)
	screens.start_game.connect(game.start_game)
	game.game_over.connect(screens.game_over)
	screens.reset_game.connect(game.reset_game)
	game.game_paused.connect(screens.pause_game)
	screens.purchase_skin.connect(game.unlock_new_skin)

func _on_window_event(event: DisplayServer.WindowEvent) -> void:
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			UtlLogger.log_message("Window focused")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			UtlLogger.log_message("Window unfocused")
			if not screens.current_screen:
				get_tree().paused = true
				screens.pause_game()
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			UtlLogger.log_message("Window close request")
			get_tree().quit()
