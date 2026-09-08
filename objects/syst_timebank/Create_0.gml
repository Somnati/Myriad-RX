/// syst_timebank - the time bank's COCKPIT CHIP. The one thing about
/// this mechanic you must not be able to forget: while a multiplier is
/// running it is quietly burning a resource you paid for. So a small
/// gold pulsing chip sits under the header - "x4 - 1h 23m", the speed
/// and what is left - and tapping it opens rm_timebank.
///
/// It draws NOTHING at x1. The cockpit stays clean, and the chip
/// appearing is itself the notification. When the bank empties,
/// timebank_spend drops to x1 and the chip removes itself.
///
/// PERSISTENT and spawned once (syst_handle_save's Create), like the
/// credit panel - so no room has to remember to place it. It shows only
/// in the money room: a burn indicator over the settings screen is an
/// alarm you cannot act on.

depth = -300;
timebank_init();

/// showing? A multiplier has to be running, and we have to be in the
/// money room - the chip is an indicator you act on by tapping, and
/// there is nothing to act on from a settings page.
__live = function() {
	if (!variable_global_exists("timebank")) return false;
	if (g.timebank.spd <= 1) return false;
	return in_room(rm_clicker);
};

cw  = 76;
cx0 = (room_width - cw) * .5;
cy0 = 19;
ch  = 12;
