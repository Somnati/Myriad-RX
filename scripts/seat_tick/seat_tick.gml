/// @description seat_tick(dt) - every vacant seat runs down by dt seconds; at zero THE SUCCESSOR takes it (q260)
/// The thread resets to stage 0 (the cards deal again), dread lifts (the
/// new one knows these crews' names), the region's cached villain is
/// dropped so region_villain generates the successor, and the news says
/// who. A world nobody can reach any more just closes its seat quietly
function seat_tick(_dt) {
	var _ss = g.exped[$ "seat"];
	if (!is_struct(_ss) || _dt <= 0) return;
	var _ks = variable_struct_get_names(_ss);
	for (var _i = 0; _i < array_length(_ks); _i++) {
		var _s = _ss[$ _ks[_i]];
		if (_s.left <= 0) continue;
		_s.left -= _dt;
		if (_s.left > 0) continue;
		_s.left = 0;
		var _kv = string_split(_ks[_i], ":");
		if (array_length(_kv) < 2) continue;
		if (array_length(_kv) >= 3) { variable_struct_remove(_ss, _ks[_i]); continue; }   // (a kind's seat: a new alpha rose, quietly - q262)
		var _d = lane_dest(real(_kv[0])), _ri = real(_kv[1]);
		if (!is_struct(g.exped[$ "vil"])) g.exped.vil = {};
		g.exped.vil[$ _ks[_i]] = 0;
		if (!is_struct(_d)) continue;
		var _rg = region_get(_d, _ri);
		_rg.villain_c = false;
		var _v = region_villain(_d, _rg);
		lane_push(_d, _ri, "dread", .45);
		if (is_struct(_v)) exped_news(_v.fac + " have a new " + (_v[$ "rank"] ?? "chief") + ": " + _v.name + ". " + choose("worse than the last, they say", "the last one's name is not said", "the roads of " + _rg.name + " are busy again"), _d, _ri);
		save_mark_dirty();
	}
}
