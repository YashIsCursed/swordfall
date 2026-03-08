# Boss L1.gd - Boss with animation support
extends Mob

var anim_player: AnimationPlayer = null

func _ready() -> void:
	super._ready()
	
	# Find the AnimationPlayer anywhere in the scene tree (FBX models nest it deep)
	anim_player = _find_animation_player(self )
	
	if anim_player:
		# Print all available animation names so we know exactly what to use
		var anim_list = anim_player.get_animation_list()
	else:
		print("BossL1: WARNING - No AnimationPlayer found!")
	
	# Connect the play_animation signal to our handler
	play_animation.connect(_on_play_animation)
	
	# Start with idle
	_on_play_animation("idle")

func _find_animation_player(node: Node) -> AnimationPlayer:
	# Check direct children first
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
	# Then recurse deeper
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

func _on_play_animation(action: String) -> void:
	if not anim_player:
		return
	
	# Skip if dying
	if is_dead and action != "Death" and action != "death":
		return
	
	# Skip if mid-attack
	var current = anim_player.current_animation
	if (current == "Attack" or current == "attack") and (action == "Walk" or action == "walk") and anim_player.is_playing():
		return
	
	# Try both capitalized and lowercase versions of the animation name
	var anim_name = _find_anim_name(action)
	if anim_name != "":
		if action == "Attack" or action == "attack":
			anim_player.stop()
		anim_player.play(anim_name)

func _find_anim_name(action: String) -> String:
	# Try exact match first
	if anim_player.has_animation(action):
		return action
	# Try lowercase
	if anim_player.has_animation(action.to_lower()):
		return action.to_lower()
	# Try capitalized (first letter upper)
	var capitalized = action.capitalize()
	if anim_player.has_animation(capitalized):
		return capitalized
	# Try UPPERCASE
	if anim_player.has_animation(action.to_upper()):
		return action.to_upper()
	return ""
