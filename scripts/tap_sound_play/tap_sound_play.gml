/// @description tap_sound_play([vol_mult]);
/// @param [vol_mult]
/// Play the tap sound the player chose. THE ONE SITE - obj_clicker calls
/// this and nothing else knows which sound is selected, so swapping the
/// roster or the setting reaches every tap at once.
/// A tap is the most repeated sound in the game, which is exactly why
/// each entry carries its own pitch range: the same sample fired at the
/// same pitch forty times in a row stops being a sound and becomes a
/// buzz.
function tap_sound_play(_vm = 1) {
	var _c = tap_sound_config();
	var _i = clamp(floor(g.tap_sound), 0, array_length(_c) - 1);
	var _e = _c[_i];
	play_sound_ext(_e.snd, _e.pmn, _e.pmx, _e.vol * _vm, 1);
}
