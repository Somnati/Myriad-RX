/// @description exped_offer_pack() -> every region's offer as one string for the save
/// records joined by "#": seed:ri:next | salt~left~taken~easy | ... (a slot a field)
/// ...and a PERSONAL card (2026-09-16) as P~left~taken~kind,node,from,foe,n,mult,who,nodes(;),pnote
function exped_offer_pack() {
	exped_init();
	var _e = g.exped;
	if (!is_struct(_e[$ "offers"])) return "";
	var _out = "";
	var _ks = variable_struct_get_names(_e.offers);
	for (var _k = 0; _k < array_length(_ks); _k++) {
		var _of = _e.offers[$ _ks[_k]];
		var _o = string(_of.seed) + ":" + string(_of.ri) + ":" + string(_of.next);
		for (var _i = 0; _i < array_length(_of.slots); _i++) {
			var _sl = _of.slots[_i];
			_o += "|" + string(_sl.salt) + "~" + string(max(0, round(_sl.left))) + "~" + string(_sl.taken) + "~" + (_sl.easy ? "1" : "0");
		}
		if (is_array(_of[$ "pq"])) for (var _i = 0; _i < array_length(_of.pq); _i++) {
			var _p = _of.pq[_i], _q = is_struct(_p.q) ? _p.q : _p[$ "raw"];
			if (!is_struct(_q)) continue;
			var _scrub = function(_t) { return string_replace_all(string_replace_all(string_replace_all(string_replace_all(string(_t), ",", " "), "~", " "), "|", " "), "#", " "); };
			_o += "|P~" + string(max(0, round(_p.left))) + "~" + string(_p.taken) + "~" + _q.kind + "," + string(_q.node) + "," + string(_q[$ "from"] ?? -1) + "," + string(_q[$ "foe"] ?? "") + "," + string(_q.n) + "," + string(_q.mult) + "," + _scrub(_q[$ "who"] ?? "") + "," + (is_array(_q[$ "nodes"]) ? string_join_ext(";", _q.nodes) : "") + "," + _scrub(_q[$ "pnote"] ?? "");
		}
		_out += ((_k > 0) ? "#" : "") + _o;
	}
	return _out;
}
