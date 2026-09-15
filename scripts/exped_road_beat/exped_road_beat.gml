/// @description exped_road_beat(trip) - a little thing on the road (his ask,
/// 2026-09-15: "i'd like little things to happen while they are walking")
/// Called once per road-hour crossed when the encounter roll opened
/// nothing; EXPED_ROAD_BEAT% of the time one of these: the weather, a
/// coin in the mud, berries or a spring (a little hp back), a stumble
/// (a little hp off one of them), a shortcut or a washed-out road (half
/// an hour gained or lost), two of them talking (a bond point), a
/// landmark, an animal, a sit-down, or a road note in someone's pad.
/// Never a fight - those are exped_encounter's.
function exped_road_beat(_tr) {
	if (!roll_perc(EXPED_ROAD_BEAT)) return;
	var _rd = _tr.road;
	if (!is_struct(_rd)) return;
	var _rg = exped_region(_tr);
	var _to = _rg.nodes[clamp(_rd.b, 0, array_length(_rg.nodes) - 1)].name;
	var _n = array_length(_tr.sids);
	var _up = [];
	for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	if (array_length(_up) == 0) return;
	var _who = _up[irandom(array_length(_up) - 1)];
	var _nm = _tr.names[_who];
	var _other = _tr.names[(_who + 1) mod _n];
	exped_stat("beats");
	var _r = random(100);
	if (_r < 16 && (_tr[$ "night"] ?? false)) {
		// the night's own
		array_push(_tr.log, choose("an owl. " + _nm + " answered it. it did not answer back.", "stars, all of them. " + _nm + " picked one and kept it.",
			"a fire, far off. nobody went to look.", "something walked alongside them in the dark for a while, then did not.",
			"cold. " + _nm + " and " + _other + " walked closer together and said nothing about it.", "the road glowed a little. nobody knew why."));
	} else if (_r < 16) {
		// the weather
		array_push(_tr.log, choose("rain. everyone is wet now.", "the wind picked up, then thought better of it.",
			"sun. " + _nm + " complained about the sun.", "fog. " + _nm + " walked into " + _other + " twice.",
			"a fine day. nobody said so.", "drizzle, the kind that gets in.", "clouds came over and stayed.",
			"hot. the road shimmered. " + _nm + " swore it moved."));
	} else if (_r < 28) {
		// a coin in the mud
		var _c = 1 + irandom(1);
		_tr.credits += _c;
		exped_stat("finds");
		array_push(_tr.log, "+ " + string(_c) + ((_c == 1) ? " credit" : " credits") + " " + choose("in the mud", "under a hedge", "in a ditch, with a boot", "on the road, shining", "in a puddle"));
	} else if (_r < 38) {
		// berries, a spring: a little back
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .1);
		array_push(_tr.log, choose("wild berries. probably fine. they were fine.", "a spring by the road. cold, and good.",
			"apples, off a tree that was not anyone's.", "a farmer's wife gave them bread. nobody knows why."));
	} else if (_r < 46) {
		// a stumble: a little off one of them (never below one)
		_tr.hp[_who] = max(1, _tr.hp[_who] - _tr.hpmax[_who] * .05);
		array_push(_tr.log, _nm + " " + choose("tripped over nothing and blamed the nothing.", "walked into a branch. the branch was fine.",
			"slipped on the bank and got a wet leg.", "stubbed a toe on a rock that had been there for a thousand years.",
			"was stung by something. it is fine. it is FINE."));
	} else if (_r < 53) {
		// a shortcut: half an hour gained
		_rd.t += EXPED_HOUR * .5;
		array_push(_tr.log, choose("a shortcut through the hedges. it worked, mostly.", "a cart going their way gave them a lift for a bit.",
			"a dry riverbed ran straight toward " + _to + ". they took it.", "a fence with a hole in it saved half an hour."));
	} else if (_r < 60) {
		// the road out: half an hour lost
		_rd.t = max(0, _rd.t - EXPED_HOUR * .5);
		array_push(_tr.log, choose("the road was out. the long way round.", "a bog. they went around it. eventually.",
			_nm + " was sure it was this way. it was not this way.", "a fallen tree across the road. it took a while.",
			"a gate, locked, and a wall too high. back to the fork."));
	} else if (_r < 70 && _n > 1) {
		// two of them talking: a bond point
		var _a = _tr.sids[_who], _b = _tr.sids[(_who + 1) mod _n];
		exped_bond_add(_a, _b, 1);
		array_push(_tr.log, _nm + " and " + _other + " " + choose("argued about which way is north. the road went on regardless.",
			"walked in step for an hour without noticing.", "shared the last of the bread.", "compared blisters. " + _other + " won.",
			"talked about the ship. both miss it. neither said so.", "sang. it was not good. it was loud."));
	} else if (_r < 80) {
		// a landmark
		array_push(_tr.log, choose("passed a standing stone with a face scratched on it.", "a signpost. it pointed at the sky.",
			"an abandoned cart. someone took the wheels.", "a milestone: " + _to + ", it said, and a number nobody believed.",
			"a shrine the size of a hat, with a hat in it.", "a bridge. under it, a smaller bridge.",
			"a scarecrow. " + _nm + " waved at it.", "a well. " + _nm + " shouted into it. it shouted back, later."));
	} else if (_r < 88) {
		// an animal
		array_push(_tr.log, choose("a fox watched from the hedge. the fox won the staring contest.", "a bird followed them for an hour. it knows something.",
			"sheep. many sheep. one of them was in charge.", "a frog crossed the road with great dignity.",
			"a dog came along for a mile, then remembered something and left.", "cows looked at them. they looked at the cows."));
	} else if (_r < 94) {
		// a sit-down: a little back
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .05);
		array_push(_tr.log, choose("sat under a tree. a good tree.", "stopped to look at the view. there was one.", "boots off. boots on. onward."));
	} else {
		// a road note
		exped_note_beat(_tr, "road", 1);
	}
}
