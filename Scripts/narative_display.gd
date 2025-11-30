extends Control


var objective_text: String = "CURRENTLY   NOT   AVAILABLE   -   "
const MAX_DISPLAY_LENGTH: int = 12
var text_pos: int = 0;

func _on_text_scroll_timeout() -> void:
	text_pos = (text_pos + 1) % objective_text.length()
	$Objective.text = objective_text.substr(text_pos) + objective_text.substr(0, text_pos)
