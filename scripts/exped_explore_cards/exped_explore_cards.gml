/// @description exped_explore_cards(dest, [ri]) -> the three explore cards: [{ kind : "explore", ex, n, name, txt, note }]
/// THE EXPLORE HAND (his ask, 2026-09-15: "the explore button should show
/// cards as well with less quest type objectives"): wander (until
/// recalled - the old explore), ramble (about N hours, then home) and
/// survey (N places, then home). N off the region's seed, so a region's
/// cards hold still. The trip carries { ex, n } and turns for home when
/// it is due (exped_next_node); it pays as an explore always did (by the
/// hours wandered).
function exped_explore_cards(_d, _ri = 0) {
	var _rg = region_get(_d, _ri);
	var _rh = 6 + (hash_mix(_rg.seed, 101) mod 5) * 2;     // 6..14 hours
	var _sn = 3 + (hash_mix(_rg.seed, 103) mod 4);         // 3..6 places
	return [
		{ kind : "explore", ex : "wander", n : 0,   name : "wander", txt : "wander " + _rg.name + " until recalled", note : "they pick their own way: inns when hurt and there is coin, shops, taverns, dungeons, camps, the wild. [recall] on the trip's page brings them home" },
		{ kind : "explore", ex : "ramble", n : _rh, name : "ramble", txt : "roam " + _rg.name + " for about " + string(_rh) + " hours, then come home", note : "a walk with a clock on it: whatever they find on the way, they turn for the landing zone when the hours are up" },
		{ kind : "explore", ex : "survey", n : _sn, name : "survey", txt : "see " + string(_sn) + " places in " + _rg.name + ", then come home", note : "a look at the region: " + string(_sn) + " places reached (the landing zone does not count), then the landing zone" },
	];
}
