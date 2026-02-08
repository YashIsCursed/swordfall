extends Resource
class_name Inventory

signal update_item(action:ItemAction,item:Item,index:int)

enum ItemAction{
	ADD,
	UPDATE,
	REMOVE
}
@export_category("Inventory")
@export var Items:Array[Item_Data]
@export var MaxSize:int=8

func _init(max_Size:int) -> void:
	print("------Inventory------")
	MaxSize = max_Size
	update_item.connect(handle_Indexed_Item_Action)
	update_item.connect(handle_Item_Action)
	

func handle_Indexed_Item_Action(action:ItemAction,item:Item_Data, index:int)->void:
	match action:

		ItemAction.ADD:
			#print("Adding"+item.props.Name)
			Items.set(index,item)

		ItemAction.UPDATE:
			if (Items.has(item)):
				Items[index]=item
			else:
				print("Not Available----")

		ItemAction.REMOVE:
			if(item==Items[index]):
				Items.remove_at(index)
				#print("Removed")
			else:
				print("I am *ucked")

func handle_Item_Action(action:ItemAction,item:Item_Data)->void:
	match action:
		ItemAction.ADD:
			print("Adding "+item.Name)
			Items.append(item)

func _ready() -> void:
	print("initialized inv")
	if(Items.is_empty()):
#		TODO IMPLEMENT THE {WORLD AND FILESYSTEM}
		pass
