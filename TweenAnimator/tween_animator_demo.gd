extends Node2D

@onready var example_sprite: Sprite2D = $ExampleSprite
@onready var example_text : RichTextLabel = $ExampleText
@onready var example_rect : TextureRect = $CanvasLayer/TextureRect
@onready var container := $CanvasLayer/Control/GridContainer
@onready var button_scene: PackedScene = preload("res://Generic/scenes/square_button.tscn")
@onready var tween_anim_text : RichTextLabel = $DemoNode/TweenAnimatorText
@onready var demo_text : RichTextLabel = $DemoNode/DemoText
@onready var demo_node : Node2D = $DemoNode

var punch_anim_duration : float = 0.1
var punch_anim : bool = false
var mouse_detected : bool = false
var is_dragging : bool = false
var drag_offset : Vector2 = Vector2.ZERO

func _ready() -> void:
	_animate_tween_animator_text()
	TweenAnimator.glow_pulse(example_rect)

	for anim_key in TweenAnimator.animation_names.keys():
		var anim_name = TweenAnimator.animation_names[anim_key]
		
		# Instantiate button
		var button : TextureButton = button_scene.instantiate()
		button.name = anim_name
		button.custom_minimum_size = Vector2(150.0, 100.0)
		
		# Reference the label correctly
		var label = button.get_node("RichTextLabel")
		if label:
			label.text = anim_name.capitalize().replace("_", " ")
		else:
			print("No label node found in button scene!")

		# Add to UI
		container.add_child(button)

		# Connect signal
		button.pressed.connect(func():
			var callable = Callable(TweenAnimator, anim_name)

			if callable.is_valid():
				if anim_name == "vanish":
					callable.call(example_sprite, 0.4, true)
				elif anim_name == "disappear":
					callable.call(example_sprite, 0.3, true)
				if anim_name == "black_hole":
					callable.call(example_sprite, 0.8, true)
				elif anim_name == "explode":
					callable.call(example_sprite, 1.8, 0.4, true)
				elif anim_name == "tv_shutdown":
					callable.call(example_sprite, 0.5, true)
				elif anim_name == "creep_out":
					callable.call(example_sprite, 1.0, true)
				elif anim_name == "typewriter":
					callable.call(example_text)
				elif anim_name == "letter_stretch":
					callable.call(example_text)
				else:
					callable.call(example_sprite)
			else:
				print("Animation not found: ", anim_name)
		) 

# Process method to handle dragging while the mouse is held down
func _process(delta: float) -> void:
	if is_dragging:
		# Calculate the new position of the rect while dragging
		var mouse_pos = get_global_mouse_position()
		example_rect.position = mouse_pos - drag_offset  # Update rect position based on mouse movement
	else :
		if mouse_detected:
			# Get the position of the mouse in global coordinates
			var mouse_pos = get_global_mouse_position()
			# Get the TextureRect's global bounding box
			var global_rect = example_rect.get_global_rect()
			
			if global_rect.has_point(mouse_pos):
				TweenAnimator.spotlight_on(example_rect, 0.5)
			else:
				TweenAnimator.spotlight_off(example_rect, 0.5)
			

# Handle mouse button input (e.g., left click for animations, right click for dragging)
func _on_texture_rect_gui_input(event: InputEvent) -> void:
	mouse_detected = (event is InputEventMouseMotion)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not punch_anim:
			# Trigger punch-out animation
			TweenAnimator.punch_out(example_rect, punch_anim_duration, 0.85)
			punch_anim = true
			# Wait for animation to finish before allowing another trigger
			await get_tree().create_timer(punch_anim_duration).timeout
			punch_anim = false

		# Handle right-click for dragging
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if not is_dragging:
					TweenAnimator.wiggle(example_rect)
					# Start dragging: record the offset between mouse position and rect position
					is_dragging = true
					drag_offset = get_global_mouse_position() - example_rect.position
					TweenAnimator.glow_pulse(example_rect)
			else:
				TweenAnimator.wiggle(example_rect)
				TweenAnimator.glow_pulse(example_rect)
				# Stop dragging when the right mouse button is released
				is_dragging = false

func _animate_tween_animator_text():
	TweenAnimator.drop_in(tween_anim_text)
	TweenAnimator.fade_in(demo_text)
	
func _reanimate_tween_animator_text():
	TweenAnimator.float_bob(demo_node, 10.0, 1.0)
	TweenAnimator.blink(tween_anim_text)
	TweenAnimator.typewriter(demo_text)
	
	await get_tree().create_timer(2.5).timeout
	TweenAnimator.float_bob(demo_node)
	
func _on_timer_timeout() -> void:
	_reanimate_tween_animator_text()
