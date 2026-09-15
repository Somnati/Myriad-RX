/// @description exped_rout(trip) - the whole crew is down: robbed, and things break
/// His pitch: "sprites dying on an expedition return with nothing but
/// what they have on them, losing some credits / gear - robbed, dropped,
/// damaged". The pocket goes; each member may lose a pocketed item
/// (30%) or have a worn one break (15%). They still come home (a nap).
function exped_rout(_tr) {
	if (_tr[$ "robbed"] ?? false) return;
	_tr.robbed = true;
	if ((_tr[$ "credits"] ?? 0) > 0) { array_push(_tr.log, "robbed while they were down - " + string(_tr.credits) + " credits gone"); _tr.credits = 0; }
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _sh = sprite_sheet(_sp);
		if (array_length(_sh.inv) > 0 && roll_perc(30)) {
			var _at = irandom(array_length(_sh.inv) - 1);
			array_push(_tr.log, _sp.name + " dropped " + _sh.inv[_at].name + " somewhere back there");
			array_delete(_sh.inv, _at, 1);
		}
		if (roll_perc(15)) {
			var _slots = [];
			if (!is_undefined(_sh.w1)) array_push(_slots, "w1");
			if (!is_undefined(_sh.w2)) array_push(_slots, "w2");
			if (array_length(_sh.armor) > 0) array_push(_slots, "armor");
			if (array_length(_sh.talis) > 0) array_push(_slots, "talis");
			if (array_length(_slots) > 0) {
				var _s = _slots[irandom(array_length(_slots) - 1)];
				var _nm = "";
				if (_s == "w1") { _nm = _sh.w1.name; _sh.w1 = undefined; }
				else if (_s == "w2") { _nm = _sh.w2.name; _sh.w2 = undefined; }
				else { var _arr = _sh[$ _s]; _nm = _arr[0].name; array_delete(_arr, 0, 1); }
				array_push(_tr.log, _sp.name + "'s " + _nm + " did not survive it");
			}
		}
	}
	save_mark_dirty();
}
