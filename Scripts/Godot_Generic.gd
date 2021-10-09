extends RigidBody2D
class_name Godot_Generic

export (int) var tier := 0
var debug : Label

func getRadius() -> float:
	return ($CollisionShape2D.shape as CircleShape2D).radius

func onBodyEntered(body: Node) -> void:
	$Sprite.modulate = Color.blue
	if body is Godot_Generic:
		if body.tier == tier:
			$Sprite.modulate = Color.red
			body.get_node("Sprite").modulate = Color.blue
