class_name DrawEffect
extends CardEffect
## El héroe roba cartas. Sin efecto si lo origina un enemigo.

@export_range(1, 10) var count: int = 1


func apply(ctx: EffectContext) -> void:
	if ctx.source is HeroCombatant:
		ctx.queue.push(DrawAction.new(count))


func describe() -> String:
	return "Roba %d" % count
