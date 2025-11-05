extends Node2D

var t = 1.0
var speed = 0.1

var health = 1
@export var health_1_color: Color
@export var health_2_color: Color
@export var health_3_color: Color

var root

var collided := {}

func create(_health: int = 1, _speed: float = 0.1) -> void:
	health = _health
	speed = _speed

func _ready() -> void:
	root = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (t <= 0.0):
		root.totalPackagesDropped += 1
		queue_free()
	if (health <= 0):
		root.totalPackagesEaten += 1
		queue_free()
	t -= speed * delta
	
	match(health):
		1:
			$CollisionShape2D.debug_color = health_1_color
		2:
			$CollisionShape2D.debug_color = health_2_color
		3:
			$CollisionShape2D.debug_color = health_3_color
	
	var drawerBounds = root.drawer.getXBounds()
	var x = (1 - t) * drawerBounds.x + t * drawerBounds.y
	var y = root.drawer.getY() + root.getTargetFunction(x)
	
	position = Vector2(x,y) + root.drawer.position

func damage(id) -> void:
	if (collided.has(id)): return
	collided[id] = true
	health -= 1
