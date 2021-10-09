extends Node2D
export (Array, PackedScene) var toSpawn : Array
signal onFruitMerge(tier)
signal onGameOver()

const SPAWN_LEVEL := 100.0
const MAX_TIER := 4
const PADDING := 5
var debug : Label

var balls := []
var ballDisplay := [
	{"color": Color(0.43, 0.039, 0.75), 
	"size": Vector2(0.5,0.5)} 
]
var highestTier := 0
var nextTier := 0
var lerping := false
var gameOver := false
var timerRunning := false

class Ball:
	var obj : RigidBody2D
	var radius : float
	var tier : int
	
	func _init(pObj : RigidBody2D = null, pRadius := 10.0, pTier := 0) -> void:
		obj = pObj
		radius = pRadius
		tier = pTier

func _ready() -> void:
	randomize()
	updateIndicator(0)
	
	debug = Label.new()
	add_child(debug)
	debug.visible = false

func _process(delta: float) -> void:
	if lerping or gameOver: return
#	if Input.is_action_just_pressed("ui_accept"): killGame()

	if Input.is_action_just_pressed("click"):
		if !timerRunning: 
			var godotBall = toSpawn[nextTier].instance()
			add_child(godotBall)
			balls.push_back(Ball.new(godotBall, getRadius(godotBall), nextTier))
			godotBall.position = Vector2(
				get_viewport().get_mouse_position().x,
				SPAWN_LEVEL)
			godotBall.rotation = $Indicator.rotation
			nextTier = rand_range(0,highestTier + 1)
			updateIndicator(nextTier)
			startTimer()
	else:
		$Indicator.position = Vector2(
			get_viewport().get_mouse_position().x,
			SPAWN_LEVEL
		)
				
		for b in balls:
			if b.obj.linear_velocity.length_squared() < 0.001:
				if b.obj.position.y < SPAWN_LEVEL:
					killGame()
					break
			for b2 in balls:
				if b == b2 or b.tier != b2.tier: continue
				
				var r1 = b.radius
				var r2 = b2.radius
				var dist = r1 + r2
				if (b.obj.position - b2.obj.position).length_squared() < dist * dist:
					merge(b, b2)

func merge(ball1 : Ball, ball2 : Ball) -> void:
	var b1 := ball1
	var b2 := ball2
	if b1.obj.position.y > b2.obj.position.y:
		var b3 := b2
		b2 = b1
		b1 = b3
	
	var position = b1.obj.position * 0.1 + b2.obj.position * 0.9
	var rotation = b1.obj.rotation * 0.1 + b2.obj.rotation * 0.9
	var tier = b1.tier + 1
	var reset := false
	emit_signal("onFruitMerge", tier)
	
#	$FX.position = position
#	$FX.emitting = true
	
	if tier <= MAX_TIER and tier > highestTier:
		highestTier = tier
		ballDisplay.append({
			"color": Color.white,
			"size": Vector2.ZERO
		})
		reset = true
	
	$Tween.interpolate_property(b1.obj.get_node("Sprite"), "global_position",
				b1.obj.position, position, 0.15,
				Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(b1.obj.get_node("Sprite"), "roation",
			b1.obj.rotation, rotation, 0.15,
			Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.start()
	balls.remove(balls.find(b1))
	balls.remove(balls.find(b2))
	
	yield($Tween, "tween_completed")
	b1.obj.queue_free()
	b2.obj.queue_free()
	
	var newBall = toSpawn[clamp(tier, 0, toSpawn.size())].instance()
	add_child(newBall)
	newBall.position = position
	newBall.rotation = rotation
	balls.append(Ball.new(newBall, getRadius(newBall), tier))
	
	debug.text = str(highestTier)
	
	if reset:
		ballDisplay[tier]["color"] = newBall.get_node("Sprite").modulate
		ballDisplay[tier]["size"] = newBall.get_node("Sprite").scale

func getRadius(ball : RigidBody2D) -> float:
	return ball.get_node("CollisionShape2D").shape.radius + PADDING

func updateIndicator(index : int) -> void:
	$Indicator.modulate = ballDisplay[index]["color"]
	$Indicator.scale = ballDisplay[index]["size"]
	$Indicator.rotation_degrees = rand_range(0, 360)

func startTimer():
	if timerRunning: return
	
	timerRunning = true
	$Indicator.visible = false
	
	$Timer.wait_time = 0.5
	$Timer.start()
	yield($Timer, "timeout")
	timerRunning = false
	$Indicator.visible = true
	var scale = $Indicator.scale
	$Indicator.scale = Vector2.ZERO
	
	$Tween.interpolate_property($Indicator, "scale",
			Vector2.ZERO, scale, 0.2, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func killGame():
	gameOver = true
	for b in balls:
		$Tween.interpolate_property(b.obj, "scale", b.obj.scale, Vector2.ZERO, 0.1, 
				Tween.TRANS_BACK, Tween.EASE_IN)
		$Tween.interpolate_callback(b.obj, 0.12, "queue_free")
		$Timer.wait_time = rand_range(0.1,0.4)
		$Timer.start()
		emit_signal("onFruitMerge", 1)
		yield ($Timer, "timeout")
	balls.clear()
	emit_signal("onGameOver")
	gameOver = false
