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
	// EVERY GAME ROOM (his call, and DE's shape - DE parks obj_clicker
	// on rm_load_ui, the persistent HUD layer, so the thumb earns
	// wherever you are). It was narrowed to the money room on
	// 2026-09-06 and widened again here.
	//
	// The one thing to know about the wide version: RX's menus are
	// ROOMS where DE's are overlays, so DE's taps were held off by
	// g.input_block and ours are not - a tap on a screen's own furniture
	// will work the control AND pay for the tap. Everything the region
	// pattern already blocks still blocks (the menu drawer, popups, any
	// clickable widget, and the dial drawer's own bars via __consumes);
	// what is missing is a __consumes for the settings / statistics /
	// saves / upgrades tables. That is the fix if the double action
	// grates - one method per screen, the shape syst_dials already has.
	return !in_room(rm_titlescreen) && !in_room(rm_gameload)
		&& !in_room(rm_quit);
};

pop = 0;  // a little press feedback the room can read

// ---- THE HOLD (Myriad DE's click_v2 accumulator) ----
tap_acc = 0;      // fractional taps banked by the current hold. The whole
                  // part is paid and subtracted every frame it reaches 1,
                  // which is what makes a rate past 60 exact - see tap_fire.
                  // A press SEEDS IT AT -1 - see the Step.
hold_on = false;  // did THIS press land somewhere that pays?
fx_tic  = 0;      // the ceremony clock, so floats stay readable at rate
tap_press = false;// the pending payout came from a PRESS, so it always
                  // performs and always sounds - see the Step

// ---- THE RATE READOUT (DE's obj_tps + obj_draw_clickgps) ----
tap_log = [];     // remaining life of each MANUAL tap, in delta units
tps     = 0;      // the eased, shown rate
tps_a   = 0;      // its fade
// DE's obj_draw_clickgps state, ported with the readout (2026-09-09).
// It SLIDES to its seat rather than appearing at it (DE trickles y to
// desy), and the crunched string is rebuilt only when the whole number
// changes - crunch_arb on a rate that moves every frame is a string
// built 60 times a second to say the same thing.
tps_y   = 99999;  // seeded off-screen; the Draw clamps it to the live
                  // room's bottom edge on frame one. A plain literal:
                  // GML will not parse 1e9 (validator check)
tps_sm  = 0;      // the SMOOTHED rate the readout shows (DE's __tps)
tps_i   = -1;     // last whole rate the string was built from
tps_txt = "0";    // ...and the string itself

// THE OVERCHARGER rides with the tap surface: one persistent instance,
// spawned here because this Create runs exactly once, at boot
if (!instance_exists(obj_overcharge)) create_obj(0, 0, obj_overcharge);

