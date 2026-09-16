/// @description exped_compose(kind, trip) -> a diary line built from slots, not picked from a list
/// COMPOSITION OVER POOLS (his pick, 2026-09-16: "pools will repeat... more
/// composition"): a line is a SUBJECT, a PREDICATE and a TAIL drawn from
/// separate pools, so twenty entries in each make thousands of lines and
/// the same one comes round rarely. Past tense throughout, so any subject
/// fits any predicate; the tails are deadpan enough to follow anything.
///   linger    a distraction in a settled place (the town plan's beat)
///   road      a landmark or a small thing on the road (exped_road_beat)
///   wild      a crossing of the open land (the "wild" activity)
///   rumour    the tavern's talk: an [article adjective noun] that [does]
///   camp      an evening at a fire (spare: for the beats that want one)
function exped_compose(_kind, _tr) {
	var _n = array_length(_tr.sids);
	var _up = [];
	for (var _k = 0; _k < _n; _k++) if (_tr.hp[_k] > 0) array_push(_up, _tr.names[_k]);
	if (array_length(_up) == 0) _up = [ _tr.names[0] ];
	var _nm = _up[irandom(array_length(_up) - 1)];
	var _nm2 = _nm;
	if (array_length(_up) > 1) { repeat (6) { _nm2 = _up[irandom(array_length(_up) - 1)]; if (_nm2 != _nm) break; } }
	var _rg = exped_region(_tr);
	var _nd = _rg.nodes[clamp(_tr.pos, 0, array_length(_rg.nodes) - 1)];
	var _here = _nd.name;
	// the tails: any of these can follow any predicate
	var _tails = ["", "", "", ". nobody minded", " for the better part of an hour", " and regretted it", " and denies it", ". it took an hour",
	              " and said nothing about it", ". the others waited", ", which helped", ", which did not help", ". then the rain", ". " + _nm2 + " laughed",
	              " and that was the afternoon", ". it is written down somewhere", " and was not sorry", ". twice", " and would do it again", ". a good hour"];
	var _tail = _tails[irandom(array_length(_tails) - 1)];
	switch (_kind) {
		case "linger": {
			var _subj = choose(_nm, _nm, _nm, _nm2, "the crew", "somebody", "half of them");
			var _pred = choose("watched a dog steal a sausage", "argued with a fence-post", "bought a pie that was mostly gravy", "fed the geese",
				"got a haircut", "asked directions", "sat by the well", "watched the smith work", "followed a wedding down the street", "counted the chimneys",
				"tried the local beer", "got talked at about the weather of years ago", "got lost in the lanes", "read the notices on the church door",
				"haggled over an onion", "petted a horse that was not for petting", "watched a fight that was not a fight", "found the graveyard and read the stones",
				"was taken for somebody's cousin", "helped push a cart out of a rut", "listened to an argument about a fence", "bought a hat and lost it",
				"stood in a queue for nothing", "won a goose and gave it back", "learned three words of the local dialect, all rude", "sat in the church for the quiet",
				"watched the river do what it does", "was sold a map of somewhere else");
			return _subj + " " + _pred + _tail;
		}
		case "road": {
			var _subj = choose(_nm, _nm, "the crew", "everyone", _nm2);
			var _pred = choose("passed a cart going the other way", "stopped for a stone in a boot", "saw a hawk take something", "found a milestone with the wrong name on it",
				"shared the road with a goat for a mile", "was overtaken by a boy on a mule", "counted crows", "argued about the way", "sang, briefly",
				"passed a standing stone with a face scratched on it", "found a signpost pointing at the sky", "waved at a scarecrow", "shouted into a well",
				"passed a tree with a door in it", "walked under a gallows with a crow on it", "added a stone to a cairn", "met a tinker with nothing to sell",
				"passed a field of something nobody could name", "stepped over a snake that was a stick", "found a coin that was a button", "crossed a bridge with a smaller bridge under it",
				"sat on a milestone", "passed a cart with a bed in it and a man asleep in the bed", "skirted a bog that had an opinion");
			return _subj + " " + _pred + _tail;
		}
		case "wild": {
			var _kd = region_kinds()[$ _nd.kind];
			var _what = is_struct(_kd) ? _kd.name : "the land";
			var _subj = choose("the crew", _nm, "everyone", _nm2);
			var _pred = choose("crossed " + _here + " without a word", "looked at " + _here + " and " + _here + " looked back", "walked through " + _here + ". nothing in it",
				"found a good stone to sit on in " + _here + " and sat", "was rained on in " + _here, "lost the path in " + _here + " and found it again",
				"counted the birds over " + _here, "took the long way round " + _here, "walked " + _here + " in the wind", "picked something in " + _here + " and dropped it",
				"named a hill in " + _here + " after " + _nm2, "skirted the " + _what + " where it was worst", "watched the light change over " + _here);
			return _subj + " " + _pred + _tail;
		}
		case "rumour": {
			var _adj = choose("red", "stone", "quiet", "old", "singing", "borrowed", "blind", "second", "hollow", "wet", "tall", "left-handed", "salt", "black", "polite");
			var _noun = choose("rock", "bell", "mule", "widow", "well", "ferryman", "goose", "miller", "door", "hat", "king", "road", "child", "dog", "boat");
			var _does = choose("watches", "walks at night", "owes money", "has been seen twice", "is not from here", "knows a song", "counts the dead", "will not cross water",
				"was here before the town", "answers if you knock", "eats the lamps", "is buried under the green", "moved the river", "married the wrong one", "keeps the winter in a jar");
			var _art = (string_pos(string_char_at(_adj, 1), "aeiou") > 0) ? "an " : "a ";
			return "the tavern at " + _here + ": " + choose("talk of", "a story about", "an argument over", "a song about", "a bet on", "a warning about") + " " + _art + _adj + " " + _noun + " that " + _does;
		}
		case "parcel": {
			// the parcel in tow (the parcel quest): the thing itself is the subject
			var _pq = _tr[$ "quest"];
			var _subj = (is_struct(_pq) && (_pq[$ "who"] ?? "") != "") ? _pq.who : "the parcel";
			var _pred = choose("got heavier", "made a noise", "was looked at by a crow", "needed carrying differently", "leaked a little", "was almost left on a wall",
				"asked, in its way, to be put down", "drew comment from a farmer", "changed hands three times in a mile", "was warmer than before", "went quiet, which was worse",
				"was set down at a ford and nearly went with the river", "was sniffed by a dog and the dog left", "was weighed by " + _nm + ", by feel, and found wanting", "was talked to by " + _nm2);
			return _subj + " " + _pred + _tail;
		}
		case "camp": {
			var _subj = choose(_nm, _nm2, "the crew");
			var _pred = choose("kept the fire", "told a story everyone had heard", "burned the supper", "watched the dark", "mended a strap by firelight", "slept first",
				"took the last watch", "sang the one song", "counted the stars and lost count", "heard something and said nothing");
			return _subj + " " + _pred + _tail;
		}
	}
	return "";
}
