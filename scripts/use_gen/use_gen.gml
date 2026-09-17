/// @description use_gen(kind, [size], [lv], [line]) -> a consumable item { slot "use", kind, size, .. }
/// THE POTIONS off potion_config (2026-09-17): the name (the big one for a
/// size-2 red or blue), the colour, the rarity it reads as; the elixir is
/// its own (drunk on the spot, sprite_take). The gear fields ride along
/// empty so the pocket and the sheet treat it like anything else.
function use_gen(_kind, _size = 1, _lv = 1, _line = "") {
	var _big = (_size >= 2);
	var _it = { slot : "use", kind : _kind, size : _size, lv : _lv, line : _line, rar : _big ? 2 : 0, seed : 0, tag : "", own : "", gen : 2,
	            pts : {}, quirks : [], holds : "", crit : 0, cnt : 0, erode : 1, mp0 : 0, fam : "potion", score0 : 0, name : "", col : c_white };
	if (_kind == "elixir") {
		_it.name = "elixir of " + ((_line == "mag") ? "int" : ((_line == "mdef") ? "res" : _line)); _it.col = c_lavender; _it.fam = "elixir"; _it.rar = 5;
		return _it;
	}
	var _pc = potion_find(_kind);
	if (is_undefined(_pc)) { _it.name = "a bottle of something"; _it.col = c_hpurple; return _it; }
	_it.name = (_big && _pc.big != "") ? _pc.big : _pc.name;
	_it.col = _pc.col;
	_it.rar = max(_it.rar, _pc.rar);
	if (_kind == "tonic" || _kind == "totem") _it.fam = _kind;
	return _it;
}
