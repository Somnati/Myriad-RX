/// @description exped_event_tick() - every region of every world on the board: with nothing on, a lull more often than not, else an event the region can host (region_event)
/// Called by exped_tick after the memories tick (the "event" memory
/// runs down like the rest - online, offline, x the debug speed). A
/// lull is a day to three; an event two to four days.
function exped_event_tick() {
	var _e = g.exped;
	for (var _b = 0; _b < array_length(_e.board); _b++) {
		var _d = _e.board[_b];
		for (var _ri = 0; _ri < EXPED_REGIONS; _ri++) {
			if (is_struct(exped_mem_get(_d, _ri, -1, "event"))) continue;
			if (roll_perc(55)) { exped_mem_set(_d, _ri, -1, "event", random_range(24, 72), "lull:-1"); continue; }
			var _rg = region_get(_d, _ri), _kk = region_kinds(), _civ = [], _open = false, _camps = false;
			for (var _i = 1; _i < array_length(_rg.nodes); _i++) {
				var _k = _rg.nodes[_i].kind, _kd = _kk[$ _k];
				if (is_struct(_kd) && _kd.civ) array_push(_civ, _i);
				if (_k == "field" || _k == "forest" || _k == "hills" || _k == "marsh") _open = true;
				if (_k == "camp") _camps = true;
			}
			var _opts = [];
			if (array_length(_civ) > 0) { array_push(_opts, "fair"); array_push(_opts, "rats"); }
			// REGION LANES (q259): trade up makes the fair likelier, trade down the rats
			var _ltr = lane_val(_d, _ri, "trade");
			if (array_length(_civ) > 0 && _ltr > .3) array_push(_opts, "fair");
			if (array_length(_civ) > 0 && _ltr < -.3) array_push(_opts, "rats");
			if (_camps) {
				var _v = region_villain(_d, _rg);
				var _vm = _e[$ "vil"], _vst = 0;
				if (is_struct(_vm)) _vst = _vm[$ string(_d.seed) + ":" + string(_ri)] ?? 0;
				if (is_struct(_v) && _vst < 3 && faction_get(_d, _ri, _v.foe, _rg).str >= .5) array_push(_opts, "lord");   // (a faction under half strength cannot ride out - q283)
			}
			if (_open) array_push(_opts, "frost");
			if (array_length(_opts) == 0) { exped_mem_set(_d, _ri, -1, "event", random_range(24, 72), "lull:-1"); continue; }
			var _kind = _opts[irandom(array_length(_opts) - 1)];
			var _node = (_kind == "fair" || _kind == "rats") ? _civ[irandom(array_length(_civ) - 1)] : -1;
			exped_mem_set(_d, _ri, -1, "event", random_range(48, 96), _kind + ":" + string(_node));
		}
	}
}
