extends Control
## Escena de pruebas de combate (spec dev/combat-sandbox). Sin arte: solo Control.
## La interfaz se construye por código para que sea fácil de cambiar mientras
## el combate evoluciona. Escucha el EventBus y registra un presentador en el combate.

const PHASE_NAMES: Dictionary = {
	CombatManager.Phase.SETUP: "Preparación",
	CombatManager.Phase.ROUND_START: "Inicio de ronda",
	CombatManager.Phase.PLAYER_TURN: "Tu turno",
	CombatManager.Phase.ENEMY_TURN: "Turno enemigo",
	CombatManager.Phase.ROUND_END: "Fin de ronda",
	CombatManager.Phase.VICTORY: "Victoria",
	CombatManager.Phase.DEFEAT: "Derrota",
}

## Pausa tras cada acción para poder seguirla en pantalla (0 en las pruebas).
var present_delay: float = 0.25

var _manager: CombatManager = null
var _pending_card: CardInstance = null
var _deck: Array[CardData] = []
var _enemy_picks: Array[EnemyData] = []
var _last_config: HeroCombatConfig = null
var _last_enemies: Array[EnemyData] = []
var _last_seed: int = 0

# Configuración
var _setup_panel: VBoxContainer
var _vitality_spin: SpinBox
var _stat_spins: Dictionary = {}
var _balanza_spin: SpinBox
var _seed_spin: SpinBox
var _available_list: ItemList
var _deck_list: ItemList
var _deck_title: Label
var _enemy_option: OptionButton
var _enemy_list: ItemList
var _setup_error: Label

# Combate
var _combat_panel: VBoxContainer
var _end_row: HBoxContainer
var _end_label: Label
var _hero_label: Label
var _piles_label: Label
var _enemies_box: HBoxContainer
var _status_label: Label
var _hand_box: HFlowContainer
var _cancel_button: Button
var _end_turn_button: Button
var _debug_card_option: OptionButton
var _debug_balanza_spin: SpinBox
var _debug_target_option: OptionButton
var _debug_vitality_spin: SpinBox
var _debug_buttons: Array[Button] = []
var _restart_button: Button
var _log: RichTextLabel


func _ready() -> void:
	_build_ui()
	EventBus.combat_ended.connect(_on_combat_ended)
	_load_defaults()
	_show_setup()


# =============================================================================
# Configuración
# =============================================================================

func _load_defaults() -> void:
	var hero: HeroCombatConfig = Database.get_default_hero()
	if hero != null:
		_vitality_spin.value = hero.max_vitality
		for stat: CombatEnums.Stat in _stat_spins:
			(_stat_spins[stat] as SpinBox).value = hero.get_stat(stat)
		_balanza_spin.value = hero.starting_balanza
		_deck.assign(hero.deck)
	_enemy_picks.clear()
	for enemy: EnemyData in Database.all_enemies().slice(0, 2):
		_enemy_picks.append(enemy)
	_seed_spin.value = randi() % 1000000
	_refresh_setup_lists()


func _refresh_setup_lists() -> void:
	_available_list.clear()
	for card: CardData in Database.all_cards():
		_available_list.add_item(_card_line(card))
	_deck_list.clear()
	for card: CardData in _deck:
		_deck_list.add_item(_card_line(card))
	_deck_title.text = "Mazo (%d cartas)" % _deck.size()
	_enemy_option.clear()
	for enemy: EnemyData in Database.all_enemies():
		_enemy_option.add_item("%s (Vit %d)" % [enemy.display_name, enemy.max_vitality])
	_enemy_list.clear()
	for enemy: EnemyData in _enemy_picks:
		_enemy_list.add_item(enemy.display_name)


func _build_config() -> HeroCombatConfig:
	var config := HeroCombatConfig.new()
	var defaults: HeroCombatConfig = Database.get_default_hero()
	if defaults != null:
		config.hero_name = defaults.hero_name
	config.max_vitality = int(_vitality_spin.value)
	config.strength = int((_stat_spins[CombatEnums.Stat.STRENGTH] as SpinBox).value)
	config.fulgor = int((_stat_spins[CombatEnums.Stat.FULGOR] as SpinBox).value)
	config.umbral = int((_stat_spins[CombatEnums.Stat.UMBRAL] as SpinBox).value)
	config.voice = int((_stat_spins[CombatEnums.Stat.VOICE] as SpinBox).value)
	config.will = int((_stat_spins[CombatEnums.Stat.WILL] as SpinBox).value)
	config.starting_balanza = int(_balanza_spin.value)
	var deck: Array[CardData] = []
	deck.assign(_deck)
	config.deck = deck
	return config


func _on_fight_pressed() -> void:
	if _deck.is_empty():
		_setup_error.text = "El mazo necesita al menos una carta."
		return
	if _enemy_picks.is_empty() or _enemy_picks.size() > CombatRules.MAX_ENEMIES:
		_setup_error.text = "Elige entre %d y %d enemigos." % [CombatRules.MIN_ENEMIES, CombatRules.MAX_ENEMIES]
		return
	_setup_error.text = ""
	_last_config = _build_config()
	_last_enemies.assign(_enemy_picks)
	_last_seed = int(_seed_spin.value)
	await _start_combat()


func _on_add_card_to_deck(index: int = -1) -> void:
	var selected: PackedInt32Array = _available_list.get_selected_items()
	var pick: int = index if index >= 0 else (selected[0] if not selected.is_empty() else -1)
	if pick < 0:
		return
	_deck.append(Database.all_cards()[pick])
	_refresh_setup_lists()


func _on_remove_card_from_deck() -> void:
	var selected: PackedInt32Array = _deck_list.get_selected_items()
	if selected.is_empty():
		return
	_deck.remove_at(selected[0])
	_refresh_setup_lists()


func _on_add_enemy() -> void:
	if _enemy_picks.size() >= CombatRules.MAX_ENEMIES or _enemy_option.selected < 0:
		return
	_enemy_picks.append(Database.all_enemies()[_enemy_option.selected])
	_refresh_setup_lists()


func _on_remove_enemy() -> void:
	var selected: PackedInt32Array = _enemy_list.get_selected_items()
	if selected.is_empty():
		return
	_enemy_picks.remove_at(selected[0])
	_refresh_setup_lists()


# =============================================================================
# Combate
# =============================================================================

func _start_combat() -> void:
	if _manager != null:
		_manager.queue_free()
	_manager = CombatManager.new()
	_manager.name = "CombatManager"
	add_child(_manager)
	_manager.presenter = _present
	_manager.phase_changed.connect(_on_phase_changed)
	_pending_card = null
	_log.clear()
	_log.append_text("[b]Combate nuevo[/b] · semilla %d\n" % _last_seed)
	_show_combat()
	await _manager.start_combat(_last_config, _last_enemies, _last_seed)
	_rebuild_debug_targets()
	_refresh()


func _present(action: CombatAction) -> void:
	if not action.log_text.is_empty():
		_log.append_text(action.log_text + "\n")
	_refresh()
	await get_tree().create_timer(present_delay).timeout


func _on_card_pressed(card: CardInstance) -> void:
	if _manager == null or not _manager.can_play(card):
		return
	if _manager.needs_target(card):
		_pending_card = card
		_refresh()
		return
	_pending_card = null
	await _manager.play_card(card)
	_refresh()


func _on_enemy_pressed(enemy: EnemyCombatant) -> void:
	if _pending_card == null or enemy.is_defeated():
		return
	var card: CardInstance = _pending_card
	_pending_card = null
	await _manager.play_card(card, enemy)
	_refresh()


func _on_cancel_pressed() -> void:
	_pending_card = null
	_refresh()


func _on_end_turn_pressed() -> void:
	if _manager == null or _manager.is_input_locked():
		return
	_pending_card = null
	await _manager.end_turn()
	_refresh()


func _on_phase_changed(_phase: CombatManager.Phase) -> void:
	_refresh()


func _on_combat_ended(victory: bool) -> void:
	_pending_card = null
	_end_label.text = "VICTORIA" if victory else "DERROTA"
	_end_row.visible = true
	_log.append_text("[b]%s[/b]\n" % _end_label.text)
	_refresh()


func _on_repeat_pressed() -> void:
	await _start_combat()


# --- Depuración --------------------------------------------------------------

func _rebuild_debug_targets() -> void:
	_debug_target_option.clear()
	if _manager == null or _manager.state == null:
		return
	for combatant: Combatant in _manager.state.all_combatants():
		_debug_target_option.add_item(combatant.display_name)


func _on_debug_add_card() -> void:
	if _manager == null or _manager.is_input_locked() or _debug_card_option.selected < 0:
		return
	_manager.debug_add_card(Database.all_cards()[_debug_card_option.selected])
	_log.append_text("[i](depuración) carta añadida a la mano[/i]\n")
	_refresh()


func _on_debug_set_balanza() -> void:
	if _manager == null or _manager.is_input_locked():
		return
	_manager.debug_set_balanza(int(_debug_balanza_spin.value))
	_log.append_text("[i](depuración) Balanza fijada en %+d[/i]\n" % _manager.state.hero.balanza)
	_refresh()


func _on_debug_set_vitality() -> void:
	if _manager == null or _manager.is_input_locked() or _debug_target_option.selected < 0:
		return
	var target: Combatant = _manager.state.all_combatants()[_debug_target_option.selected]
	_log.append_text("[i](depuración) Vitalidad de %s fijada en %d[/i]\n" % [target.display_name, int(_debug_vitality_spin.value)])
	_manager.debug_set_vitality(target, int(_debug_vitality_spin.value))
	_refresh()


# =============================================================================
# Pintado
# =============================================================================

func _show_setup() -> void:
	_setup_panel.visible = true
	_combat_panel.visible = false


func _show_combat() -> void:
	_setup_panel.visible = false
	_combat_panel.visible = true
	_end_row.visible = false


func _refresh() -> void:
	if _manager == null or _manager.state == null:
		return
	var state: CombatState = _manager.state
	var hero: HeroCombatant = state.hero
	var locked: bool = _manager.is_input_locked()

	_hero_label.text = "%s — Vitalidad %d/%d · Guardia %d · Velo %d · Fervor %d/%d · Balanza %+d · Ronda %d · %s" % [
		hero.display_name, hero.vitality, hero.max_vitality, hero.guard, hero.velo,
		hero.fervor, hero.max_fervor, hero.balanza, state.round_number, PHASE_NAMES[_manager.phase],
	]
	var piles: CardPiles = hero.piles
	_piles_label.text = "Robo %d · Mano %d · Descarte %d · Exilio %d · Borradas %d" % [
		piles.draw_pile.size(), piles.hand.size(), piles.discard.size(), piles.exile.size(), piles.erased.size(),
	]

	for child: Node in _enemies_box.get_children():
		child.queue_free()
	for enemy: EnemyCombatant in state.enemies:
		var button := Button.new()
		button.custom_minimum_size = Vector2(220, 90)
		var intent_text: String = enemy.current_intent.describe() if enemy.current_intent != null else "—"
		if enemy.is_defeated():
			button.text = "%s\n(derrotado)" % enemy.display_name
		else:
			button.text = "%s\nVitalidad %d/%d · G %d · V %d\nIntención: %s" % [
				enemy.display_name, enemy.vitality, enemy.max_vitality, enemy.guard, enemy.velo, intent_text,
			]
		button.disabled = enemy.is_defeated() or _pending_card == null or locked
		button.pressed.connect(_on_enemy_pressed.bind(enemy))
		_enemies_box.add_child(button)

	for child: Node in _hand_box.get_children():
		child.queue_free()
	for card: CardInstance in piles.hand:
		var button := Button.new()
		button.custom_minimum_size = Vector2(170, 90)
		var rules: String = card.data.rules_text if not card.data.rules_text.is_empty() else card.data.describe_effects()
		button.text = "%s\n[%d] %s\n%s" % [card.data.display_name, card.data.cost, card.data.describe_balanza(), rules]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not _manager.can_play(card)
		if card == _pending_card:
			button.modulate = Color(1.0, 0.85, 0.4)
		button.pressed.connect(_on_card_pressed.bind(card))
		_hand_box.add_child(button)

	if _manager.is_over():
		_status_label.text = "Combate terminado."
	elif _pending_card != null:
		_status_label.text = "Elige un enemigo como objetivo de %s (o cancela)." % _pending_card.data.display_name
	elif locked:
		_status_label.text = "Resolviendo…"
	else:
		_status_label.text = "Juega cartas o termina el turno."

	_cancel_button.visible = _pending_card != null
	_end_turn_button.disabled = locked
	for button: Button in _debug_buttons:
		button.disabled = locked
	_restart_button.disabled = locked and not _manager.is_over()


func _card_line(card: CardData) -> String:
	return "%s [%d] %s" % [card.display_name, card.cost, card.describe_balanza()]


# =============================================================================
# Construcción de la interfaz
# =============================================================================

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var root := VBoxContainer.new()
	margin.add_child(root)
	var title := Label.new()
	title.text = "ASHEN VEIL · Escena de pruebas de combate"
	root.add_child(title)

	_build_setup_panel(root)
	_build_combat_panel(root)


func _build_setup_panel(root: VBoxContainer) -> void:
	_setup_panel = VBoxContainer.new()
	_setup_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_setup_panel)

	var stats_row := HBoxContainer.new()
	_setup_panel.add_child(stats_row)
	_vitality_spin = _add_spin(stats_row, "Vitalidad", 1, 999, 60)
	var stat_labels: Dictionary = {
		CombatEnums.Stat.STRENGTH: "FUE", CombatEnums.Stat.FULGOR: "FUL", CombatEnums.Stat.UMBRAL: "UMB",
		CombatEnums.Stat.VOICE: "VOZ", CombatEnums.Stat.WILL: "VOL",
	}
	for stat: CombatEnums.Stat in stat_labels:
		_stat_spins[stat] = _add_spin(stats_row, stat_labels[stat], 0, 99, 0)
	_balanza_spin = _add_spin(stats_row, "Balanza inicial", CombatRules.BALANZA_MIN, CombatRules.BALANZA_MAX, 0)
	_seed_spin = _add_spin(stats_row, "Semilla", 0, 999999999, 0)
	var random_seed := Button.new()
	random_seed.text = "Semilla aleatoria"
	random_seed.pressed.connect(func() -> void: _seed_spin.value = randi() % 1000000)
	stats_row.add_child(random_seed)

	var lists_row := HBoxContainer.new()
	lists_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_setup_panel.add_child(lists_row)

	var available_col: VBoxContainer = _add_column(lists_row, "Cartas disponibles (doble clic para añadir)")
	_available_list = _add_item_list(available_col)
	_available_list.item_activated.connect(_on_add_card_to_deck)
	_add_button(available_col, "Añadir al mazo →", _on_add_card_to_deck.bind(-1))

	var deck_col: VBoxContainer = _add_column(lists_row, "Mazo")
	_deck_title = deck_col.get_child(0) as Label
	_deck_list = _add_item_list(deck_col)
	_add_button(deck_col, "Quitar carta", _on_remove_card_from_deck)
	_add_button(deck_col, "Mazo y héroe por defecto", _load_defaults)

	var enemy_col: VBoxContainer = _add_column(lists_row, "Enemigos (1 a 6)")
	_enemy_option = OptionButton.new()
	enemy_col.add_child(_enemy_option)
	_add_button(enemy_col, "Añadir enemigo", _on_add_enemy)
	_enemy_list = _add_item_list(enemy_col)
	_add_button(enemy_col, "Quitar enemigo", _on_remove_enemy)

	var fight := Button.new()
	fight.text = "COMBATIR"
	fight.custom_minimum_size = Vector2(0, 44)
	fight.pressed.connect(_on_fight_pressed)
	_setup_panel.add_child(fight)
	_setup_error = Label.new()
	_setup_error.modulate = Color(1.0, 0.5, 0.5)
	_setup_panel.add_child(_setup_error)


func _build_combat_panel(root: VBoxContainer) -> void:
	_combat_panel = VBoxContainer.new()
	_combat_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_combat_panel)

	_end_row = HBoxContainer.new()
	_combat_panel.add_child(_end_row)
	_end_label = Label.new()
	_end_row.add_child(_end_label)
	_add_button(_end_row, "Repetir (misma semilla)", _on_repeat_pressed)
	_add_button(_end_row, "Configurar", _show_setup)

	_hero_label = Label.new()
	_combat_panel.add_child(_hero_label)
	_piles_label = Label.new()
	_combat_panel.add_child(_piles_label)

	_enemies_box = HBoxContainer.new()
	_combat_panel.add_child(_enemies_box)

	_status_label = Label.new()
	_combat_panel.add_child(_status_label)

	_hand_box = HFlowContainer.new()
	_combat_panel.add_child(_hand_box)

	var turn_row := HBoxContainer.new()
	_combat_panel.add_child(turn_row)
	_cancel_button = _add_button(turn_row, "Cancelar objetivo", _on_cancel_pressed)
	_end_turn_button = _add_button(turn_row, "Terminar turno", _on_end_turn_pressed)

	var debug_row := HBoxContainer.new()
	_combat_panel.add_child(debug_row)
	var debug_label := Label.new()
	debug_label.text = "Depuración:"
	debug_row.add_child(debug_label)
	_debug_card_option = OptionButton.new()
	for card: CardData in Database.all_cards():
		_debug_card_option.add_item(card.display_name)
	debug_row.add_child(_debug_card_option)
	_debug_buttons.append(_add_button(debug_row, "Añadir a la mano", _on_debug_add_card))
	_debug_balanza_spin = _add_spin(debug_row, "", CombatRules.BALANZA_MIN, CombatRules.BALANZA_MAX, 0)
	_debug_buttons.append(_add_button(debug_row, "Fijar Balanza", _on_debug_set_balanza))
	_debug_target_option = OptionButton.new()
	debug_row.add_child(_debug_target_option)
	_debug_vitality_spin = _add_spin(debug_row, "", 0, 999, 1)
	_debug_buttons.append(_add_button(debug_row, "Fijar Vitalidad", _on_debug_set_vitality))
	_restart_button = _add_button(debug_row, "Reiniciar", _on_repeat_pressed)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.custom_minimum_size = Vector2(0, 160)
	_combat_panel.add_child(_log)


func _add_spin(parent: Container, label: String, min_value: float, max_value: float, value: float) -> SpinBox:
	var box := VBoxContainer.new()
	if not label.is_empty():
		var text := Label.new()
		text.text = label
		box.add_child(text)
	var spin := SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.rounded = true
	spin.allow_lesser = false
	spin.value = value
	box.add_child(spin)
	parent.add_child(box)
	return spin


func _add_column(parent: Container, title: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = title
	column.add_child(label)
	parent.add_child(column)
	return column


func _add_item_list(parent: Container) -> ItemList:
	var list := ItemList.new()
	list.custom_minimum_size = Vector2(240, 220)
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(list)
	return list


func _add_button(parent: Container, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)
	return button
