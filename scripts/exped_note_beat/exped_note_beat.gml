/// @description exped_note_beat(trip, beat, chance) - a dumb note, maybe
/// One random member who is up writes the useless kind (sprite_note_gen's
/// land / rest / find / home) with that chance; the truth line quotes it.
/// ctx: the planet, a partner's name, the item (from the trip's last find).
function exped_note_beat(_tr, _beat, _chance, _item = "") {
	if (!roll_perc(_chance * 100)) return;
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	if (array_length(_up) == 0) return;
	var _who = _up[irandom(array_length(_up) - 1)];
	var _sp = undefined;
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sids[_who]) _sp = g.sprites[_i];
	if (_sp == undefined) return;
	var _partner = "";
	for (var _k = 0; _k < array_length(_tr.names); _k++) if (_k != _who) { _partner = _tr.names[_k]; break; }
	var _txt = sprite_note_gen(_sp, _beat, { planet : _tr.dest.name, partner : (_partner != "") ? _partner : "the ship", item : _item });
	if (_txt != "" && sprite_note(_sp, _txt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _txt + "\"");
}
