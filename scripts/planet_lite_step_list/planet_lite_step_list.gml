/// @description planet_lite_step_list(list, budget_us) - THE STAMPS' BUILDER (q216: out of syst_exped_panel): the first unfinished world of the list takes budget microseconds - rows of samples (planet_gen_step), then its textures (planet_bake with the deadline) - and stands within a few frames; the rest wait their turn
function planet_lite_step_list(_list, _budget) {
	var _lim = get_timer() + _budget;
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _pn = _list[_i];
		if (planet_lite_ready(_pn)) continue;
		planet_build_step(_pn, _lim);   // (the one builder's step, q225)
		return;
	}
}
