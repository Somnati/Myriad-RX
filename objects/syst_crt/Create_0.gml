/// syst_crt - THE TUBE, everywhere (his ask, 2026-09-10: "i like the
/// CRT effect but am curious if we can use it and keep the vanilla
/// brightness of all our pixels. also can you put it in front of
/// everything... add some settings... a setting to draw it behind UI
/// elements like it is now so i can have it only effect the
/// visualizer"). Born as the title screen's own pass (syst_titlescreen
/// at depth 20); now one persistent instance that lives in every room
/// and runs sh_crt over whatever has drawn by the time its depth comes
/// round - read the shader's header for what the tube does and why it
/// no longer dims anything.
///
/// TWO SEATS (settings > crt "over the interface"):
///   over    depth CRT_OVER, just under the pointer (-20000): the
///           header, the menus, the drawers, the overlays and the room
///           are all on the glass; the pointer alone stays a pointer
///   behind  depth CRT_BEHIND: only what draws DEEPER than 5 is on the
///           tube - in the money room the visualiser, its glow pass,
///           the dice and the puck; on the title the field, the halo
///           and the gradient. Everything at 0 or above (the dial
///           column at -20, the tile table, every readout, the header)
///           draws after, crisp - "only the visualiser"
///
/// WHERE (settings > crt "crt"): off / the title screen only / every
/// room. The room transition draws in Draw End, after everything, so
/// the wipe is never on the tube.
///
/// PERSISTENT, made once by setgame after the pointer. Free-standing:
/// nothing else reads it.

#macro CRT_OVER   -19000
#macro CRT_BEHIND      5

depth = CRT_OVER;
persistent = true;

scratch = -1;   // the frame's copy (the surface can't sample itself)
t = 0;          // the tube's own clock, seconds

/// is the pass on in this room?
__on = function() {
	var _m = variable_global_exists("crt_mode") ? g.crt_mode : 0;
	if (_m == 2) return true;
	if (_m == 1) return in_room(rm_titlescreen);
	return false;
};

/// the seat this frame
__seat = function() {
	return (variable_global_exists("crt_over_ui") && !g.crt_over_ui) ? CRT_BEHIND : CRT_OVER;
};
