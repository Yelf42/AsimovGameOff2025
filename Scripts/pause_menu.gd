extends Control

var root

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		togglePause()

func togglePause() -> void:
	if (!root.canPause()): return
	get_tree().paused = !get_tree().paused
	if (get_tree().paused):
		self.show()
	else:
		self.hide()


func _on_resume_pressed() -> void:
	togglePause()


func _on_main_menu_pressed() -> void:
	root.openMainMenu()
	self.hide()
