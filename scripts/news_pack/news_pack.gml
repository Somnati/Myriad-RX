/// @description news_pack() -> "seed:ri:left=txt|..." the world's news for the save (q285)
function news_pack() {
	exped_init();
	var _nw = g.exped[$ "news"];
	if (!is_array(_nw)) return "";
	var _out = "";
	for (var _i = 0; _i < array_length(_nw); _i++) {
		var _n = _nw[_i];
		if (!is_struct(_n)) continue;
		var _t = string_replace_all(string_replace_all(_n.txt, "|", " "), "=", "-");
		_out += ((_out != "") ? "|" : "") + string(_n.seed) + ":" + string(_n.ri) + ":" + string(max(0, round(_n.left))) + "=" + _t;
	}
	return _out;
}
