/// @description syz_cost(s, what, [i]) -> the flux (or tokens, for the token buys - a struct { flux, tokens }) a thing costs; -1 = not to be had. what: lv / per / cycle / sync / anchor / harm / ninth
function syz_cost(_s, _what, _i = -1) {
	var _n = array_length(_s.cycles);
	switch (_what) {
		case "lv":     return (_i < 0 || _i >= _n) ? -1 : round(20 * power(1.35, _s.cycles[_i].lv - 1) * (1 + _i * .5));
		case "per":    return (_i < 0 || _i >= _n) ? -1 : round(6 * (1 + (_s.cycles[_i].lv - 1) * .5) * (1 + _i * .3));   // (a second either way)
		case "cycle":  return (_n >= _s.cap) ? -1 : round(120 * power(4.5, _n - 2));
		case "sync":   return (_s.sync_cd > 0) ? -1 : max(60, round(_s.rate * 60));   // (a minute's flux, on the readout's rate)
		case "anchor": { if (_i < 0 || _i >= _n || _s.cycles[_i].anchor) return -1; var _na = 0; for (var _j = 0; _j < _n; _j++) if (_s.cycles[_j].anchor) _na++; return round(300 * power(2.2, _na)); }
		case "harm":   return 1 + floor((_s.harm - 1) * 2);   // (tokens: the harmonic up a half - one, then two, three... each step dearer)
		case "ninth":  return (_s.cap >= 9) ? -1 : 3;   // (three tokens: the ninth cycle)
	}
	return -1;
}
