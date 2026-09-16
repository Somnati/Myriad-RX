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
	// A USEFUL ONE, a quarter of the time (his ask, 2026-09-16: "make the effect of useful notes more broad"):
	// by where the crew is - the land (the pace on its roads), the weather (no slips, no fog turns), the
	// night (fewer lost hours), a hazard (half its bite), the inn (a bed cheaper), the shop (the haggle)
	if (roll_perc(25)) {
		var _rg = exped_region(_tr);
		var _nd = _rg.nodes[clamp(_tr[$ "pos"] ?? 0, 0, array_length(_rg.nodes) - 1)];
		var _kk = region_kinds()[$ _nd.kind];
		var _wx = _tr[$ "weather"] ?? "calm";
		var _utag = "", _utxt = "";
		switch (_beat) {
			case "land": case "road": {
				var _hz = region_hazard_at(_tr.dest, _rg, _nd.kind);
				if (is_struct(_hz) && roll_perc(40)) { _utag = "haz:" + _hz.key; _utxt = choose(_hz.name + ": " + _hz.hold + ". bring one. brought one.", _hz.name + " is a thing. it is less of a thing if you expect it.", "note on " + _hz.name + ": " + choose("breathe through the nose", "count to three first", "keep the good hand free", "walk like you have been here")); }
				else if (_wx != "calm" && roll_perc(45)) { _utag = "wx:" + _wx; _utxt = choose(_wx + ": walk in it. it is only " + _wx + ".", _wx + " again. the trick is not to notice.", "in " + _wx + ", small steps. wrote it down. small.", _wx + ": the road is still there under it."); }
				else if ((_tr[$ "night"] ?? false) && roll_perc(40)) { _utag = "night"; _utxt = choose("night: count the steps. four hundred to the bend.", "the dark: keep the hedge on the left. the hedge knows.", "at night the road hums. follow the hum.", "night walking: look at the sky-line, not the feet."); }
				else if (is_struct(_kk) && _kk.wild && _nd.kind != "landing") { _utag = "road:" + _nd.kind; _utxt = choose(_nd.kind + ": keep to the left. the left is drier.", "in " + _nd.kind + " the short way is the long way. take the long way.", _nd.kind + ": there is a path. it is not the one you can see.", "walking " + _nd.kind + ": lean into it. it leans back less."); }
				break;
			}
			case "rest": if (roll_perc(60)) { _utag = "inn"; _utxt = choose("inns: ask for the small room. it is the same room.", "innkeepers: say the last place was cheaper. it was not.", "a bed costs less after the second yawn. yawn.", "the inn: pay in the morning. mornings are cheaper."); } break;
			case "shop": _utag = "shop"; _utxt = choose("shops: look bored. the price drops.", "shopkeepers: ask about the cat first. then the price.", "haggling: say a number. wait. say it again.", "the trick with shops is to leave once. slowly."); break;
		}
		if (_utag != "" && _utxt != "" && !sprite_note_has(_sp, _utag) && sprite_note(_sp, _utxt, _utag)) { array_push(_tr.log, _sp.name + " writes: \"" + _utxt + "\""); return; }
	}
	var _txt = sprite_note_gen(_sp, _beat, { planet : _tr.dest.name, partner : (_partner != "") ? _partner : "the ship", item : _item });
	if (_txt != "" && sprite_note(_sp, _txt, "")) array_push(_tr.log, _sp.name + " writes: \"" + _txt + "\"");
}
