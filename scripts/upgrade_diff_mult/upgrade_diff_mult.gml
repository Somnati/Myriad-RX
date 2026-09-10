/// @description upgrade_diff_mult();
/// THE DIFFICULTY SEAT for upgrade pricing - and the first thing in
/// Myriad RX that g.difficulty actually does.
///
/// It was picked at new game (easy / standard / hard / critical), given
/// flavour text that promises something, stored on the save, and read
/// by NOTHING. Myriad DE's equivalent is real: hardmode raises upgrade
/// prices and cuts sell value, classicmode does the reverse, and the
/// same two flags reach dial cost growth, rarity rolls and the pace
/// features unlock at. This is the first of those seats; the rest can
/// follow the same shape as each system lands.
function upgrade_diff_mult() {
	if (!variable_global_exists("difficulty")) return 1;
	switch (clamp(floor(g.difficulty), 0, 4)) {
		case 0: return 0.75;   // easy
		case 1: return 1;      // standard
		case 2: return 1.35;   // hard
		case 3: return 1.8;    // critical
		case 4: return 1;      // custom: its own rules, later (his call)
	}
	return 1;
}
