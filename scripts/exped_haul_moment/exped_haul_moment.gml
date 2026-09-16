/// @description exped_haul_moment(trip) -> { title, line } THE BEST MOMENT of a trip come home (his pick, 2026-09-16)
/// The diary read once at the haul's making: every line scored by what
/// it was (a rout home, a member down, a title, a boss down, the credits
/// joke, the totem, an elixir, the dice, one more room, a find, a brawl,
/// the quest done...), the best kept with a title in the form "the one
/// where..." - what you would tell someone about the trip. Saved on the
/// haul (bt / bm). A trip with nothing to tell is "the quiet one".
function exped_haul_moment(_tr) {
	static _first = function(_l, _names) { var _sp = string_pos(" ", _l); var _w = (_sp > 1) ? string_copy(_l, 1, _sp - 1) : _l; return array_contains(_names, _w) ? _w : "somebody"; };
	static _quoted = function(_l) { var _a = string_pos("\"", _l); if (_a <= 0) return ""; var _rest = string_delete(_l, 1, _a); var _b = string_pos("\"", _rest); return (_b > 1) ? string_copy(_rest, 1, _b - 1) : ""; };
	var _log = _tr.log, _bs = 0, _bl = "", _bt = "";
	for (var _i = 0; _i < array_length(_log); _i++) {
		var _l = _log[_i], _pre = string_copy(_l, 1, 2);
		if (_pre == "~ " || _pre == "* " || _pre == "# ") continue;
		var _s = 0, _t = "";
		if (string_pos("home, limping", _l) > 0)                                          { _s = 9; _t = "the one they limped home from"; }
		else if (string_pos("is finished. ", _l) > 0)                                    { _s = 9; _t = "the one where the thread was cut"; }
		else if (string_pos("bane of the", _l) > 0 || string_pos("scourge of the", _l) > 0 || string_pos("warden", _l) > 0) { _s = 8; _t = "the one where the names were earned"; }
		else if (string_pos("totem cracks", _l) > 0)                                     { _s = 8; _t = "the one with the totem"; }
		else if (string_pos(" is down. cautious", _l) > 0)                               { _s = 7; _t = "the one where " + _first(_l, _tr.names) + " went down"; }
		else if (string_pos(" is down. ", _l) > 0)                                       { _s = 7; _t = "the one where " + string_copy(_l, 1, string_pos(" is down. ", _l) - 1) + " went down"; }
		else if (string_pos(" a look", _l) > 0 || string_pos("already a credit", _l) > 0) { _s = 7; _t = "the one where " + _first(_l, _tr.names) + " tried to sell a credit"; }
		else if (string_pos("drank the elixir", _l) > 0)                                 { _s = 6; _t = "the one with the elixir"; }
		else if (string_pos("the camp burns", _l) > 0)                                   { _s = 5; _t = "the one where the camp burned"; }
		else if (string_pos("sat down to", _l) > 0)                                      { _s = 5; _t = "the one with the dice"; }
		else if (string_pos("one more room", _l) > 0)                                    { _s = 5; _t = "the one with one more room"; }
		else if (string_pos("a brawl with", _l) > 0 || string_pos("bar fight", _l) > 0)  { _s = 5; _t = "the one with the bar fight"; }
		else if (string_pos("barred", _l) > 0)                                           { _s = 5; _t = "the one where they were barred"; }
		else if (_pre == "+ " && string_pos("acquired", _l) > 0)                         { var _qn = _quoted(_l); _s = 4; _t = (_qn != "") ? ("the one with " + _qn) : "the one with the find"; }
		else if (string_pos("word gets round", _l) > 0)                                  { _s = 4; _t = "the one that got talked about"; }
		else if (string_pos("the quest is done", _l) > 0)                                { _s = 4; _t = "the one where the quest got done"; }
		else if (string_pos("came out of", _l) > 0 || string_pos("stood ", _l) > 0)      { _s = 3; _t = "the one with the other crew"; }
		else if (string_pos("wrong change", _l) > 0)                                     { _s = 3; _t = "the one with the wrong change"; }
		if (_s > _bs || (_s == _bs && _s > 0 && roll_perc(50))) { _bs = _s; _bl = _l; _bt = _t; }
	}
	if (_bs == 0) return { title : "the quiet one", line : "" };
	var _bp = string_copy(_bl, 1, 2);
	if (_bp == "+ ") _bl = string_delete(_bl, 1, 2);
	return { title : _bt, line : _bl };
}
