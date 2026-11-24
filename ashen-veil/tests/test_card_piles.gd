extends GutTest
## Grupo 4 · spec combat/card-piles.

const F = preload("res://tests/helpers/combat_factory.gd")


func _cards(count: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for i: int in range(count):
		result.append(CardInstance.new(F.card(StringName("c%d" % i), 1, [])))
	return result


func _piles(seed_value: int = 1) -> CardPiles:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return CardPiles.new(rng)


func _order_ids(piles: CardPiles) -> Array[StringName]:
	var ids: Array[StringName] = []
	for card: CardInstance in piles.draw_pile:
		ids.append(card.data.id)
	return ids


func test_same_seed_same_order() -> void:
	var cards: Array[CardInstance] = _cards(20)
	var a: CardPiles = _piles(42)
	var b: CardPiles = _piles(42)
	a.setup(cards)
	b.setup(cards)
	assert_eq(_order_ids(a), _order_ids(b))


func test_setup_puts_everything_in_draw_pile() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(20))
	assert_eq(piles.draw_pile.size(), 20)
	assert_eq(piles.hand.size() + piles.discard.size() + piles.exile.size() + piles.erased.size(), 0)


func test_draw_moves_top_card_to_hand() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(10))
	var top: CardInstance = piles.draw_pile.back()
	var drawn: CardInstance = piles.draw_one()
	assert_eq(drawn, top)
	assert_eq(piles.draw_pile.size(), 9)
	assert_eq(piles.hand.size(), 1)


func test_recycles_discard_when_draw_pile_is_empty() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(9))
	for i: int in range(8):
		piles.move(piles.draw_pile[0], CombatEnums.Pile.DISCARD)
	assert_eq(piles.draw_pile.size(), 1)
	for i: int in range(3):
		piles.draw_one()
	assert_eq(piles.hand.size(), 3)
	assert_eq(piles.discard.size(), 0)
	assert_eq(piles.draw_pile.size(), 6)


func test_nothing_to_draw_returns_null() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(0))
	assert_null(piles.draw_one())


func test_hand_limit_sends_card_to_discard() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(12))
	for i: int in range(10):
		piles.draw_one()
	var card: CardInstance = piles.draw_one()
	assert_eq(piles.hand.size(), CombatRules.MAX_HAND_SIZE)
	assert_true(piles.discard.has(card))


func test_exile_and_erased_are_not_recycled() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(6))
	piles.move(piles.draw_pile[0], CombatEnums.Pile.EXILE)
	piles.move(piles.draw_pile[0], CombatEnums.Pile.EXILE)
	piles.move(piles.draw_pile[0], CombatEnums.Pile.ERASED)
	piles.move(piles.draw_pile[0], CombatEnums.Pile.DISCARD)
	piles.recycle_discard()
	assert_eq(piles.exile.size(), 2)
	assert_eq(piles.erased.size(), 1)
	assert_eq(piles.draw_pile.size(), 3)


func test_card_count_is_conserved() -> void:
	var piles: CardPiles = _piles()
	piles.setup(_cards(20))
	for i: int in range(30):
		var card: CardInstance = piles.draw_one()
		if card != null and i % 3 == 0:
			piles.move(card, CombatEnums.Pile.DISCARD)
		assert_eq(piles.total_count(), 20)
	assert_eq(piles.pile_of(CardInstance.new(F.card(&"fuera", 1, []))), -1)
