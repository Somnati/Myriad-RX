/// @description tiles_sync();
/// PUSH THE UPGRADE LEVELS INTO THE BOARD. Slot count, fabricator
/// period, hopper size and fabricator luck are all DERIVED from
/// g.tiles.upg here and nowhere else, so a rebalance reaches a save
/// that already exists and no purchase has to remember to apply itself.
///
/// The fields it writes are MIRRORS. The ported tile code reads
/// g.tiles.slots / fab_t / stored_max directly and there is no reason
/// to rewrite all of it - so this runs at the top of every tick and
/// after every purchase, and those fields are never the truth, only
/// the current answer.
///
/// GROWING THE BOARD GROWS THE ARRAY, which is the one thing here that
/// is not a plain assignment: the tier array IS the game state, so it
/// gets extended with empty slots rather than rebuilt.
function tiles_sync() {
	if (!variable_global_exists("tiles")) return;
	var _t = g.tiles;
	if (!is_struct(_t[$ "upg"])) return;

	var _slots = TILE_SLOTS_BASE + TILE_SLOT_STEP * (_t.upg[$ "slots"] ?? 0);
	if (_slots != _t.slots) {
		var _old = array_length(_t.tier);
		_t.slots = _slots;
		if (_slots > _old)
			for (var _i = _old; _i < _slots; _i++) _t.tier[_i] = 0;
		else
			// shrinking should never happen (levels only rise), but a
			// hand-edited save must not leave tiles outside the board
			array_resize(_t.tier, _slots);
		_t.dirty = true;
	}

	_t.fab_t      = TILE_FAB_T * power(TILE_SPEED_FACTOR, _t.upg[$ "speed"] ?? 0);
	_t.stored_max = TILE_BANK_BASE + TILE_BANK_STEP * (_t.upg[$ "bank"] ?? 0);

	// the fabricator's luck: a base knob (nothing sets it yet) plus what
	// the upgrade bought. tile_roll_tier and tile_tier_odds both read
	// g.tile_rarity, so writing it here keeps the roll and the bar in
	// step with one assignment.
	g.tile_rarity = (variable_global_exists("tile_luck_base") ? g.tile_luck_base : 0)
		+ TILE_LUCK_STEP * (_t.upg[$ "luck"] ?? 0);
}
