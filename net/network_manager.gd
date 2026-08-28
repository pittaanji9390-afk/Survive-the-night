class_name NetworkManager
extends Node

signal server_hosted(port: int)
signal client_connected_to_server(ip: String, port: int)
signal peer_joined_session(peer_id: int)
signal peer_left_session(peer_id: int)
signal connection_error(reason: String)

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8

var peer: ENetMultiplayerPeer = null
var connected_peers: Array[int] = []
var is_server: bool = false
var is_network_active: bool = false

func _ready() -> void:
	ServiceLocator.register_service(&"NetworkManager", self)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"NetworkManager")
	close_network_session()

func host_game(port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		connection_error.emit("Failed to create server on port %d" % port)
		return err
	
	multiplayer.multiplayer_peer = peer
	is_server = true
	is_network_active = true
	connected_peers.clear()
	connected_peers.append(1) # Host ID
	server_hosted.emit(port)
	EventBus.notification_posted.emit("MULTIPLAYER HOSTED", "Server listening on port %d" % port, "wifi")
	return OK

func join_game(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(address, port)
	if err != OK:
		connection_error.emit("Failed to connect to %s:%d" % [address, port])
		return err
	
	multiplayer.multiplayer_peer = peer
	is_server = false
	is_network_active = true
	client_connected_to_server.emit(address, port)
	EventBus.notification_posted.emit("CONNECTING...", "Joining %s:%d" % [address, port], "wifi")
	return OK

func close_network_session() -> void:
	if peer:
		peer.close()
		peer = null
	multiplayer.multiplayer_peer = null
	is_network_active = false
	is_server = false
	connected_peers.clear()

func _on_peer_connected(peer_id: int) -> void:
	if not connected_peers.has(peer_id):
		connected_peers.append(peer_id)
	peer_joined_session.emit(peer_id)
	EventBus.notification_posted.emit("Player Joined", "Peer #%d joined the game" % peer_id, "user")

func _on_peer_disconnected(peer_id: int) -> void:
	connected_peers.erase(peer_id)
	peer_left_session.emit(peer_id)
	EventBus.notification_posted.emit("Player Left", "Peer #%d disconnected" % peer_id, "user")

func _on_connected_to_server() -> void:
	EventBus.notification_posted.emit("CONNECTED!", "Successfully synced with server.", "check")

func _on_connection_failed() -> void:
	close_network_session()
	connection_error.emit("Could not reach host server.")

func _on_server_disconnected() -> void:
	close_network_session()
	connection_error.emit("Host server disconnected.")
