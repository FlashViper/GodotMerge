extends CanvasLayer

export (Gradient) var textColor : Gradient

onready var scoreText : Label = $ScoreLabel
onready var highScoreText : Label = $HighScoreLabel
onready var tween = $Tween
onready var timer = $Timer

const POINTS_PER_TIER := 10
const TIER_MULTIPLIER := 2
const POINT_COLLECT_TIME := 0.5

var score := 0
var highScore := 0
var pointQueue := 0

var oScale : Vector2

func _ready() -> void:
	oScale = scoreText.rect_scale
	timer.connect("timeout", self, "onTimeUp")
	highScoreText.text = "High: " + str(highScore)

func _process(delta: float) -> void:
	scoreText.text = str(score + pointQueue)

func onTimeUp():
	score += pointQueue
	if score > highScore:
		var prevScore = highScore
		highScore = score
		highScoreText.text = "High: " + str(highScore)
		interpolateText(highScoreText, highScore, highScore - prevScore)
	pointQueue = 0

func _on_Main_onFruitMerge(tier) -> void:
	var points = tier * POINTS_PER_TIER * pow(TIER_MULTIPLIER, tier - 1)
	pointQueue += points
	interpolateText(scoreText, score, pointQueue)
	timer.start(POINT_COLLECT_TIME)

func interpolateText(text : Label, pScore : int, queue := 0) -> void:
	text.rect_scale = Vector2.ONE * (
		1 + ceil(lerp(0, 1, inverse_lerp(0, 10000, queue))))
	tween.interpolate_property(text, "modulate",
		text.modulate, textColor.interpolate(inverse_lerp(0, 4999, pScore)),
		0.35)
	tween.interpolate_property(text, "rect_scale",
			text.rect_scale, oScale, 0.25, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.start()

func _on_Main_onGameOver() -> void:
	score = 0
