/// @description exped_rivals(dest) -> the world's three RIVAL CREWS [{ name, lead, col }] (his pick, 2026-09-16), rolled under the world's seed and cached on it
/// "other people take quests too": a rival takes an open card now and
/// then (exped_offer_tick, taken = -(i + 1); the card names them), turns
/// up on the road (exped_encounter: a word, a note swapped), in the
/// tavern (exped_act_step: a round, a brawl) and at a dungeon door
/// ("nothing left", said the lead - the delve is a quiet one). Names
/// from the generators - a lead's name and a crew name off pools.
function exped_rivals(_d) {
	if (is_array(_d[$ "rivals"])) return _d.rivals;
	var _old = random_get_seed();
	random_set_seed((_d.seed ^ $b1f) & $7fffffff);
	var _out = [];
	repeat (3) {
		var _lead = str_cap(sprite_name_gen());
		var _r = random(100), _nm;
		if (_r < 35) _nm = _lead + "'s " + choose("lot", "crew", "three", "band", "company", "gang", "irregulars", "cousins");
		else if (_r < 70) _nm = "the " + choose("red", "black", "quiet", "loud", "late", "second", "bent", "salt", "tin", "wet", "long") + " " + choose("kettles", "spoons", "hats", "crows", "boots", "geese", "lanterns", "buckets", "knives");
		else _nm = _lead + " and the " + choose("two", "three", "four", "twins", "cousins", "dog", "other one");
		array_push(_out, { name : _nm, lead : _lead, col : make_colour_hsv(irandom(255), 120, 200) });
	}
	rng_release(_old);
	_d.rivals = _out;
	return _out;
}
