/// @description ram_used() - the bill: every automation that is ON,
/// priced through ram_cost at its current setting. Walks g.autom once;
/// cheap enough to read every step (tiles_tick does, for the merger's
/// throttle).
function ram_used() {
	autom_init();
	var _a = g.autom;
	var _u = 0;
	// the two things on by default: the dials' own cycling and the
	// fabricator, priced on their speed
	if (_a.run.on) _u += ram_cost("speed", _a.run.spd);
	if (_a.fab.on) _u += ram_cost("speed", _a.fab.spd);
	// the automerger: the TABLE's switch, this page's speed
	if (variable_global_exists("tiles") && g.tiles.automerge)
		_u += ram_cost("speed", _a.am_speed);
	// the dial autobuys, each on its own clock
	for (var _i = 0; _i < array_length(_a.dial); _i++)
		if (_a.dial[_i].on) _u += ram_cost("timer", _a.dial[_i].t);
	// the upgrade table
	var _g = _a.upg;
	if (_g.roll) _u += ram_cost("flag");
	if (_g.sell) _u += ram_cost("flag");
	if (_g.buy)  _u += ram_cost("timer", _g.t);
	// the tile upgrades
	var _tn = variable_struct_get_names(_a.tiles);
	for (var _i = 0; _i < array_length(_tn); _i++) {
		var _p = _a.tiles[$ _tn[_i]];
		if (_p.on) _u += ram_cost("timer", _p.t);
	}
	// the autorebirth: its master switch is what costs
	if (_a.reb.on) _u += ram_cost("rebirth");
	return _u;
}
