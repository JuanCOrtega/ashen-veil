class_name DrawAction
extends CombatAction
## Roba cartas para el héroe, reciclando el descarte si hace falta.

var count: int


func _init(p_count: int) -> void:
	count = p_count


func execute(state: CombatState) -> void:
	var piles: CardPiles = state.hero.piles
	var names: PackedStringArray = []
	for i: int in range(count):
		if piles.draw_pile.is_empty():
			if piles.discard.is_empty():
				break
			var recycled: int = piles.recycle_discard()
			EventBus.discard_recycled.emit(recycled)
			names.append("(descarte barajado: %d)" % recycled)
		var card: CardInstance = piles.draw_one()
		if card == null:
			break
		var overflowed: bool = piles.discard.has(card)
		names.append(card.data.display_name + (" → descarte (mano llena)" if overflowed else ""))
		EventBus.card_drawn.emit(card, overflowed)
	if names.is_empty():
		log_text = "No quedan cartas que robar."
	else:
		log_text = "Roba: %s." % ", ".join(names)
