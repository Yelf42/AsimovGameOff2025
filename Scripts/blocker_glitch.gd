extends Node2D

const MAX_SCALE: float = 4.0
const GROWTH_SPEED: float = 0.1

const MIN_SCALE: float = 0.8

var growing = true

func _ready() -> void:
	var viewport = get_viewport().size
	self.position = Vector2(randf_range(viewport.x / 10, 9 * viewport.x / 10), randf_range(viewport.y / 10, 9 * viewport.y / 10))

func _process(delta: float) -> void:
	if (growing): 
		grow(delta)
		var rad = $Sprite2D.scale.x * $Sprite2D.get_rect().size.x / 2.0
		if (self.position.distance_to(get_global_mouse_position()) < rad):
			growing = false
	else:
		shrink(delta)
		if ($Sprite2D.scale.x <= MIN_SCALE):
			queue_free()

func getShaderData() -> Vector3:
	return Vector3(self.position.x, self.position.y, $Sprite2D.scale.x * $Sprite2D.get_rect().size.x / 2.0)

func grow(delta: float) -> void:
	var scle = $Sprite2D.scale.x
	if (scle < MAX_SCALE):
		scle = lerp(scle, MAX_SCALE * 1.2, GROWTH_SPEED * delta)
		$Sprite2D.scale = Vector2(scle,scle)

func shrink(delta: float) -> void:
	var scle = $Sprite2D.scale.x
	if (scle > MIN_SCALE):
		scle = lerp(scle, MIN_SCALE * 0.8, 15.0 * GROWTH_SPEED * delta)
		$Sprite2D.scale = Vector2(scle,scle)
