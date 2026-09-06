/// obj_clicker - THE TAP (Myriad DE's obj_clicker + click_v2 +
/// give_click, rebuilt). Owns nothing but the tap surface: what a tap
/// is WORTH is update_click's business, and where the profit goes is
/// give_profit's. This object only decides that a tap happened.
/// DE reads five simultaneous touch devices here; RX starts with the
/// single pointer and grows into that when a device needs it.
/// PERSISTENT, and live in every GAME room (his ask, and DE's shape -
/// DE keeps obj_clicker on rm_load_ui, the persistent HUD layer, so
/// the thumb earns wherever you are). The title screen, the boot room
/// and the quit room are excluded, and nothing earns before a run has
/// actually started.

depth = 0; // input only - this object draws nothing, but keep it
           // above the room's Background layer (100) on principle

// the live tap surface: everything under the header. The dial drawer
// claims only its bars and buttons (syst_dials.__consumes, see Step),
// so taps keep paying with the drawer open - region law, his rule.
tap_y0 = 16;
tap_y1 = room_height;

/// is tapping live right now? A run has to have started, and the
/// non-game rooms are off limits.
__live = function() {
	if (!variable_global_exists("game_started") || !g.game_started) return false;
	// THE MONEY ROOM ONLY (his call 2026-09-06). It used to be live
	// everywhere but the title / boot / quit rooms, so a tap while
	// reading the statistics paid profit and threw bezier motes across
	// the screen. in_room is orientation-aware, so this covers both
	// shapes of the clicker.
	return in_room(rm_clicker);
};

pop = 0;  // a little press feedback the room can read

