/// @description gear_gen(slot, lv, rar, seed) -> an item { slot, fam, name, lv, rar, seed, pts, col, score0 }
/// THE SILLY GENERATOR. slot = "w1" / "w2" / "armor" / "talis"; the family
/// and the name roll from the seed (an item is the same item on every
/// load: the save keeps slot / lv / rar / seed and regenerates). POINTS
/// = (1.5 + .5 x lv) x (1 + .4 x rarity), spread over the family's stat
/// lines by weight with a little jitter - so a level-10 rare sword is
/// worth ~11 stat points, a fifth of a level-10 sprite. Names: [an
/// adjective] noun [a suffix past rare], the adjective more likely the
/// rarer it is. col = the house rarity colour. score0 = the flat sum.
function gear_gen(_slot, _lv, _rar, _seed) {
	var _old = random_get_seed();
	random_set_seed(_seed & $7fffffff);
	var _fams = gear_families()[$ _slot];
	var _fam = _fams[irandom(array_length(_fams) - 1)];
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
	var _name = _fam.nouns[irandom(array_length(_fam.nouns) - 1)];
	if (random(1) < .25 + .1 * _rar) _name = _adjs[irandom(array_length(_adjs) - 1)] + " " + _name;
	if (_rar >= 2 && random(1) < .3 + .15 * _rar) _name += " " + _sufs[irandom(array_length(_sufs) - 1)];
	rng_release(_old);
	return { slot : _slot, fam : _fam.key, name : _name, lv : max(1, _lv), rar : _rar, seed : _seed & $7fffffff,
	         pts : _pts, col : upgrade_rarity_info(_rar).col, score0 : _sum };
}
