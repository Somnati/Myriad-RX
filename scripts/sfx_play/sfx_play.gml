/// @description sfx_play(kind, [vol_mult]) - play the sound the player
/// chose for `kind`. THE ONE SITE: nothing else knows which sound is
/// selected, so swapping a roster or a setting reaches every caller at
/// once.
///
/// Volume is three multiplications and each earns its place:
///   the ROW's own vol   calibrates the samples against each other, so
///                       changing sound does not change loudness
///   the KIND's fader    the player's mix between taps and dials - one
///                       is a thing they are DOING and the other is a
///                       thing that HAPPENS, and those want different
///                       levels (sfx_volume)
///   g.vol_sfx           applied inside play_sound_ext; master and mute
///                       ride the audio bus above that
///
/// The guard is on the ASSET rather than on the volume because a roster
/// row is allowed to be silent by choice: "off" rows carry snd -1.
function sfx_play(_kind, _vm = 1) {
	var _l = sfx_config(_kind);
	if (array_length(_l) == 0) return;
	var _e = _l[sfx_index(_kind)];
	if (_e.snd == -1) return;
	play_sound_ext(_e.snd, _e.pmn, _e.pmx, _e.vol * _vm * sfx_volume(_kind), 1);
}
