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

	// FABRICATION SPEED: a flat -0.1s a level (his spec), floored so the
	// fabricator can never reach zero and spin. Subtractive rather than
	// the old multiplicative factor because he asked for a fixed step -
	// which also means the LAST levels are the valuable ones, where a
	// multiplier's would have been the first.
	// ⚖️ TWO LIMITS, AND THEY DO DIFFERENT JOBS. The CAP is the most the
	// upgrade may remove (5.0s of the 10) and it is what keeps three
	// seconds open for the abilities that will come; MIN is where the
	// fabricator stops no matter what has been applied. Without the cap
	// a floor alone would let upgrades take every second there is, and
	// every future ability would arrive worth nothing.
	var _cut = min(TILE_FAB_CAP, TILE_FAB_STEP * (_t.upg[$ "fab"] ?? 0));
	_t.fab_t = max(TILE_FAB_MIN, TILE_FAB_T - _cut);
	_t.stored_max = TILE_BANK_BASE + TILE_BANK_STEP * (_t.upg[$ "bank"] ?? 0);

	// ⚖️ THE FLAT PART ONLY. The upgrade is a MULTIPLIER on this (DE's
	// chain - see tile_rarity_rate), and a multiplier cannot be folded
	// into the number it multiplies without losing the order: the
	// ability deck's flat bonus has to land BEFORE it, and that flag is
	// not known here. So this publishes the base and the one authority
	// applies everything conditional.
	g.tile_rarity = TILE_RARITY_BASE
		+ (variable_global_exists("tile_rarity_base") ? g.tile_rarity_base : 0);
}
