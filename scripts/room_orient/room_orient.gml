/// @description room_orient() - which SHAPE the game is playing in
/// right now: 0 portrait, 1 landscape. The one answer; every resolver
/// asks this rather than looking at the display itself.
///
/// g.orient is the player's setting (settings > display "orientation"):
///   -1  AUTO - follow the device. A phone is held in portrait, a
///       desktop sits in landscape, so that is the split.
///    0  forced portrait
///    1  forced landscape
/// Kept as a SETTING, not a fact about the window, on purpose: he asked
/// to be able to force it either way regardless of what he is playing
/// on, and a forced choice must survive a window resize.
function room_orient() {
	var _o = variable_global_exists("orient") ? g.orient : -1;
	if (_o == 0) return 0;
	if (_o == 1) return 1;
	// AUTO: mobile is portrait, everything else landscape
	if (os_type == os_android || os_type == os_ios) return 0;
	return 1;
}
