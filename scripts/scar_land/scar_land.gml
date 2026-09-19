/// @description scar_land(dest, ri, lane) -> true when a scar landed: a lane held at its extreme long enough leaves a PERMANENT mark on the region (q260)
///   order  high  a camp becomes a SETTLEMENT (people move in while the roads are quiet; the faction loses a hold)
///   trade  high  a settlement grows to a village, a village to a town
///   faith  low   a wild node beside a crypt becomes a crypt (the dead spread)
/// Three a region at most; SCAR_CAP regions in the galaxy - past it the
/// oldest region's scars heal (history is bounded because the save is).
/// Applied to the cached region at once and kept in g.exped.scars
/// (saved ex_scars); the news says what changed
function scar_land(_d, _ri, _lane) {
	exped_init();
	if (!is_struct(g.exped[$ "scars"])) g.exped.scars = {};
	if (!is_array(g.exped[$ "scar_order"])) g.exped.scar_order = [];
	var _k = lane_key(_d, _ri), _sc = g.exped.scars[$ _k] ?? [];
	if (array_length(_sc) >= 3) return false;
	var _rg = region_get(_d, _ri), _kk = region_kinds();
	var _pick = -1, _to = "", _line = "";
	if (_lane == "order") {
		var _c = [];
		for (var _i = 1; _i < array_length(_rg.nodes); _i++) if (_rg.nodes[_i].kind == "camp") array_push(_c, _i);
		if (array_length(_c) == 0) return false;
		_pick = _c[hash_mix(_rg.seed, 7001 + array_length(_sc)) mod array_length(_c)]; _to = "settlement";
		_line = "the camp at " + _rg.nodes[_pick].name + " is a settlement now - " + choose("people moved in while the roads were quiet", "farmers took the fields the bandits left", "the tents are houses");
	} else if (_lane == "trade") {
		var _c = [];
		for (var _i = 1; _i < array_length(_rg.nodes); _i++) if (_rg.nodes[_i].kind == "settlement" || _rg.nodes[_i].kind == "village") array_push(_c, _i);
		if (array_length(_c) == 0) return false;
		_pick = _c[hash_mix(_rg.seed, 7101 + array_length(_sc)) mod array_length(_c)]; _to = (_rg.nodes[_pick].kind == "settlement") ? "village" : "town";
		_line = _rg.nodes[_pick].name + " has grown into a " + _to + " - " + choose("the carts kept coming", "a market on the green now", "there is an inn with two floors");
	} else if (_lane == "faith") {
		var _c = [];
		for (var _i = 1; _i < array_length(_rg.nodes); _i++) {
			if (_rg.nodes[_i].kind != "crypt") continue;
			var _nb = region_neighbors(_rg, _i);
			for (var _j = 0; _j < array_length(_nb); _j++) { var _nk = _kk[$ _rg.nodes[_nb[_j].j].kind]; if (is_struct(_nk) && _nk.wild && _rg.nodes[_nb[_j].j].kind != "crypt") array_push(_c, _nb[_j].j); }
		}
		if (array_length(_c) == 0) return false;
		_pick = _c[hash_mix(_rg.seed, 7201 + array_length(_sc)) mod array_length(_c)]; _to = "crypt";
		_line = "the dead have spread to " + _rg.nodes[_pick].name + " - " + choose("nobody goes there after dark now", "the ground gave up its stones", "the shrine's candles went out");
	} else return false;
	array_push(_sc, { n : _pick, k : _to, was : _rg.nodes[_pick].kind });
	g.exped.scars[$ _k] = _sc;
	if (!array_contains(g.exped.scar_order, _k)) array_push(g.exped.scar_order, _k);
	while (array_length(g.exped.scar_order) > SCAR_CAP) {
		var _old = g.exped.scar_order[0]; array_delete(g.exped.scar_order, 0, 1);
		if (variable_struct_exists(g.exped.scars, _old)) variable_struct_remove(g.exped.scars, _old);
	}
	scar_apply(_d, _ri, _rg);
	exped_news(_line, _d, _ri);
	exped_stat("scars");
	save_mark_dirty();
	return true;
}
