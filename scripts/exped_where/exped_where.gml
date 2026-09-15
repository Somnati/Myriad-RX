/// @description exped_where(trip) -> a line: where the crew is and what it is doing
function exped_where(_tr) {
	if (_tr.stage == 0) return "flying to " + _tr.dest.name;
	if (_tr.stage == 2) return _tr.routed ? "limping home" : "flying home";
	var _rg = exped_region(_tr);
	var _here = _rg.nodes[clamp(_tr.pos, 0, array_length(_rg.nodes) - 1)].name;
	if (!is_undefined(_tr.fight)) return "fighting at " + _here;
	if (is_struct(_tr.act)) {
		var _a = _tr.act;
		switch (_a.kind) {
			case "rest":   return "resting at " + _here;
			case "shop":   return "shopping at " + _here;
			case "tavern": return "in the tavern at " + _here;
			case "hunt":   return "hunting at " + _here;
			case "delve":  return "delving " + _here + " - " + string(_a.steps) + ((_a.steps == 1) ? " room" : " rooms") + " to go";
			case "camp":   return "raiding " + _here;
			case "mine":   return "mining at " + _here;
			case "shrine": return "at the shrine";
			case "ruin":   return "poking around " + _here;
			case "wild":   return "crossing " + _here;
			case "look":   return "having a look at " + _here;
		}
		return "busy at " + _here;
	}
	if (is_struct(_tr.road)) {
		var _to = _rg.nodes[_tr.road.b].name;
		var _left = max(0, _tr.road.d * EXPED_HOUR - _tr.road.t) / EXPED_HOUR;
		return "on the road to " + _to + "  -  " + string_format(_left, 1, 1) + "h";
	}
	return "at " + _here;
}
