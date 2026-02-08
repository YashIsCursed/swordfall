extends Node3D
class_name Item

@export_category("item data")
@export var props:Item_Data = Item_Data.new()

@onready var hitbox:Hitbox = $Hitbox if has_node("Hitbox") else null


func _ready() -> void:
	print("sskh")
	pass
