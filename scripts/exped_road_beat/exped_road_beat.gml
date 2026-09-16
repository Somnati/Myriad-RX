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
	if (!roll_perc(EXPED_ROAD_BEAT)) { exped_say(_tr, "road", undefined, .16); return; }   // (an hour of nothing: the voice, sometimes - 2026-09-15)
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
	// (the road-beats pass, 2026-09-15: every pool twice the size, and four
	// new things - a ford, a hawker, a stuck cart, a wayside shrine)
	if (_r < 12 && (_tr[$ "night"] ?? false)) {
		// the night's own
		array_push(_tr.log, choose("an owl. " + _nm + " answered it. it did not answer back.", "stars, all of them. " + _nm + " picked one and kept it.",
			"a fire, far off. nobody went to look.", "something walked alongside them in the dark for a while, then did not.",
			"cold. " + _nm + " and " + _other + " walked closer together and said nothing about it.", "the road glowed a little. nobody knew why.",
			"a fox barked. it sounded like a question. nobody had the answer.", "the lamp guttered. " + _nm + " cupped it and got a warm hand.",
			"an hour of dark with the sound of their own feet, which " + _nm + " counted, and lost, and counted.", "a light in a window, far off. somebody up late. " + _nm + " waved at it.",
			"bats. " + _nm + " ducked. the bats had not noticed " + _nm + ".", "the moon went behind a cloud and the road went with it, briefly."));
	} else if (_r < 12) {
		// the weather
		array_push(_tr.log, choose("rain. everyone is wet now.", "the wind picked up, then thought better of it.",
			"sun. " + _nm + " complained about the sun.", "fog. " + _nm + " walked into " + _other + " twice.",
			"a fine day. nobody said so.", "drizzle, the kind that gets in.", "clouds came over and stayed.",
			"hot. the road shimmered. " + _nm + " swore it moved.", "a rainbow. " + _nm + " pointed. everyone had seen it. " + _nm + " pointed again.",
			"the sun came out and " + _nm + " took a coat off and the sun went in.", "a cold snap. breath in the air. " + _nm + " made shapes with it.",
			"warm rain, which is rain with manners.", "a wind from behind, for once. the road went easy for a mile."));
	} else if (_r < 22) {
		// a coin in the mud
		var _c = 1 + irandom(1);
		_tr.credits += _c;
		exped_stat("finds");
		array_push(_tr.log, "+ " + string(_c) + ((_c == 1) ? " credit" : " credits") + " " + choose("in the mud", "under a hedge", "in a ditch, with a boot", "on the road, shining", "in a puddle",
			"in a bird's nest, of all places", "under a stone " + _nm + " turned for no reason", "in the pocket of a coat on a fence", "in the road's middle, where everyone had walked past it", "stuck in a tree, at a height " + _nm + " is not proud of reaching"));
	} else if (_r < 30) {
		// berries, a spring: a little back
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .1);
		array_push(_tr.log, choose("wild berries. probably fine. they were fine.", "a spring by the road. cold, and good.",
			"apples, off a tree that was not anyone's.", "a farmer's wife gave them bread. nobody knows why.",
			"mushrooms. " + _nm + " knew which ones. " + _nm + " was right, this time.", "a shepherd shared his cheese. it was strong cheese. it helped.",
			"nuts, off the ground, off a tree, off the season. good nuts.", "a stream to drink from. " + _nm + " drank most of it.",
			"honey, from a hollow tree, at a cost of two stings and a run.", "a pie left cooling on a sill. nobody asked. it was cooled."));
	} else if (_r < 37) {
		// a stumble: a little off one of them (never below one)
		_tr.hp[_who] = max(1, _tr.hp[_who] - _tr.hpmax[_who] * .05);
		array_push(_tr.log, _nm + " " + choose("tripped over nothing and blamed the nothing.", "walked into a branch. the branch was fine.",
			"slipped on the bank and got a wet leg.", "stubbed a toe on a rock that had been there for a thousand years.",
			"was stung by something. it is fine. it is FINE.", "sat on a thistle. stood up quickly. sat on another.",
			"put a foot in a rabbit hole and the rest of the leg after it.", "was hit by a falling apple and has forgiven the tree, mostly.",
			"walked into a gate that was closed, having been sure it was open.", "went over an ankle and walked it off, loudly."));
	} else if (_r < 43) {
		// a shortcut: half an hour gained
		_rd.t += EXPED_HOUR * .5;
		array_push(_tr.log, choose("a shortcut through the hedges. it worked, mostly.", "a cart going their way gave them a lift for a bit.",
			"a dry riverbed ran straight toward " + _to + ". they took it.", "a fence with a hole in it saved half an hour.",
			"a farmer pointed a shorter way. it was shorter.", "the road forked and " + _nm + " guessed. " + _nm + " guessed right.",
			"a ferryman, going anyway, took them across for a song. " + _nm + " sang it.", "a downhill stretch and a good pace and half an hour in hand."));
	} else if (_r < 49) {
		// the road out: half an hour lost
		_rd.t = max(0, _rd.t - EXPED_HOUR * .5);
		array_push(_tr.log, choose("the road was out. the long way round.", "a bog. they went around it. eventually.",
			_nm + " was sure it was this way. it was not this way.", "a fallen tree across the road. it took a while.",
			"a gate, locked, and a wall too high. back to the fork.", "a flock of sheep, the road's width, going the other way, slowly.",
			"a bridge that was more idea than bridge. they went round.", "a farmer's dog with opinions about the road. they waited for the farmer.",
			"a landslip. the road was under it. the new road was over it.", _nm + " stopped to tie a boot. then the other. then the first again."));
	} else if (_r < 58 && _n > 1) {
		// two of them talking: a bond point
		var _a = _tr.sids[_who], _b = _tr.sids[(_who + 1) mod _n];
		exped_bond_add(_a, _b, 1);
		array_push(_tr.log, _nm + " and " + _other + " " + choose("argued about which way is north. the road went on regardless.",
			"walked in step for an hour without noticing.", "shared the last of the bread.", "compared blisters. " + _other + " won.",
			"talked about the ship. both miss it. neither said so.", "sang. it was not good. it was loud.",
			"told each other the same story. it was better the second time, from the other side.", "raced to the next tree. both lost, somehow.",
			"swapped hats for a mile. swapped back. no lessons learned.", "played a game with the milestones. " + _nm + " is winning. the rules are " + _nm + "'s.",
			"agreed about something. nobody remembers what. it felt good.", "walked in silence, the good kind, for an hour."));
	} else if (_r < 67) {
		// a landmark
		array_push(_tr.log, choose("passed a standing stone with a face scratched on it.", "a signpost. it pointed at the sky.",
			"an abandoned cart. someone took the wheels.", "a milestone: " + _to + ", it said, and a number nobody believed.",
			"a shrine the size of a hat, with a hat in it.", "a bridge. under it, a smaller bridge.",
			"a scarecrow. " + _nm + " waved at it.", "a well. " + _nm + " shouted into it. it shouted back, later.",
			"a tree with a door in it. the door was locked.", "a gallows, empty, and a crow on it, full.", "a boundary stone: one side said HERE, the other said THERE.",
			"a mill with no wheel and a wheel with no mill, a field apart.", "an old battlefield, they think. it was very flat and very quiet.",
			"a cairn. " + _nm + " added a stone. it fell off. " + _nm + " added it again."));
	} else if (_r < 74) {
		// an animal
		array_push(_tr.log, choose("a fox watched from the hedge. the fox won the staring contest.", "a bird followed them for an hour. it knows something.",
			"sheep. many sheep. one of them was in charge.", "a frog crossed the road with great dignity.",
			"a dog came along for a mile, then remembered something and left.", "cows looked at them. they looked at the cows.",
			"a hare, going the other way, very fast, about something.", "a hedgehog. " + _nm + " said hello. the hedgehog was a hedgehog about it.",
			"geese. the road was theirs. the crew agreed.", "a heron, standing in a ditch, judging.", "a cat on a wall, in the middle of nowhere, unbothered."));
	} else if (_r < 79) {
		// a sit-down: a little back
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .05);
		array_push(_tr.log, choose("sat under a tree. a good tree.", "stopped to look at the view. there was one.", "boots off. boots on. onward.",
			"a wall at sitting height. it was sat on.", "ten minutes by the road, doing nothing, on purpose.", "lay in the grass and named clouds. one was called steve."));
	} else if (_r < 84) {
		// a road note
		exped_note_beat(_tr, "road", 1);
	} else if (_r < 88) {
		// A FORD: wet through, a little off, a line (the pass)
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = max(1, _tr.hp[_k] - _tr.hpmax[_k] * .03);
		array_push(_tr.log, choose("a ford. the water came up to the knees and then, briefly, the rest.", "forded a river. " + _nm + " went in to the waist and came out to the neck.",
			"a river with no bridge. they crossed it the slow, wet way.", "a ford, and a slippery one. " + _other + " went over. " + _nm + " went in after " + _other + ". both are out."));
	} else if (_r < 92) {
		// A HAWKER: a pie for a credit (when there is one), a little back
		if (_tr.credits > 0) {
			_tr.credits -= 1;
			for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .08);
			array_push(_tr.log, choose("a hawker with a tray. a pie, a credit. the pie was mostly crust. the crust was good.", "a woman selling apples off a cart. a credit for the lot. the lot was four apples.",
				"a boy with a basket of buns. " + _nm + " bought the basket and gave the buns back, keeping one.", "hot chestnuts, off a brazier, off a cart, off a man who had seen everything. a credit."));
		} else array_push(_tr.log, choose("a hawker with pies. the crew had no coin. the hawker had pies. they parted that way.", "a woman selling apples. " + _nm + " looked at the apples for a long time and walked on."));
	} else if (_r < 96) {
		// A STUCK CART: half an hour, a bond point, a thank-you (the pass)
		_rd.t = max(0, _rd.t - EXPED_HOUR * .5);
		if (_n > 1) exped_bond_add(_tr.sids[_who], _tr.sids[(_who + 1) mod _n], 1);
		array_push(_tr.log, choose("a cart in a ditch. they pushed. it came out. the farmer said a word that meant thanks.", "a cart stuck in the mud and an old man stuck in the cart. half an hour and everyone was out.",
			"helped a carter with a wheel. the wheel is on. the cart is upright. the carter is somewhere else now.", "a wagon across the road, axle gone. they carried the load off it, and the driver's thanks with it."));
	} else {
		// A WAYSIDE SHRINE: a little back, a line (the pass)
		for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) _tr.hp[_k] = min(_tr.hpmax[_k], _tr.hp[_k] + _tr.hpmax[_k] * .06);
		array_push(_tr.log, choose("a wayside shrine. someone had left a candle. " + _nm + " left a pebble.", "a little shrine by the road, with a face in it. " + _nm + " nodded to it. it seemed the thing.",
			"a shrine at the crossroads. a coin in the dish, not theirs. they left it and felt better anyway.", "a roadside shrine, mossy. " + _other + " cleared the moss. " + _nm + " put some back."));
	}
}
