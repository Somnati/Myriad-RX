/// @description cheat_set(i, value) -> did the row move? THE ONE
/// mutation site. Snaps to CHEAT_STEP, holds CHEAT_ROW_MIN..MAX, and a
/// raise may only take what the free pool has (Disgaea's rule: lower
/// one thing to raise another). Applies and marks the save on a change.
function cheat_set(_i, _val) {
	cheat_init();
	var _v = g.cheat.v;
	if (_i < 0 || _i >= array_length(_v)) return false;
	var _cur = _v[_i];
	_val = clamp(round(_val / CHEAT_STEP) * CHEAT_STEP, CHEAT_ROW_MIN, CHEAT_ROW_MAX);
	if (_val > _cur) {
		var _room = floor(max(0, cheat_free()) / CHEAT_STEP) * CHEAT_STEP;
		_val = min(_val, _cur + _room);
	}
	if (_val == _cur) return false;
	_v[_i] = _val;
	cheat_apply();
	save_mark_dirty();
	return true;
}
