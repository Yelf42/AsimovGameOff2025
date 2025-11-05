extends ColorRect

const WAVE_RESOLUTION = 200;

var gap
var mid
var root
@export var target_line_color: Color
@export var player_line_color: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene
	mid = self.size/2
	gap = (2*mid.x - 2*(mid.x/3)) / WAVE_RESOLUTION


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	drawTarget()
	drawPlayer()

# Draw player
func drawPlayer() -> void:
	for i in range(1,WAVE_RESOLUTION+1):
		var d1x = mid.x/3 + (gap*(i-1))
		var d1y = mid.y + root.getPlayerFunction(d1x)
		var d2x = mid.x/3 + (gap*i)
		var d2y = mid.y + root.getPlayerFunction(d2x)
		draw_line(Vector2(d1x,d1y),Vector2(d2x,d2y),player_line_color,3)

# Draw target
func drawTarget() -> void:
	for i in range(1,WAVE_RESOLUTION+1):
		var d1x = mid.x/3 + (gap*(i-1))
		var d1y = mid.y + root.getTargetFunction(d1x)
		var d2x = mid.x/3 + (gap*i)
		var d2y = mid.y + root.getTargetFunction(d2x)
		draw_line(Vector2(d1x,d1y),Vector2(d2x,d2y),target_line_color,3)

func getXBounds() -> Vector2:
	return Vector2(mid.x / 3, mid.x/3 + (gap*(WAVE_RESOLUTION+1)))

func getY() -> float:
	return mid.y;
