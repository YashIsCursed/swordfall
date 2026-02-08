# MultiplayerManager.gd - Singleton for managing multiplayer connections (ENet)
extends Node

signal server_started(port: int)
signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)
signal connection_failed
signal connection_succeeded
signal server_discovered(server_info: Dictionary)

const DEFAULT_PORT := 45456
const MAX_PLAYERS := 8
const BROADCAST_PORT := 45457

@export_category("Multiplayer Setup")
@export var default_ip: String = "localhost"

var is_server: bool = false
var is_client: bool = false
var current_port: int = 0
var server_name: String = "Swordfall Server"
var discovered_servers: Array[Dictionary] = []

var _broadcast_timer: Timer
var _discovery_socket: PacketPeerUDP

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func create_Server(port: int = DEFAULT_PORT, name: String = "Swordfall Server") -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYERS)
	
	if error != OK:
		push_error("Failed to create server on port " + str(port) + ": " + str(error))
		return error
	
	multiplayer.multiplayer_peer = peer
	is_server = true
	is_client = false
	current_port = port
	server_name = name
	
	# Start broadcasting for LAN discovery
	_start_broadcasting()
	
	server_started.emit(port)
	print("Server started on port: " + str(port))
	return OK

func create_Client(ip: String, port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	
	if error != OK:
		push_error("Failed to connect to " + ip + ":" + str(port) + ": " + str(error))
		return error
	
	multiplayer.multiplayer_peer = peer
	is_client = true
	is_server = false
	current_port = port
	
	print("Connecting to " + ip + ":" + str(port))
	return OK

func disconnect_from_server() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	is_server = false
	is_client = false
	current_port = 0
	
	_stop_broadcasting()
	_stop_discovery()

func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected: " + str(peer_id))
	client_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected: " + str(peer_id))
	client_disconnected.emit(peer_id)

func _on_connected_to_server() -> void:
	print("Connected to server!")
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	print("Connection failed!")
	is_client = false
	connection_failed.emit()

func get_connected_peers() -> PackedInt32Array:
	if multiplayer.multiplayer_peer:
		return multiplayer.get_peers()
	return PackedInt32Array()

func get_player_count() -> int:
	return get_connected_peers().size() + 1 # +1 for host

func is_multiplayer_active() -> bool:
	return is_server or is_client

# LAN Discovery
func _start_broadcasting() -> void:
	if not is_server:
		return
	
	_broadcast_timer = Timer.new()
	_broadcast_timer.wait_time = 1.0
	_broadcast_timer.timeout.connect(_broadcast_server_info)
	add_child(_broadcast_timer)
	_broadcast_timer.start()

func _stop_broadcasting() -> void:
	if _broadcast_timer:
		_broadcast_timer.stop()
		_broadcast_timer.queue_free()
		_broadcast_timer = null

func _broadcast_server_info() -> void:
	var socket = PacketPeerUDP.new()
	socket.set_broadcast_enabled(true)
	socket.set_dest_address("255.255.255.255", BROADCAST_PORT)
	
	var info = {
		"name": server_name,
		"port": current_port,
		"players": get_player_count(),
		"max_players": MAX_PLAYERS
	}
	
	socket.put_packet(JSON.stringify(info).to_utf8_buffer())
	socket.close()

func start_lan_discovery() -> void:
	discovered_servers.clear()
	
	_discovery_socket = PacketPeerUDP.new()
	_discovery_socket.bind(BROADCAST_PORT)
	
	# Check for broadcasts in process
	set_process(true)

func stop_lan_discovery() -> void:
	_stop_discovery()
	set_process(false)

func _stop_discovery() -> void:
	if _discovery_socket:
		_discovery_socket.close()
		_discovery_socket = null

func _process(_delta: float) -> void:
	if _discovery_socket and _discovery_socket.get_available_packet_count() > 0:
		var packet = _discovery_socket.get_packet()
		var ip = _discovery_socket.get_packet_ip()
		
		var json = JSON.new()
		if json.parse(packet.get_string_from_utf8()) == OK:
			var server_info = json.data
			server_info["ip"] = ip
			
			# Check if already discovered
			var found = false
			for server in discovered_servers:
				if server.get("ip") == ip and server.get("port") == server_info.get("port"):
					# Update existing
					server.merge(server_info)
					found = true
					break
			
			if not found:
				discovered_servers.append(server_info)
				server_discovered.emit(server_info)

func get_discovered_servers() -> Array[Dictionary]:
	return discovered_servers
