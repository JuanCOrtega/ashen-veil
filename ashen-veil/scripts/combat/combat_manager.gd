class_name CombatManager
extends Node
## Máquina de estados del combate. Crea las acciones y las resuelve con la cola.
## No dibuja nada: la presentación escucha el EventBus y puede registrar un presentador.

enum Phase { SETUP, ROUND_START, PLAYER_TURN, ENEMY_TURN, ROUND_END, VICTORY, DEFEAT }

signal phase_changed(phase: Phase)

## Callable(action: CombatAction) -> void. Si se asigna antes de start_combat,
## la cola espera a que termine cada presentación.
var presenter: Callable = Callable()

var phase: Phase = Phase.SETUP
var state: CombatState
var queue: ActionQueue


func start_combat(config: HeroCombatConfig, enemy_data: Array[EnemyData], rng_seed: int) -> void:
	if enemy_data.size() < CombatRules.MIN_ENEMIES or enemy_data.size() > CombatRules.MAX_ENEMIES:
		push_error("Un combate necesita entre %d y %d enemigos (recibidos: %d)." % [
			CombatRules.MIN_ENEMIES, CombatRules.MAX_ENEMIES, enemy_data.size()])
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	state = CombatState.new()
	state.rng = rng
	state.hero = HeroCombatant.new(config, rng)
	for i: int in range(enemy_data.size()):
		state.enemies.append(EnemyCombatant.new(enemy_data[i], i))
	var cards: Array[CardInstance] = []
	for card_data: CardData in config.deck:
		cards.append(CardInstance.new(card_data))
	state.hero.piles.setup(cards)

	queue = ActionQueue.new(state)
	queue.presenter = presenter
	queue.end_check = _check_end

	_set_phase(Phase.SETUP)
	EventBus.combat_started.emit(state)
	await _start_round()


func is_over() -> bool:
	return phase == Phase.VICTORY or phase == Phase.DEFEAT


## True cuando el jugador no puede actuar (no es su turno o hay acciones resolviéndose).
func is_input_locked() -> bool:
	return phase != Phase.PLAYER_TURN or queue == null or queue.is_resolving


func can_play(card: CardInstance) -> bool:
	if is_input_locked():
		return false
	if not state.hero.piles.hand.has(card):
		return false
	return state.hero.fervor >= card.data.cost


func needs_target(card: CardInstance) -> bool:
	return card.data.target_type == CombatEnums.TargetType.ONE_ENEMY


## Juega una carta. Para cartas de "un enemigo", target es obligatorio.
## Devuelve false (sin cambiar nada) si no se puede jugar.
func play_card(card: CardInstance, target: EnemyCombatant = null) -> bool:
	if not can_play(card):
		return false
	var targets: Array[Combatant] = []
	match card.data.target_type:
		CombatEnums.TargetType.ONE_ENEMY:
			if target == null or target.is_defeated() or not state.enemies.has(target):
				return false
			targets.append(target)
		CombatEnums.TargetType.ALL_ENEMIES:
			for enemy: EnemyCombatant in state.living_enemies():
				targets.append(enemy)
		CombatEnums.TargetType.HERO:
			targets.append(state.hero)

	queue.push(FervorAction.spend_action(card.data.cost))
	queue.push(PlayCardAction.new(card, targets))
	var ctx := EffectContext.new(state.hero, targets, state, queue)
	for effect: CardEffect in card.data.effects:
		effect.apply(ctx)
	if card.data.balanza != 0:
		queue.push(ShiftBalanzaAction.new(card.data.balanza))
	var destination: CombatEnums.Pile = CombatEnums.Pile.EXILE if card.data.is_ephemeral() else CombatEnums.Pile.DISCARD
	queue.push(MoveCardAction.new(card, destination))
	await queue.process()
	return true


func end_turn() -> void:
	if is_input_locked():
		return
	EventBus.player_turn_ended.emit(state.round_number)
	_set_phase(Phase.ENEMY_TURN)
	var hand_copy: Array[CardInstance] = state.hero.piles.hand.duplicate()
	for card: CardInstance in hand_copy:
		queue.push(MoveCardAction.new(card, CombatEnums.Pile.DISCARD))
	await queue.process()
	if is_over():
		return
	await _run_enemy_turn()


# --- Depuración (escena de pruebas) -------------------------------------------

func debug_add_card(card_data: CardData) -> CardInstance:
	var card := CardInstance.new(card_data)
	var piles: CardPiles = state.hero.piles
	var overflowed: bool = piles.hand.size() >= CombatRules.MAX_HAND_SIZE
	piles.get_pile(CombatEnums.Pile.DISCARD if overflowed else CombatEnums.Pile.HAND).append(card)
	EventBus.card_drawn.emit(card, overflowed)
	return card


func debug_set_balanza(value: int) -> void:
	var old_value: int = state.hero.balanza
	state.hero.balanza = CombatRules.clamp_balanza(value)
	EventBus.balanza_changed.emit(old_value, state.hero.balanza)


func debug_set_vitality(combatant: Combatant, value: int) -> void:
	combatant.set_vitality(value)
	if combatant.is_defeated():
		EventBus.combatant_defeated.emit(combatant)
	_check_end()


# --- Flujo interno -----------------------------------------------------------

func _start_round() -> void:
	state.round_number += 1
	_set_phase(Phase.ROUND_START)
	EventBus.round_started.emit(state.round_number)
	queue.push(RoundAction.new(RoundAction.Kind.CLEAR_GUARD))
	queue.push(FervorAction.refill_action())
	var to_draw: int = maxi(0, state.hero.hand_size - state.hero.piles.hand.size())
	if to_draw > 0:
		queue.push(DrawAction.new(to_draw))
	for enemy: EnemyCombatant in state.living_enemies():
		queue.push(SetIntentAction.new(enemy))
	await queue.process()
	if is_over():
		return
	_set_phase(Phase.PLAYER_TURN)
	EventBus.player_turn_started.emit(state.round_number)


func _run_enemy_turn() -> void:
	_set_phase(Phase.ENEMY_TURN)
	var hero_target: Array[Combatant] = [state.hero]
	for enemy: EnemyCombatant in state.enemies:
		if enemy.is_defeated() or enemy.current_intent == null:
			continue
		var ctx := EffectContext.new(enemy, hero_target, state, queue)
		for effect: CardEffect in enemy.current_intent.effects:
			effect.apply(ctx)
		await queue.process()
		if is_over():
			return
	await _end_round()


func _end_round() -> void:
	_set_phase(Phase.ROUND_END)
	queue.push(RoundAction.new(RoundAction.Kind.DECAY_VELO))
	await queue.process()
	if is_over():
		return
	EventBus.round_ended.emit(state.round_number)
	await _start_round()


func _check_end() -> bool:
	if is_over():
		return true
	if state.hero.is_defeated():
		_finish(false)
		return true
	if state.all_enemies_defeated():
		_finish(true)
		return true
	return false


func _finish(victory: bool) -> void:
	_set_phase(Phase.VICTORY if victory else Phase.DEFEAT)
	EventBus.combat_ended.emit(victory)


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	phase_changed.emit(phase)
