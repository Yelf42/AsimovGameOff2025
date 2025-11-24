extends Node2D

var t = 1.0
var speed: float = 0.1

var health: int = 1
@export var health_1_color: Color
@export var health_2_color: Color
@export var health_3_color: Color

var root

var collided := {}

var dead: String = ""

func create(healthSpeed: Vector2) -> void:
	health = int(healthSpeed.x)
	speed = 0.1 * healthSpeed.y
	showHealth()

func _ready() -> void:
	root = get_tree().current_scene
	$"1".modulate = health_1_color
	$"2".modulate = health_2_color
	$"3".modulate = health_3_color
	
	$Spawn.pitch_scale = randf_range(0.9, 1.3)
	$Spawn.volume_db = -25.0 + (health * 7.0)
	$Spawn.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (t <= 0.0 and dead != "failed"):
		$Zap.pitch_scale = randf_range(1.0, 1.6)
		$Zap.play()
		dead = "failed"
	t -= speed * delta
	
	if (dead == "popped" and !$Pop.playing):
		root.totalPackagesEaten += 1
		queue_free()
	
	if (dead == "failed" and !$Zap.playing):
		root.totalPackagesDropped += 1
		queue_free()
	
	var drawerBounds = root.drawer.getXBounds()
	var x = (1 - t) * drawerBounds.x + t * drawerBounds.y
	var y = root.drawer.getY() + root.getTargetFunction(x)
	
	position = Vector2(x,y) + root.drawer.position
	$"1".rotation += delta
	$"2".rotation += delta
	$"3".rotation += delta

func damage(id) -> void:
	if (collided.has(id)): return
	collided[id] = true
	health -= 1
	if (health <= 0):
		$Pop.play()
		dead = "popped"
	$Pop.pitch_scale = randf_range(0.7, 1.3)
	$Pop.play()
	showHealth()

func showHealth() -> void:
	$"2".visible = (health >= 2)
	$"2".rotation = $"1".rotation + (PI if (health < 3) else TAU / 3.0)
	$"3".visible = (health >= 3)
