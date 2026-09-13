/// @description ticket_roll(ticket) -> { win, sym, grid } - what is under
/// the foil, replayed from the ticket's seed (the same ticket always
/// shows the same grid). HOW A SCRATCH TICKET IS PRINTED: the outcome
/// is decided FIRST at the printed odds, then a grid is laid that
/// agrees with it - a winner carries exactly three of its symbol, a
/// loser carries no symbol more than twice. Nothing else is tuned: the
/// fillers are drawn flat, so near-misses (two of a kind) happen at
/// their natural rate, never an engineered one (his rule: the ticket
/// never lies). Five symbols x two = ten fillers, so a nine-cell loser
/// always fills.
function ticket_roll(_t) {
	var _c = ticket_config();
	var _ns = array_length(_c.syms);
	var _s = random_get_seed();
	random_set_seed(_t.seed);
	var _win = (random(100) < _c.rars[_t.rar].win);
	var _sym = irandom(_ns - 1);
	var _cnt = array_create(_ns, 0);
	var _list = [];
	if (_win) { repeat (3) array_push(_list, _sym); _cnt[_sym] = 99; }
	while (array_length(_list) < 9) {
		var _k = irandom(_ns - 1);
		if (_cnt[_k] >= 2) continue;
		_cnt[_k] += 1;
		array_push(_list, _k);
	}
	// shuffle (Fisher-Yates, on the ticket's stream)
	for (var _i = 8; _i > 0; _i--) {
		var _j = irandom(_i);
		var _tmp = _list[_i]; _list[_i] = _list[_j]; _list[_j] = _tmp;
	}
	rng_release(_s);   // never random_set_seed(_s): that rewinds
	return { win : _win, sym : _win ? _sym : -1, grid : _list };
}
