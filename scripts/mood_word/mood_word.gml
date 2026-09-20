/// @description mood_word(sprite) -> { key, txt, col, why } the sprite's mood as a word ("" key = no word: near its rest) and the reason it carries (q261)
///   grieving  a lost buddy still weighs (lost.gr past .25)      tired    the battery under .3
///   shaken / angry   sad and keyed (angry for the brave, grumpy, proud and greedy)     glum    sad and calm
///   cocky / eager    happy and keyed (cocky for the smug, proud, brave and greedy)     content happy and calm
function mood_word(_sp) {
	static _none = { key : "", txt : "", col : c_white, why : "" };
	if (is_undefined(_sp) || !is_struct(_sp[$ "mood"])) return _none;
	var _m = _sp.mood, _b = mood_base(_sp), _pn = mood_pers(_sp);
	var _dv = _m.v - _b.v, _hot = (_m.a > .5);
	var _k = "", _col = c_white;
	if (is_struct(_m.lost) && _m.lost.gr > .25) { _k = "grieving"; _col = c_lavender; }
	else if (_m.e < .3) { _k = "tired"; _col = c_steelblue; }
	else if (_dv < -.3) {
		if (_hot) { _k = (_pn == "brave" || _pn == "grumpy" || _pn == "proud" || _pn == "greedy") ? "angry" : "shaken"; _col = (_k == "angry") ? c_hred : c_horange; }
		else { _k = "glum"; _col = c_steelblue; }
	}
	else if (_dv > .3) {
		if (_hot) { _k = (_pn == "smug" || _pn == "proud" || _pn == "brave" || _pn == "greedy") ? "cocky" : "eager"; _col = c_gold; }
		else { _k = "content"; _col = c_seagreen; }
	}
	if (_k == "") return _none;
	var _why = (_k == "grieving" && is_struct(_m.lost)) ? (_m.lost.name + " was let go") : _m.why;
	return { key : _k, txt : _k, col : _col, why : _why };
}
