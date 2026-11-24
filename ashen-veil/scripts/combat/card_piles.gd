class_name CardPiles
extends RefCounted
## Pilas de cartas del héroe. Cada carta está siempre en exactamente una pila.
## La "cima" de la pila de robo es el final del array.

var draw_pile: Array[CardInstance] = []
var hand: Array[CardInstance] = []
var discard: Array[CardInstance] = []
var exile: Array[CardInstance] = []
var erased: Array[CardInstance] = []
var resolving: Array[CardInstance] = []

var _rng: RandomNumberGenerator


func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng


func setup(cards: Array[CardInstance]) -> void:
	for pile: Array[CardInstance] in _all_piles():
		pile.clear()
	draw_pile.assign(cards)
	shuffle(draw_pile)


## Fisher–Yates con el RNG del combate: misma semilla, mismo orden.
func shuffle(cards: Array[CardInstance]) -> void:
	for i: int in range(cards.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: CardInstance = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp


func get_pile(pile: CombatEnums.Pile) -> Array[CardInstance]:
	match pile:
		CombatEnums.Pile.DRAW:
			return draw_pile
		CombatEnums.Pile.HAND:
			return hand
		CombatEnums.Pile.DISCARD:
			return discard
		CombatEnums.Pile.EXILE:
			return exile
		CombatEnums.Pile.ERASED:
			return erased
		CombatEnums.Pile.RESOLVING:
			return resolving
	return []


## Devuelve la pila en la que está la carta, o -1 si no está en ninguna.
func pile_of(card: CardInstance) -> int:
	for pile: CombatEnums.Pile in CombatEnums.Pile.values():
		if get_pile(pile).has(card):
			return pile
	return -1


## Mueve una carta a otra pila. Devuelve la pila de origen (-1 si no estaba).
func move(card: CardInstance, to_pile: CombatEnums.Pile) -> int:
	var from: int = pile_of(card)
	if from != -1:
		get_pile(from as CombatEnums.Pile).erase(card)
	get_pile(to_pile).append(card)
	return from


## Baraja el descarte y lo convierte en la nueva pila de robo.
## El exilio y las borradas no se tocan. Devuelve cuántas cartas se reciclaron.
func recycle_discard() -> int:
	var count: int = discard.size()
	draw_pile.append_array(discard)
	discard.clear()
	shuffle(draw_pile)
	return count


## Roba la carta de la cima. Si la mano está llena, va al descarte.
## Si la pila de robo está vacía, recicla antes el descarte.
## Devuelve null si no hay nada que robar.
func draw_one() -> CardInstance:
	if draw_pile.is_empty():
		if discard.is_empty():
			return null
		recycle_discard()
	var card: CardInstance = draw_pile.pop_back()
	if hand.size() >= CombatRules.MAX_HAND_SIZE:
		discard.append(card)
	else:
		hand.append(card)
	return card


func total_count() -> int:
	var total: int = 0
	for pile: Array[CardInstance] in _all_piles():
		total += pile.size()
	return total


func _all_piles() -> Array[Array]:
	return [draw_pile, hand, discard, exile, erased, resolving]
