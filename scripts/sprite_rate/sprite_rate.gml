/// @description sprite_rate(s) - the taps per second one sprite averages:
/// work x pace / SPRITE_TAP_T. THE one number every executor derives
/// from - obj_blob's live loop, sprites_tick headless, sprites_offline.
/// @param s
function sprite_rate(_s) {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(_s.pers, 0, array_length(_pl) - 1)];
	return _p.work * _p.pace / SPRITE_TAP_T;
}
