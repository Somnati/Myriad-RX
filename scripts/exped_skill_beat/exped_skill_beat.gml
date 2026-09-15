/// @description exped_skill_beat(trip, chance) - someone up may learn a skill (sprite_skill_learn); the diary says so
/// Called after a won fight, at a shrine, in a tavern, on a level (the
/// chances are the callers'). The "+ " line is a reward line.
function exped_skill_beat(_tr, _chance) {
	if (!roll_perc(_chance * 100)) return;
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	if (array_length(_up) == 0) return;
	var _sp = exped_sprite(_tr.sids[_up[irandom(array_length(_up) - 1)]]);
	if (is_undefined(_sp)) return;
	var _txt = sprite_skill_learn(_sp);
	if (_txt != "") { array_push(_tr.log, "+ " + _txt); exped_stat("skills"); }
}
