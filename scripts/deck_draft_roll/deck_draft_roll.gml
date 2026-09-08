/// @description deck_draft_roll() - roll the discovery DRAFT: up to
/// three DISTINCT candidates drawn seeded from the eligible pool,
/// landing in g.abi_draft for the player to pick from. this finishes
/// what Myriad started: fetch_new_ability already rolled next_ability
/// 2 and 3 and never surfaced them. the seed (abi_seed + unlocked
/// count) keeps the trio deterministic per save - closing and
/// reopening the draft shows the same three.
function deck_draft_roll() {
	// fresh pool + counts
	g.abi_pool = [];
	_new_abilities_unlocked = 0;
	_unlockable_abilities   = 0;
	send_deck();
	g.new_abilities_unlocked = _new_abilities_unlocked;
	g.unlockable_abilities   = _unlockable_abilities;

	g.abi_draft = [];
	if (array_length(g.abi_pool) == 0) exit;

	var _seed = random_get_seed();
	random_set_seed((g.abi_seed + g.new_abilities_unlocked) & $7fffffff);
	var _tmp = [];
	array_copy(_tmp, 0, g.abi_pool, 0, array_length(g.abi_pool));
	repeat (min(3, array_length(_tmp))) {
		var _i = irandom(array_length(_tmp) - 1);
		array_push(g.abi_draft, _tmp[_i]);
		array_delete(_tmp, _i, 1);
	}
	random_set_seed(_seed);
}
