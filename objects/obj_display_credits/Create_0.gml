/// obj_display_credits - THE CREDIT PANEL (Myriad DE's
/// obj_display_credits, rebuilt). A small strip that SLIDES IN FROM
/// THE LEFT EDGE at y 46: the credit icon, the balance in lavender,
/// and a "+N" while a drop is fresh. Display only - it never takes a
/// tap (DE's neither). Persistent; spawned once by syst_handle_save's
/// Create so it exists in every room, and shows itself only in game
/// rooms with a run started.
/// WHEN IT SHOWS (DE's rules): three seconds after every drop, re-armed
/// by each one; while the menu is open; and always in the money room
/// when "always show popups" is on (g.persist_popups, DE's setting,
/// off by default). It goes AWAY while the dial drawer is out and under
/// the rebirth overlay.
/// DE's DRAW, kept: a pixel strip tw x 11 at alpha .8 shaded black
/// into lavender by the glow, spr_display_units frame 1 as the right
/// end-cap, text at +13/+1, spr_particon at +5/+4.

depth = -600;
x = 0;
ystart = 46;
y = ystart;

hp_  = 3;     // seconds the panel stays out after a drop
hp   = 0;
move = 0;     // 0 tucked away .. 1 fully out (eased)
x_   = 0;     // the slide offset, derived from move
glow = 0;

shown = 0;    // the balance as drawn (glides to the real one)
tw    = 30;   // panel width, text-dependent
text  = "0";

add_val = 0;  // the "+N" tail
add_hp  = 0;

// where motes land: the icon's centre when the panel is fully out
seat_x = 8;
seat_y = ystart + 4;

/// a drop landed: show the panel, flash it, grow the "+N"
__pop = function(_n) {
	hp   = hp_;
	glow = 1;
	add_val += _n;
	add_hp = hp_;
};
