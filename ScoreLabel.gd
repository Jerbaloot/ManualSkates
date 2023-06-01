extends Label

func _ready():
	ScoreKeeper.score_changed.connect(update_label)
	update_label()

func update_label():
	text = "Score: " + str(ScoreKeeper.score)
