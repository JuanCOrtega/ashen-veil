class_name VeloEffect
extends CardEffect
## Quien origina el efecto gana Velo (defensa contra daño etéreo).

@export var base: int = 5
@export var scaling_stat: CombatEnums.Stat = CombatEnums.Stat.VOICE


func compute(source: Combatant) -> int:
	return CombatRules.scale_value(base, source.get_stat(scaling_stat))


func apply(ctx: EffectContext) -> void:
	ctx.queue.push(GainVeloAction.new(ctx.source, compute(ctx.source)))


func describe() -> String:
	return "%d Velo" % base
