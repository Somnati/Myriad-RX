/// @description gear_gen(slot, lv, rar, seed, [tag], [own], [gen]) -> an item { slot, fam, name, lv, rar, seed, tag, own, gen, pts, col, score0, quirks, holds, crit, cnt, erode, mp0 }
/// THE SILLY GENERATOR. slot = "w1" / "w2" / "armor" / "talis"; the family
/// and the name roll from the seed (an item is the same item on every
/// load: the save keeps slot / lv / rar / seed / tag / own / gen and
/// regenerates). POINTS = (1.5 + .5 x lv) x (1 + .4 x rarity), spread over
/// the family's stat lines by weight with a little jitter - so a
/// level-10 rare sword is worth ~11 stat points, a fifth of a level-10
/// sprite. Names: [an adjective] noun [a suffix past rare], the adjective
/// more likely the rarer it is. col = the house rarity colour. score0 =
/// the flat sum.
/// THE PROC-GEAR PASS (2026-09-15), rolled AFTER the old stream so a
/// pre-pass item keeps its family, points and noun:
///   tag    the place kind it came from (gear_tags): a flavour adjective
///          sometimes, and a lean toward the land's quirk
///   quirks by rarity (gear_quirks): none / one / two, named into the item
///          (the first as an adjective when the slot is free, else a
///          suffix; the second the other way); a hazard hold, a garnish,
///          or cursed (x1.35, one line to .6)
///   own    a named boss's name in front ("bokk the goblin king's pot lid")
///   gen    1 = a pre-pass item: the family picks from the OLD pool sizes
///          (the same item on every load - the law); 2 = the full pools
function gear_gen(_slot, _lv, _rar, _seed, _tag = "", _own = "", _gen = 2) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _fams = gear_families()[$ _slot];
	var _nf = array_length(_fams);
	if (_gen <= 1) { switch (_slot) { case "w1": _nf = 8; break; default: _nf = 6; break; } }   // (the pools before the pass)
	var _fam = _fams[irandom(min(_nf, array_length(_fams)) - 1)];
	_rar = clamp(floor(_rar), 0, 7);
	var _budget = (1.5 + .5 * max(1, _lv)) * (1 + .4 * _rar);
	var _lk = variable_struct_get_names(_fam.lines);
	var _wsum = 0;
	for (var _i = 0; _i < array_length(_lk); _i++) _wsum += _fam.lines[$ _lk[_i]];
	var _pts = {};
	var _sum = 0;
	for (var _i = 0; _i < array_length(_lk); _i++) {
		var _v = _budget * (_fam.lines[$ _lk[_i]] / _wsum) * random_range(.85, 1.15);
		_v = round(_v * 10) / 10;
		_pts[$ _lk[_i]] = _v;
		_sum += _v;
	}
	var _adjs = ["damp", "borrowed", "haunted (a little)", "artisanal", "suspicious", "grandma's", "regulation",
	             "improvised", "very shiny", "lightly cursed", "second-hand", "questionable", "legendary-ish",
	             "heavy", "quiet", "loud", "ceremonial", "rusty", "ornate", "alarmingly warm"];
	var _sufs = ["of mild inconvenience", "of the damp cellar", "of probably fire", "of good intentions",
	             "of the lost sock", "of unpaid taxes", "of surprising heft", "of the tuesday", "of local renown",
	             "of no fixed address", "of the long nap", "of someone's uncle", "of moderate doom"];
	var _noun = _fam.nouns[irandom(array_length(_fam.nouns) - 1)];
	var _adj = "", _suf = "";
	if (random(1) < .25 + .1 * _rar) _adj = _adjs[irandom(array_length(_adjs) - 1)];
	if (_rar >= 2 && random(1) < .3 + .15 * _rar) _suf = _sufs[irandom(array_length(_sufs) - 1)];
	// ---- the pass's rolls, after the old stream ----
	var _tg = gear_tags()[$ _tag];
	if (is_struct(_tg) && random(1) < .45) _adj = _tg.adjs[irandom(array_length(_tg.adjs) - 1)];   // (the land's word takes the adjective)
	var _qs = gear_quirks();
	var _nq = 0;
	if (_rar == 0)      _nq = (random(1) < .15) ? 1 : 0;
	else if (_rar == 1) _nq = (random(1) < .45) ? 1 : 0;
	else if (_rar <= 3) _nq = 1 + ((random(1) < .25) ? 1 : 0);
	else                _nq = 1 + ((random(1) < .6) ? 1 : 0) + ((_rar >= 6 && random(1) < .5) ? 1 : 0);
	var _quirks = [], _holds = "", _crit = 0, _cnt = 0, _erode = 1, _mp0 = 0, _cursed = false;
	var _res_el = "", _res_v = 0, _elem = "";
	var _weapon = (_slot == "w1" || _slot == "w2");
	for (var _n = 0; _n < _nq; _n++) {
		var _qk = undefined, _try = 0;
		do {
			if (is_struct(_tg) && _tg.quirk != "" && random(1) < .5) { for (var _j = 0; _j < array_length(_qs); _j++) if (_qs[_j].key == _tg.quirk) _qk = _qs[_j]; }
			else _qk = _qs[irandom(array_length(_qs) - 1)];
			if (is_undefined(_qk)) _qk = _qs[irandom(array_length(_qs) - 1)];
			_try += 1;
			// (a proofing belongs on armour or a talisman, an element on a weapon - 2026-09-17)
			var _wrong = (!is_undefined(_qk[$ "elem"]) && !_weapon) || (!is_undefined(_qk[$ "res"]) && _weapon);
		} until ((!array_contains(_quirks, _qk.key) && !_wrong) || _try >= 4);
		if (array_contains(_quirks, _qk.key) || _wrong) continue;
		array_push(_quirks, _qk.key);
		if (!is_undefined(_qk[$ "res"]))   { _res_el = _qk.res; _res_v += cbt_balance().res_quirk; }
		if (!is_undefined(_qk[$ "elem"]))  _elem = _qk.elem;
		if (!is_undefined(_qk[$ "hold"]))  _holds = _qk.hold;
		if (!is_undefined(_qk[$ "crit"]))  _crit += _qk.crit;
		if (!is_undefined(_qk[$ "cnt"]))   _cnt += _qk.cnt;
		if (!is_undefined(_qk[$ "erode"])) _erode *= _qk.erode;
		if (!is_undefined(_qk[$ "mp0"]))   _mp0 += _qk.mp0;
		if (!is_undefined(_qk[$ "budget"])) _cursed = true;
		// the name: an adjective while the slot is free, else a suffix (the second quirk the other way)
		if (_adj == "") _adj = _qk.adjs[irandom(array_length(_qk.adjs) - 1)];
		else if (_suf == "") _suf = _qk.sufs[irandom(array_length(_qk.sufs) - 1)];
		else _adj = _qk.adjs[irandom(array_length(_qk.adjs) - 1)] + " " + _adj;   // (both taken: the quirk's word goes in front)
	}
	if (_cursed) {
		// more of it, and a hole: every line x1.35, one line to .6 of that
		var _hk = _lk[irandom(array_length(_lk) - 1)];
		_sum = 0;
		for (var _i = 0; _i < array_length(_lk); _i++) { var _v2 = _pts[$ _lk[_i]] * 1.35 * ((_lk[_i] == _hk) ? .6 : 1); _v2 = round(_v2 * 10) / 10; _pts[$ _lk[_i]] = _v2; _sum += _v2; }
	}
	rng_release(_old);
	var _name = ((_adj != "") ? (_adj + " ") : "") + _noun + ((_suf != "") ? (" " + _suf) : "");
	if (_own != "") _name = _own + "'s " + _name;
	return { slot : _slot, fam : _fam.key, name : _name, lv : max(1, _lv), rar : _rar, seed : _seed & $7fffffff,
	         tag : _tag, own : _own, gen : _gen,
	         pts : _pts, col : upgrade_rarity_info(_rar).col, score0 : _sum,
	         quirks : _quirks, holds : _holds, crit : _crit, cnt : _cnt, erode : _erode, mp0 : _mp0,
	         res_el : _res_el, res_v : _res_v, elem : _elem };   // (the elements pass, 2026-09-17)
}
