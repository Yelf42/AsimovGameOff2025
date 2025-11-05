extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		togglePause()


func togglePause() -> void:
	get_tree().paused = !get_tree().paused
	if (get_tree().paused):
		self.show()
	else:
		self.hide()


func _on_resume_pressed() -> void:
	togglePause()
