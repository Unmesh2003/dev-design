extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	print("button pressed")
	get_tree().change_scene_to_file("res://scean/temple.tscn")


func _on_option_pressed() -> void:
	$AboutScreen.visible=true
	$TextureRect.visible=false


func _on_story_pressed() -> void:
	$story.visible=true
	$AboutScreen.visible=false


func _on_character_pressed() -> void:
	$characters.visible=true
	$AboutScreen.visible=false


func _on_vikram_pressed() -> void:
	$vikram.visible=true
	$characters.visible=true


func _on_back_pressed() -> void:
	$characters.visible=true
	$vikram.visible=false


func _on_tantrik_pressed() -> void:
	$tantrik.visible=true
	$characters.visible=false


func _on_betal_pressed() -> void:
	$betal.visible=true
	$characters.visible=false


func _on_hidimb_pressed() -> void:
	$hidimb.visible=true
	$characters.visible=false


func _on_home_pressed() -> void:
	$characters.visible=false
	$TextureRect.visible=true
