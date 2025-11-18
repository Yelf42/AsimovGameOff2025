extends ColorRect

const WAVE_RESOLUTION = 500;

var gap
var mid
var root
@export var target_line_color: Color
@export var player_line_color: Color

var packageGlitch: bool = false
const PACKAGE_GLITCH_RADIUS = 150.0
var mouthGlitch: bool = false
const MOUTH_GLITCH_RADIUS = 80.0

var circle = preload("res://Scenes/circle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene
	mid = self.size/2
	gap = (2*mid.x - 2*(mid.x/3)) / WAVE_RESOLUTION
	for i in range(WAVE_RESOLUTION):
		$PlayerWave.add_child(circle.instantiate())
		$TargetWave.add_child(circle.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	drawPlayerWave()
	drawTargetWave()

# Draw player
func drawPlayerWave() -> void:
	for i in range(WAVE_RESOLUTION):
		var d1x = mid.x/3 + (gap*i)
		var d1y = mid.y + root.getPlayerFunction(d1x)
		var d1xy = Vector2(d1x,d1y) + self.position
		
		var col = player_line_color
		if (mouthGlitch):
			var dist = INF
			for mth in root.mouths.get_children():
				dist = min(dist, d1xy.distance_squared_to(mth.position))
			dist = sqrt(dist)
			col.a = max(0, (MOUTH_GLITCH_RADIUS - dist) / MOUTH_GLITCH_RADIUS)
		
		$PlayerWave.get_child(i).position = d1xy
		$PlayerWave.get_child(i).modulate = col

# Draw player
func drawTargetWave() -> void:
	for i in range(WAVE_RESOLUTION):
		var d1x = mid.x/3 + (gap*i)
		var d1y = mid.y + root.getTargetFunction(d1x)
		var d1xy = Vector2(d1x,d1y) + self.position
		
		var col = target_line_color
		if (packageGlitch):
			var dist = INF
			for pck in root.packages.get_children():
				dist = min(dist, d1xy.distance_squared_to(pck.position))
			dist = sqrt(dist)
			col.a = max(0, (PACKAGE_GLITCH_RADIUS - dist) / PACKAGE_GLITCH_RADIUS)
		
		$TargetWave.get_child(i).position = d1xy
		$TargetWave.get_child(i).modulate = col

func getXBounds() -> Vector2:
	return Vector2(mid.x / 3, mid.x/3 + (gap*(WAVE_RESOLUTION+1)))

func getY() -> float:
	return mid.y;

func resetGlitches() -> void:
	packageGlitch = false
	mouthGlitch = false
