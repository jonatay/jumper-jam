extends CanvasLayer
class_name Screens

signal new_game
signal start_game
signal reset_game


@onready var title_screen: BaseScreen = $TitleScreen
@onready var pause_screen: BaseScreen = $PauseScreen
@onready var game_over_screen: BaseScreen = $GameOverScreen

@onready var btn_toggle_console: TextureButton = $Debug/BtnToggleConsole
@onready var console_log: Control = $Debug/ConsoleLog
@onready var scroll_container: ScrollContainer = $Debug/ConsoleLog/ScrollContainer
@onready var scrollbar = scroll_container.get_v_scroll_bar()
@onready var lbl_score: Label = $GameOverScreen/Box/LblScore
@onready var lbl_best: Label = $GameOverScreen/Box/LblBest

var current_screen: BaseScreen = null

var max_scroll_length = 0

func _ready() -> void:
	console_log.visible = false
	btn_toggle_console.pressed.connect(_on_btn_toggle_console_pressed)
	scrollbar.changed.connect(handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value
	register_buttons()
	change_screen(title_screen)

func register_buttons() -> void:
	var buttons = get_tree().get_nodes_in_group("screen_buttons")
	for button in buttons:
		if button is ScreenButton:
			button.clicked.connect(_on_screen_button_clicked)

func _on_screen_button_clicked(button: ScreenButton) -> void:
	SoundFX.play_sound("CLICK")
	UtlLogger.log_message("Button clicked: %s" % button.name)
	match button.name:
		"SBTitleStart":
			change_screen(null)
			await (get_tree().create_timer(0.5).timeout)
			new_game.emit()
		"SBTitleClose":
			change_screen(null)
			await (get_tree().create_timer(0.75).timeout)
			get_tree().quit()
		"SBPauseRestart":
			get_tree().paused = false
			change_screen(null)
			start_game.emit()
		"SBPauseBack":
			get_tree().paused = false
			change_screen(title_screen)
			reset_game.emit()
		"SBPauseClose":
			change_screen(null)
			await (get_tree().create_timer(0.75).timeout)
			get_tree().paused = false
		"SBGameOverRestart":
			change_screen(null)
			await (get_tree().create_timer(0.5).timeout)
			start_game.emit()
		"SBGameOverBack":
			change_screen(title_screen)
			reset_game.emit()
		_:
			UtlLogger.log_message("No action defined for button: %s" % button.name)

func _on_btn_toggle_console_pressed() -> void:
	console_log.visible = not console_log.visible
	
func handle_scrollbar_changed() -> void:
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
	scroll_container.scroll_vertical = max_scroll_length

func change_screen(new_screen: BaseScreen) -> void:
	if current_screen:
		await (current_screen.disappear()).finished

	current_screen = new_screen
	if current_screen:
		await (current_screen.appear()).finished
		get_tree().call_group("screen_buttons", "set_disabled", false)
		
func game_over(score: int, high_score: int) -> void:
	lbl_score.text = "Score: %s" % UtlFunc.add_commas_to_number(score)
	lbl_best.text = "Best: %s" % UtlFunc.add_commas_to_number(high_score)
	await (get_tree().create_timer(0.75).timeout)
	change_screen(game_over_screen)

func pause_game() -> void:
	change_screen(pause_screen)
