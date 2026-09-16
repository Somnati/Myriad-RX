/// @description bestiary_payout(trip, fight) - THE BESTIARY PAYS (his pick, 2026-09-16), at a fight's end, to the crew that is up
/// THE HUNT, a kind at a time (g.exped.best[kind].paid = the last rung
/// paid, saved with the ledger):
///   10 slain    the measure: everyone up writes a foe note on it (a facet
///               off its shape - sprite_note_gen; one note a kind, so the
///               ones with a note keep theirs)
///   50 slain    the TITLE "bane of the <plural>" (sprite_title, rank 1)
///   250 slain   "scourge of the <plural>" (rank 2) and an elixir of luck each
/// THE LAND'S SET (g.exped.blands, the lands complete): the moment every
/// kind that haunts a land is in the book, the crew that closed it takes
/// the title "warden of the <land>" and a road note on that land (the
/// pace, sprite_note_has "road:<land>"). The roads and the towns are no
/// set - the road's four haunt everywhere. Diary lines for all of it.
function bestiary_payout(_tr, _f) {
	static _thr = [10, 50, 250];
	static _noset = ["road", "village", "town", "city", "settlement", "landing"];
	var _e = g.exped;
	if (!is_struct(_e[$ "best"])) return;
	if (!is_array(_e[$ "blands"])) _e.blands = [];
	// the kinds that fell here, once each, with a pawn of theirs for the note
	var _kinds = [], _pawns = [];
	for (var _j = 0; _j < array_length(_f.foes); _j++) {
		var _fo = _f.foes[_j], _kd = _fo[$ "kind"] ?? "";
		if (_kd == "" || _fo.hp > 0 || array_contains(_kinds, _kd)) continue;
		array_push(_kinds, _kd); array_push(_pawns, _fo);
	}
	if (array_length(_kinds) == 0) return;
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) { if (_tr.hp[_k] <= 0) continue; var _sp = exped_sprite(_tr.sids[_k]); if (!is_undefined(_sp)) array_push(_up, _sp); }
	if (array_length(_up) == 0) return;
	var _crew = [];
	for (var _i = 0; _i < array_length(_up); _i++) array_push(_crew, _up[_i].name);
	var _ros = foe_roster();
	for (var _ki = 0; _ki < array_length(_kinds); _ki++) {
		var _kd = _kinds[_ki], _pw = _pawns[_ki];
		var _b = _e.best[$ _kd];
		if (!is_struct(_b)) continue;
		var _paid = _b[$ "paid"] ?? 0, _pl = foe_plural(_kd);
		for (var _t = 0; _t < array_length(_thr); _t++) {
			var _th = _thr[_t];
			if (_b.slain < _th || _paid >= _th) continue;
			_paid = _th;
			switch (_th) {
				case 10: {
					array_push(_tr.log, "the tenth " + _kd + ". " + choose("the crew has the measure of " + _pl + " now", _pl + " hold no surprises for this crew", "there is a way to fight " + _pl + ", and they have it"));
					for (var _i = 0; _i < array_length(_up); _i++) {
						var _ctx = { foe : _pw, facet : "hit" };
						var _txt = sprite_note_gen(_up[_i], "foe", _ctx);
						if (_txt != "" && sprite_note(_up[_i], _txt, "foe:" + _kd + ":" + _ctx.facet)) array_push(_tr.log, _up[_i].name + " writes: \"" + _txt + "\"");
					}
					break;
				}
				case 50: {
					for (var _i = 0; _i < array_length(_up); _i++) sprite_title(_up[_i], "bane of the " + _pl, 1);
					array_push(_tr.log, "fifty " + _pl + " down. " + exped_crew_txt(_crew) + " - the bane of the " + _pl + ", from here on" + choose("", ". nobody voted on it", ". the " + _pl + " were not asked", ". it will do"));
					break;
				}
				default: {
					for (var _i = 0; _i < array_length(_up); _i++) { sprite_title(_up[_i], "scourge of the " + _pl, 2); array_push(_tr.log, sprite_elixir(_up[_i], "luck")); }
					array_push(_tr.log, "two hundred and fifty " + _pl + ". " + exped_crew_txt(_crew) + " - the scourge of the " + _pl + ". " + choose("a bottle each turned up for it, from nobody in particular", "something in the water tastes of luck", "the bottles were on the step in the morning"));
					break;
				}
			}
		}
		_b.paid = _paid;
		// THE LAND'S SET: every land this kind haunts - is the whole of it met now?
		var _re = undefined;
		for (var _ri = 0; _ri < array_length(_ros); _ri++) if (_ros[_ri].name == _kd) _re = _ros[_ri];
		if (!is_struct(_re)) continue;
		for (var _li = 0; _li < array_length(_re.lands); _li++) {
			var _ld = _re.lands[_li];
			if (array_contains(_noset, _ld) || array_contains(_e.blands, _ld)) continue;
			var _ks = foe_kinds_at(_ld), _all = true;
			for (var _q = 0; _q < array_length(_ks) && _all; _q++) { var _bq = _e.best[$ _ks[_q]]; if (!is_struct(_bq) || _bq.seen <= 0) _all = false; }
			if (!_all) continue;
			array_push(_e.blands, _ld);
			for (var _i = 0; _i < array_length(_up); _i++) {
				sprite_title(_up[_i], "warden of the " + _ld, 1);
				sprite_note(_up[_i], "the " + _ld + ": everything in it is in the book. walk it like a garden", "road:" + _ld);
			}
			array_push(_tr.log, "every kind that haunts the " + _ld + " is in the book now. " + exped_crew_txt(_crew) + " - " + ((array_length(_crew) > 1) ? "wardens" : "warden") + " of the " + _ld + ". they walk it like a garden from here");
		}
	}
	save_mark_dirty();
}
