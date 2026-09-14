/// @description fetch_new_ability([do_unlock]) - rebuild the
/// discovery pool and counts; when do_unlock, also draw one.
/// what changed from Myriad: the pool is an ARRAY (the original
/// wrote eligible names to ability_pool.txt and read the file back),
/// and the dead minor/tier pacing (computed then clobbered by
/// `type = 2`) is gone - discovery is a clean seeded pick. the seed
/// (abi_seed + unlocked count) keeps the discovery ORDER
/// deterministic per save, which was the original's best trick.
function fetch_new_ability(_do_unlock = false) {

	update_deck_titles(); // sections only exist once populated
	deck_failsafes();     // no orphan-enabled children (heals old saves too)

	g.abi_pool = [];
	_new_abilities_unlocked = 0;
	_unlockable_abilities   = 0;
	send_deck();
	g.new_abilities_unlocked = _new_abilities_unlocked;
	g.unlockable_abilities   = _unlockable_abilities;
	get_ability_cost();

	if (!_do_unlock) exit;
	if (array_length(g.abi_pool) == 0) exit;

	// the seeded draw (the stream is released after - rng_release)
	var _seed = random_get_seed();
	random_set_seed((g.abi_seed + g.new_abilities_unlocked) & $7fffffff);
	abi = g.abi_pool[irandom(array_length(g.abi_pool) - 1)];
	rng_release(_seed);

	var _drawn = abi; // unlock_deck consumes abi; Scholar needs the key
	unlock_deck();
	update_deck_titles(); // the new ability may have opened its section

	// (Scholar was cut from the roster, 2026-09-14: a discovery arrives off)

	// refresh everything for the new state
	g.abi_pool = [];
	_new_abilities_unlocked = 0;
	_unlockable_abilities   = 0;
	send_deck();
	g.new_abilities_unlocked = _new_abilities_unlocked;
	g.unlockable_abilities   = _unlockable_abilities;
	get_ability_cost();

	if (instance_exists(syst_rm_ability))
		with (syst_rm_ability) { input_changed = 2; update_ap = true; }
	with (obj_ability_slot) input_changed = 2;
	save_mark_dirty();
}
