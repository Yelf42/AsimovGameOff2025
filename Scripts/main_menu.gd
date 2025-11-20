extends Control


var root
var queueSkip = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene

func _process(_delta: float) -> void:
	if (queueSkip): skipCutscene()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		queueSkip = $CutscenePlayer.is_playing()

func _on_play_pressed() -> void:
	$CutscenePlayer.show()
	$CutscenePlayer.play("Cutscene")

func _on_cutscene_player_animation_finished() -> void:
	root.startGame()
	$CutscenePlayer.hide()
	self.hide()

func skipCutscene() -> void:
	$CutscenePlayer.stop()
	$CutscenePlayer.set_frame_and_progress(0, 0.0)
	root.startGame()
	$CutscenePlayer.hide()
	self.hide()
	queueSkip = false
