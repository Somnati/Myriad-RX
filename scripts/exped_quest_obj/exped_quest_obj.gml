/// @description exped_quest_obj(quest, region, long) -> what the crew will do, in words: short for the card, long for the preparation page
function exped_quest_obj(_q, _rg, _long) {
	static _pl = function(_f) { return foe_plural(_f); };
	var _nn = array_length(_rg.nodes);
	var _nd = _rg.nodes[clamp(_q.node, 0, _nn - 1)];
	var _fd = _rg.nodes[clamp((_q[$ "from"] ?? -1) >= 0 ? _q.from : _q.node, 0, _nn - 1)];
	var _who = _q[$ "who"] ?? "";
	switch (_q.kind) {
		case "slay":   return _long ? ("hunt " + _pl(_q.foe) + " at " + _nd.name + " (" + _nd.kind + "), " + string(_q.n) + " of them; the crew comes home when the count is met") : ("slay " + string(_q.n) + " " + _pl(_q.foe));
		case "clear":  return _long ? ("go room by room through " + _nd.name + ", " + string(_q.n) + " rooms - fights, finds, traps") : ("clear it, room by room (" + string(_q.n) + ")");
		case "rout":   return _long ? ("walk into the camp at " + _nd.name + " and win two fights against its bandits") : "rout the bandits: two fights, then their chest";
		case "scout":  return _long ? ("get to " + _nd.name + " and come back with a look at it") : "have a look around, come back";
		case "escort": return _long ? ("meet " + _who + " at " + _fd.name + " and walk them by the roads to " + _nd.name + "; bandits like a cart on the road") : ("walk " + _who + " to " + _nd.name);
		case "fetch":  return _long ? ("go to " + _fd.name + " for " + _who + " and carry it to " + _nd.name + "; something may be sitting on it") : ("fetch " + _who + ", bring it to " + _nd.name);
		case "rescue": return _long ? ("search " + _fd.name + " room by room for " + _who + " and bring them back to " + _nd.name) : ("find " + _who + " here, bring them to " + _nd.name);
		case "bounty": return _long ? (_who + " was seen at " + _nd.name + ". bring it down - one big fight; the bounty is paid at home") : ("bring down " + _who);
		case "defend": return _long ? ("stand at " + _nd.name + " and hold it against " + string(_q.n) + " waves of " + _pl(_q.foe) + "; the villagers patch you up between") : (string(_q.n) + " waves of " + _pl(_q.foe) + " to hold off");
		case "survey": return _long ? ("walk to each place and chart it - nothing to fight but the road; " + string(_q.n) + " places") : ("chart " + string(_q.n) + " places, this one first");
		case "gather": return _long ? ("work the mine at " + _nd.name + " for " + string(_q.n) + " sacks of " + _who + "; a few hours of digging") : (string(_q.n) + " sacks of " + _who + " from the mine");
	}
	return _q.txt;
}
