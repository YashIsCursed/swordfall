extends Resource
class_name Item_Data


enum StackSize {
	SINGLE=1,
	DOUBLE=2,
	STACK=8
}

@export_category("Data")
@export var ITId:int
@export var Name:String
@export var Description:String
@export var Weight:float=0.5
@export var Damage:int=1
#
