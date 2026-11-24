class_name DamageEffect
extends CardEffect
## Hace daño físico o etéreo a los objetivos del contexto.

@export var base: int = 6
@export var damage_type: CombatEnums.DamageType = CombatEnums.DamageType.PHYSICAL
@export var scaling_stat: CombatEnums.Stat = CombatEnums.Stat.STRENGTH


func compute(source: Combatant) -> int:
	return CombatRules.scale_value(base, source.get_stat(scaling_stat))


func apply(ctx: EffectContext) -> void:
	var amount: int = compute(ctx.source)
	for target: Combatant in ctx.targets:
		ctx.queue.push(DamageAction.new(ctx.source, target, amount, damage_type))


func describe() -> String:
	var type_name: String = "físico" if damage_type == CombatEnums.DamageType.PHYSICAL else "etéreo"
	var stat: String = CardEffect.stat_label(scaling_stat)
	return "%d daño %s%s" % [base, type_name, (" (+½ %s)" % stat) if not stat.is_empty() else ""]
