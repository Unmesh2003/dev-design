extends HBoxContainer

@export var max_count: int = 10  # Maximum number of items to display
var texture: Texture  # Dynamically assigned

func _ready() -> void:
	# If a TextureRect already exists as a child, use its texture
	var existing_texture_rect = get_node_or_null("TextureRect")
	if existing_texture_rect:
		texture = existing_texture_rect.texture

	if texture == null:
		print("Error: Texture is not assigned. Please assign it manually or ensure an initial TextureRect exists.")
		return

func update_items(count: int) -> void:
	# Clear all existing children
	var existing_texture_rect = get_node_or_null("TextureRect")
	if existing_texture_rect:
		texture = existing_texture_rect.texture
	for child in get_children():
		child.queue_free()

	if texture == null:
		print("Error: Cannot update items without a valid texture.")
		return

	# Add TextureRects based on the count
	for i in range(min(count, max_count)):  # Ensure count does not exceed max_count
		var item = TextureRect.new()
		item.texture = texture
		item.stretch_mode = TextureRect.STRETCH_SCALE  # Keep the aspect ratio of the image
		item.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		add_child(item)
