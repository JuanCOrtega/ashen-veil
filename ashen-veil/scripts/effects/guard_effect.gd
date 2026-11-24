class_name GuardEffect
extends CardEffect
## Quien origina el efecto gana Guardia (defensa contra daño físico).

@export var base: int = 6
@export var scaling_stat: CombatEnums.Stat = CombatEnums.Stat.STRENGTH


func compute(source: Combatant) -> int:
	return CombatRules.scale_value(base, source.get_stat(scaling_stat))


func apply(ctx: EffectContext) -> void:
	ctx.queue.push(GainGuardAction.new(ctx.source, compute(ctx.source)))


func describe() -> String:
	return "%d Guardia" % base
