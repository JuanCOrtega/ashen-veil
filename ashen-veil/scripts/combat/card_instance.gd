class_name CardInstance
extends RefCounted
## Una copia concreta de una carta dentro de un combate. Permite que dos copias
## del mismo CardData sean distintas en el futuro (mejoras, corrupción, borrado).

static var _next_uid: int = 1

var uid: int
var data: CardData


func _init(card_data: CardData) -> void:
	data = card_data
	uid = _next_uid
	_next_uid += 1


func _to_string() -> String:
	return "%s#%d" % [data.display_name if data != null else "?", uid]
