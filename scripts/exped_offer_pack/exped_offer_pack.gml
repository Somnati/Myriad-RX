/// @description exped_offer_pack() -> every region's offer as one string for the save
/// records joined by "#": seed:ri:next | salt~left~taken~easy | ... (a slot a field)
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
		_out += ((_k > 0) ? "#" : "") + _o;
	}
	return _out;
}
