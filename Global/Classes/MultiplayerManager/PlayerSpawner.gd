extends MultiplayerSpawner

@export var Network_player:PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_Player)
	
func spawn_Player(id:int)->void:
	if !multiplayer.is_server():return
	
	var new_player:Node = Network_player.instantiate()
	new_player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child",new_player)
