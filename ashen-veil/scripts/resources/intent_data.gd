class_name IntentData
extends Resource
## Una intención enemiga: qué hará el enemigo en su turno. Reutiliza los mismos
## efectos que las cartas (el daño se calcula igual para todos).

enum Icon { ATTACK_PHYSICAL, ATTACK_ETHEREAL, DEFEND, MIXED, UNKNOWN }

@export var icon: Icon = Icon.ATTACK_PHYSICAL
## Texto visible opcional; si está vacío se genera a partir de los efectos.
@export var label: String = ""
@export var effects: Array[CardEffect] = []


func describe() -> String:
	if not label.is_empty():
		return label
	var parts: PackedStringArray = []
	for effect: CardEffect in effects:
		var text: String = effect.describe()
		if not text.is_empty():
			parts.append(text)
	return " + ".join(parts)
