/// @description exped_pack() -> the trip / haul as one string for the save
/// The trip: dest (seed:biome:tier:dist:rate:name) / crew / clock /
/// stage / rooms / hp / cleared / routed / the finds. A fight in
/// progress is NOT packed - the room replays from its start on load,
/// which is honest (the fight is seeded by nothing). The haul packs
/// the same way with a flag.
function exped_pack() {
	exped_init();
	var _e = g.exped;
	var _o = "";
	var _src = !is_undefined(_e.trip) ? _e.trip : (!is_undefined(_e.haul) ? _e.haul : undefined);
	if (is_undefined(_src)) return "";
	var _d = _src.dest;
	_o += (is_undefined(_e.trip) ? "H" : "T");
	_o += "|" + string(_d.seed) + ":" + string(_d.biome) + ":" + string(_d.tier) + ":" + string(_d.dist) + ":" + string(_d.rate) + ":" + _d.name;
	_o += "|" + string(_src.sid) + ":" + _src.sname;
	if (!is_undefined(_e.trip)) {
		var _tr = _e.trip;
		var _ri = _tr.room_i - (is_undefined(_tr.fight) ? 0 : 1);   // an open fight replays its room
		_o += "|" + string(_tr.t) + ":" + string(_tr.stage) + ":" + string(_ri) + ":" + string(_tr.hp) + ":" + string(_tr.hpmax) + ":" + string(_tr.cleared) + ":" + (_tr.routed ? "1" : "0");
		_o += "|" + string_join_ext(",", _tr.rooms);
	} else {
		_o += "|0:2:0:0:0:" + string(_src.cleared) + ":" + (_src.routed ? "1" : "0");
		_o += "|";
	}
	var _f = "";
	for (var _i = 0; _i < array_length(_src.finds); _i++) {
		var _l = _src.finds[_i];
		_f += ((_i > 0) ? "," : "") + _l.kind + ":" + string(_l.rar) + ":" + string(_l[$ "n"] ?? 0) + ":" + (_l[$ "fam"] ?? "") + ":" + string(_l[$ "tier"] ?? 0);
	}
	_o += "|" + _f;
	return _o;
}
