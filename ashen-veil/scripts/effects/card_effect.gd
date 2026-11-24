class_name CardEffect
extends Resource
## Pieza reutilizable de comportamiento. Las cartas y las intenciones enemigas
## son listas de efectos. Un efecto NO cambia el estado directamente: encola acciones.


func apply(_ctx: EffectContext) -> void:
	push_error("CardEffect.apply() no está implementado en %s" % get_script().resource_path)


## Texto corto para cartas e intenciones (por ejemplo, "6 daño físico").
func describe() -> String:
	return ""


static func stat_label(stat: CombatEnums.Stat) -> String:
	match stat:
		CombatEnums.Stat.STRENGTH:
			return "FUE"
		CombatEnums.Stat.FULGOR:
			return "FUL"
		CombatEnums.Stat.UMBRAL:
			return "UMB"
		CombatEnums.Stat.VOICE:
			return "VOZ"
		CombatEnums.Stat.WILL:
			return "VOL"
	return ""
