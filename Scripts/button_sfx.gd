extends Button

var sfxTSCN = preload("res://Scenes/button_click_audio.tscn")
var sfxPlayer: Node2D

var hovering: bool = false

func _ready() -> void:
	sfxPlayer = sfxTSCN.instantiate()
	add_child(sfxPlayer)

func _pressed() -> void:
	sfxPlayer.playClick()

func _process(_delta: float) -> void:
	var curHovering = is_hovered()
	if (curHovering != hovering and curHovering): sfxPlayer.playHover()
	hovering = curHovering
