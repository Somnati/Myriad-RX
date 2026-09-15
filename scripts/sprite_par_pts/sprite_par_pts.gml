/// @description sprite_par_pts(lv) -> the stat total of a PAR creature
/// at that level: the 40-point base plus SPRITE_LV_PTS a level (no
/// gear). His xp law's unit - a level is SPRITE_LV_KILLS of these.
function sprite_par_pts(_lv) {
	return 40 + SPRITE_LV_PTS * (max(1, _lv) - 1);
}
