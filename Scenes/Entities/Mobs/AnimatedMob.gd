# AnimatedMob.gd
extends Mob

@onready var anim_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

func _ready() -> void:
	super._ready()
	
	# Connect the new signal to our animation handler
	play_animation.connect(_on_play_animation)
	
	# Ensure the idle animation starts immediately
	_on_play_animation("idle")

func _on_play_animation(action: String) -> void:
	if not anim_player:
		return
		
	# Skip if we are mid-attack (prevent sliding walks interrupting attack)
	if anim_player.current_animation == "attack" and action == "walk" and anim_player.is_playing():
		return
		
	# Skip if we are dying or dead (we don't want walk animations playing during death)
	if anim_player.current_animation == "death" and action != "death":
		return
		
	# Play standard actions
	match action:
		"idle":
			if anim_player.has_animation("idle"):
				anim_player.play("idle")
		"walk":
			if anim_player.has_animation("walk"):
				anim_player.play("walk")
		"attack":
			if anim_player.has_animation("attack"):
				# Reset and play attack from beginning
				anim_player.stop()
				anim_player.play("attack")
		"death":
			if anim_player.has_animation("death"):
				anim_player.play("death")
