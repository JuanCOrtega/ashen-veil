class_name EnemyData
extends Resource
## Definición de un tipo de enemigo.

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 9999) var max_vitality: int = 20
## Se recorre en orden y vuelve al principio al llegar al final.
@export var intent_pattern: Array[IntentData] = []
