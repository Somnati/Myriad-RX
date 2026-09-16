/// @description sprite_elixir(sprite, line) -> the text: THE ELIXIR (his ask, 2026-09-16) - +1 to one line, for good, on the sprite that drinks it
/// sheet.elix = { line : n } - sprite_stats adds it after the base and the
/// gear (it shows in the green), sprite_luck adds its luck; saved as the
/// sheet's ninth field. No cap: the ladder's odds are the cap.
function sprite_elixir(_sp, _line) {
	var _sh = sprite_sheet(_sp);
	if (!is_struct(_sh[$ "elix"])) _sh.elix = {};
	_sh.elix[$ _line] = (_sh.elix[$ _line] ?? 0) + 1;
	save_mark_dirty();
	var _lab = (_line == "mag") ? "int" : ((_line == "mdef") ? "res" : _line);
	return _sp.name + " drank the elixir of " + _lab + " on the spot. +1 " + _lab + ", for good" + choose(". it tasted of the colour purple", ". nothing happened, then something did", ". the bottle is kept", ". " + _sp.name + " feels the same, and is not");
}
