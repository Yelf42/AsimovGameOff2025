extends Node2D

func _process(delta: float) -> void:
	$Sprite2D.rotation += 2.0 * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (!area.is_in_group("Package")): return
	area.damage(self.get_instance_id())
