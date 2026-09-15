/// @description exped_npc_name() -> a sprite-style name for someone met on the road
function exped_npc_name() {
	var _c = ["b", "m", "p", "n", "l", "d", "z", "k", "w", "t", "f", "j"];
	var _v = ["a", "i", "o", "u", "e", "oo", "ee"];
	var _s1 = _c[irandom(11)] + _v[irandom(6)];
	var _nm = (random(1) < .35) ? (_s1 + _s1) : (_s1 + _c[irandom(11)] + _v[irandom(6)]);
	if (random(1) < .25) _nm += choose("t", "n", "p", "k");
	return _nm;
}
