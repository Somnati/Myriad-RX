/// @description deck_draft_pick(key) - claim one card from the draft:
/// the chosen key unlocks with full fanfare (the other candidates
/// dissolve back into the pool for future drafts), Scholar applies,
/// and every count/cost/view refreshes.
function deck_draft_pick(_key) {
	abi = _key;
	unlock_deck();
	update_deck_titles();

	// Scholar: the pick arrives already enabled when the ap covers it
	if (g.ad_scholar == 1 && variable_global_get(_key) == 100) {
		var _ci = deck_card_info(_key);
		if (g.ap + 2 >= _ci.ap) variable_global_set(_key, 1);
	}

	g.abi_draft = [];
	fetch_new_ability(); // recount + the next discovery's cost

	if (instance_exists(syst_rm_ability))
		with (syst_rm_ability) { input_changed = 2; update_ap = true; }
	with (obj_ability_slot) input_changed = 2;
	save_mark_dirty();
}
