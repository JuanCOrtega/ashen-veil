class_name BalanzaEffect
extends CardEffect
## Mueve la Balanza del héroe una cantidad fija, o la acerca al centro (Equilibrio).
## Distinto del valor de Balanza de la carta, que se aplica al final de la resolución.

@export var amount: int = 2
## true = Equilibrio: acerca la Balanza a 0 `amount` puntos sin cruzar el centro.
@export var toward_center: bool = true


func apply(ctx: EffectContext) -> void:
	ctx.queue.push(ShiftBalanzaAction.new(amount, toward_center))


func describe() -> String:
	if toward_center:
		return "Equilibrio %d" % amount
	return "Balanza %+d" % amount
