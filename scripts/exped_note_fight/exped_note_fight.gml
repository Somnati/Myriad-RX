/// @description exped_note_fight(trip, fight) - the notepad after a fight
/// Won: each foe kind of the pack, half the time, is written up by a
/// random survivor (tagged, so it counts against that kind from now on
/// - SPRITE_NOTE_HIT). Routed: whoever is up (or the first) writes the
/// other kind of note. The truth line says who wrote what.
function exped_note_fight(_tr, _f) {
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	var _who = (array_length(_up) > 0) ? _up[irandom(array_length(_up) - 1)] : 0;
	var _sp = undefined;
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sids[_who]) _sp = g.sprites[_i];
	if (_sp == undefined) return;
	if (_f[$ "withdrew"] ?? false) return;
	if (_f.won) {
		var _seen = [];
		for (var _j = 0; _j < array_length(_f.foes); _j++) {
			var _fo = _f.foes[_j];
			var _kd = _fo[$ "kind"] ?? "";
			if (_kd == "" || array_contains(_seen, _kd)) continue;
			array_push(_seen, _kd);
			if (!roll_perc(50)) continue;
			var _txt = sprite_note_gen(_sp, "foe", { foe : _fo });
			if (_txt != "" && sprite_note(_sp, _txt, "foe:" + _kd))
				array_push(_tr.log, _sp.name + " writes: \"" + _txt + "\"");
		}
	} else if (roll_perc(60)) {
		var _txt = sprite_note_gen(_sp, "rout", { foe : _f.b });
		if (_txt != "" && sprite_note(_sp, _txt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _txt + "\"");
	}
}
