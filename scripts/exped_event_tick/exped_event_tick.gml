/// @description exped_event_tick() - every region of every world on the board: with nothing on, a lull more often than not, else an event the region can host (region_event)
/// Called by exped_tick after the memories tick (the "event" memory
/// runs down like the rest - online, offline, x the debug speed). A
/// lull is a day to three; an event two to four days.
function exped_event_tick() {
	var _e = g.exped;
	for (var _b = 0; _b < array_length(_e.board); _b++) {
		var _d = _e.board[_b];
		var _nrg = region_count(_d);   // (the territories' count; 0 until the world stands - q287)
		for (var _ri = 0; _ri < _nrg; _ri++) {
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
				// THE RAID (q285): a villain whose faction stands at FAC_RAID_STR or better falls on a settled place - twice on the
				// list, so a strong faction raids more often than it fairs; hunting its people is how you stop it
				if (is_struct(_v) && _vst < 3 && array_length(_civ) > 0 && faction_get(_d, _ri, _v.foe, _rg).str >= FAC_RAID_STR) { array_push(_opts, "raid"); array_push(_opts, "raid"); }
			}
			if (_open) array_push(_opts, "frost");
			if (array_length(_opts) == 0) { exped_mem_set(_d, _ri, -1, "event", random_range(24, 72), "lull:-1"); continue; }
			var _kind = _opts[irandom(array_length(_opts) - 1)];
			var _node = (_kind == "fair" || _kind == "rats" || _kind == "raid") ? _civ[irandom(array_length(_civ) - 1)] : -1;
			exped_mem_set(_d, _ri, -1, "event", random_range(48, 96), _kind + ":" + string(_node));
			if (_kind == "rats") pop_push(_d, _ri, _node, -.08); else if (_kind == "fair") pop_push(_d, _ri, _node, .05);   // (the people go, or come - q284)
			if (_kind == "raid") { pop_push(_d, _ri, _node, -RAID_POP); lane_push(_d, _ri, "dread", .3); lane_push(_d, _ri, "order", -.2); lane_push(_d, _ri, "welcome", -.1); }   // (the raid's toll - q285; the shelf thins by q284's reader)
		}
	}
}
