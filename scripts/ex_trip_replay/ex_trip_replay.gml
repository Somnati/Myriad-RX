/// @description ex_trip_replay() - THE REPLAY: a trip page with an unseen film (and no live fight) plays it (syst_exped_panel's Step, q220; self = the panel)
function ex_trip_replay() {
	var _tvr = __trip();
	if (!is_undefined(_tvr)) {
		var _rr = _tvr[$ "replay"];
		// a fight watched LIVE on this page is not replayed after
		if (!is_undefined(_tvr.fight)) seen_live = string(_tvr.id) + ":" + string(_tvr[$ "fights"] ?? 0);
		if (!is_undefined(_rr) && !_rr.seen && seen_live == string(_tvr.id) + ":" + string(_rr.room)) _rr.seen = true;
		if (is_undefined(rp) && !is_undefined(_rr) && !_rr.seen && is_undefined(_tvr.fight) && array_length(_rr.ev) > 0)
			rp = { i : 0, t : 0, r : _rr, id : _tvr.id };
		if (!is_undefined(rp)) {
			if (rp.id != _tvr.id || !is_undefined(_tvr.fight)) rp = undefined;
			else {
				rp.t += delta / 60;
				var _step = (rp.i < array_length(rp.r.ev) - 1) ? .5 : 1.6;
				if (rp.t >= _step) {
					rp.t = 0;
					if (rp.i < array_length(rp.r.ev) - 1) rp.i += 1;
					else { rp.r.seen = true; rp = undefined; }
				}
			}
		}
	} else rp = undefined;
}
