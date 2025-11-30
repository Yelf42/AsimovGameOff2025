extends Control


var root
var queueSkip = false

var cutscene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene
	cutscene = $CutsceneBlocker/CutscenePlayer

func _process(_delta: float) -> void:
	if (queueSkip): skipCutscene()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		queueSkip = cutscene.is_playing()

func _on_play_pressed() -> void:
	$CutsceneBlocker.show()
	cutscene.play("Cutscene")
	skipCutscene() # TODO: Remove when/if cutscene is added

func _on_cutscene_player_animation_finished() -> void:
	root.startGame()
	$CutsceneBlocker.hide()
	self.hide()

func skipCutscene() -> void:
	cutscene.stop()
	cutscene.set_frame_and_progress(0, 0.0)
	root.startGame()
	$CutsceneBlocker.hide()
	self.hide()
	queueSkip = false
