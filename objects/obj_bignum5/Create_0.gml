/// obj_bignum5 - THE BIG NUMBER VISUALISER: your profit rendered as a
/// nested grid of coloured blocks, one order of magnitude per nesting
/// level, with an endless zoom in both directions.
/// Ported from Myriad DE 2026-08-14, where it arrived from Techdemo II
/// and was tuned there for the 144-wide portrait room - so this is the
/// newest of the family and the one DE's own clicker prefers.
/// DISPLAY ONLY: it reads g.profit and owns no game logic.

// the assembling square centers on x/y; vertical anchor matches the old
// cube vis (obj_bignum2's yos = room_height/3)
x = room_width * 0.5;
y = room_height / 3;

depth = 50; // BEHIND the dial column (-20) and the header (-1000) but
            // IN FRONT of rm_clicker's opaque Background layer (100).
            // DE can park this at 2000 because its clicker room has no
            // black fill layer; ours does, and LOWER DEPTH DRAWS ON TOP
            // - at 2000 the background simply painted over it.

salpha = 0; // the entrance fade

// continuous swipe-zoom state (see Step)
swipe_oy = -1;      // press-origin y (-1 = no press)
swipe_py = 0;       // last frame's y
swipe_on = false;   // engaged once travel beats the drag budget
swipe_sens = 0.02;  // OOMs per px: ~60px swipe = 1.2 OOM

vis = bignum_visualizer_create();
vis.renderer.grid_sprite = spr_vis_grid2; // 3 subimages: border/inner/outer
// the grid's master opacity, his setting (settings > display). The
// renderer's own default is .75, which is what 75 here reproduces.
vis.renderer.grid_alpha = (variable_global_exists("vis_grid_alpha")
	? g.vis_grid_alpha : 75) / 100;

// NO SUB-TIER SQUARES (his report). DigitWindow can SYNTHESISE digits
// below the value's real precision so a deep zoom always has something
// to draw - which shows up as squares smaller than the lowest (white)
// tier, representing decimals the number does not actually have.
// The tier-1 squares ARE the unit; nothing is smaller than one.
vis.display_win.fake_digits = false;

// framing for the 144-wide portrait room (techdemo tuned 480-wide):
// base_unit scales everything; start_scale = px per unit of the lowest
// field at rest -> 1px units, a 100px field, fits with margin
vis.renderer.base_unit = 2.0;
vis.set_start_scale(1.0);

// tier colors through MYRIAD's palette: tiers are per digit pair (one
// per square size) so the OOM halves, +1 lands units on tier 1 (white)
// like the old vis glow. the sat doubling is the old vis's
// make_colour_hsv pass, kept host-side on purpose.
vis.renderer.set_tier_color_callback(function(_oom) {
	var _c = vis_tier_color(max((_oom div 2) + 1, 0));
	return make_colour_hsv(
		colour_get_hue(_c),
		clamp(colour_get_saturation(_c) * 2, 0, 255),
		colour_get_value(_c)
	);
});

// block labels through the house crunch ladder: a block is
// count x 10^tier - pack that magnitude as an arb via its log10 and let
// crunch_arb speak, instead of the renderer's raw "Ne M" fallback
vis.renderer.set_label_callback(function(_tier_mag, _count) {
	return crunch_arb(port_log_to_arb(_tier_mag + log10(max(1, _count))));
});

// THE GLOW IS PARKED (his report: the circular banding was never in
// the original). DE's obj_bignum5 puts an additive spr_glow_sw pass
// behind the blocks; a wide, dark, additive gradient is precisely what
// BANDS on an 8-bit surface - the house lore - so it read as a ringed
// halo rather than as light. The techdemo's own obj_bignum had already
// parked its glow for the same reason.
// Bringing it back needs a DITHERED pass, not a raw sprite stretch:
//   vis.glow_sprite = spr_glow_sw;
//   vis.glow_size = 90; vis.glow_alpha = .35; vis.glow_pulse = 1;

// entry glide: seed the camera 0.6 OOM out so entry is a glide IN to
// native zoom. feed the focus once now - Step re-feeds it every frame.
vis.set_focus_value(instance_exists(obj_ui_header)
	? obj_ui_header.prof_shown : g.profit);
vis.lod.wm = max(vis.lod.wm_min, vis.focus_mag - vis.lod.band_anchor) + 0.6;
