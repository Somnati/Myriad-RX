/// @description exped_room_trap(trip, prefix) - a trap bites one of the crew (8% + 4% a tier of their pool)
function exped_room_trap(_tr, _pre) {
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	if (array_length(_up) == 0) return;
	var _who = _up[irandom(array_length(_up) - 1)];
	var _dmg = max(1, round(_tr.hpmax[_who] * (.08 + .04 * _tr.dest.tier)));
	_tr.hp[_who] = max(0, _tr.hp[_who] - _dmg);
	array_push(_tr.log, _pre + "a trap - " + ((array_length(_tr.names) > 1) ? (_tr.names[_who] + " ") : "") + "-" + string(_dmg) + " hp");
	if (exped_alive(_tr) <= 0) { _tr.routed = true; array_push(_tr.log, exped_crew_txt(_tr.names) + ((array_length(_tr.names) > 1) ? " are down" : " is down")); }
	exped_say(_tr, "trap", undefined, .7);
}
