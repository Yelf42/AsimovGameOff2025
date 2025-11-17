extends Node2D

const MAX_SCALE: float = 4
const GROWTH_SPEED: float = 0.1

func _ready() -> void:
	var viewport = get_viewport().size
	self.position = Vector2(randf_range(viewport.x / 10, 9 * viewport.x / 10), randf_range(viewport.y / 10, 9 * viewport.y / 10))

func _process(delta: float) -> void:
	var scle = $Sprite2D.scale.x
	if (scle < MAX_SCALE):
		scle = lerp(scle, MAX_SCALE * 1.2, GROWTH_SPEED * delta)
		$Sprite2D.scale = Vector2(scle,scle)
	var rad = scle * $Sprite2D.get_rect().size.x / 2.0
	if (self.position.distance_to(get_global_mouse_position()) < rad):
		queue_free()

func getShaderData() -> Vector3:
	return Vector3(self.position.x, self.position.y, $Sprite2D.scale.x * $Sprite2D.get_rect().size.x / 2.0)
