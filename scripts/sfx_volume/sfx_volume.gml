/// @description sfx_volume(kind) - the player's mix level for this kind
/// of sound, 0..1 (his ask: separate faders for taps and dials).
/// Kinds without a fader of their own ride the one they belong to: a
/// critical IS a tap, so it moves with the tap fader rather than needing
/// a third control nobody asked for and everybody has to think about.
function sfx_volume(_kind) {
	if (_kind == "dial")
		return (variable_global_exists("vol_dial") ? g.vol_dial : 100) / 100;
	return (variable_global_exists("vol_tap") ? g.vol_tap : 100) / 100;
}
