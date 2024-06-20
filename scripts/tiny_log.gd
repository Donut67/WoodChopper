extends pickable_object

func highlight(toggle):
	$Sprite2D.modulate = Color(0.85, 0.85, 0.85) if toggle else Color(1, 1, 1)
