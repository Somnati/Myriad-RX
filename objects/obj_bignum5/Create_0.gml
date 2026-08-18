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

depth = 2000; // GM CULLS draws outside depth -16000..16000 - the family's
              // 10000000 never drew directly (obj_bignum2 only shows via
              // obj_surface_vis's event_perform capture at depth 1000).
              // 2000 = deeper than every rm_clicker layer (max 150) and
              // than obj_surface_vis, still inside the drawable range.

salpha = 0; // fade-in once the tutorial clears (the family's entrance)

// continuous swipe-zoom state (see Step)
swipe_oy = -1;      // press-origin y (-1 = no press)
swipe_py = 0;       // last frame's y
swipe_on = false;   // engaged once travel beats the drag budget
swipe_sens = 0.02;  // OOMs per px: ~60px swipe = 1.2 OOM

vis = bignum_visualizer_create();
vis.renderer.grid_sprite = spr_vis_grid2; // 3 subimages: border/inner/outer

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

// additive glow: the old spr_glow_sw pass. glow_pulse 1 + alpha .35
// replicates the shipped sawtooth (.35 * frac(gold/2)) exactly.
// spr_glow_sw is 144x144 origin-centered - the contract the glow needs.
vis.glow_sprite = spr_glow_sw;
vis.glow_size = 90; // px diameter; ~0.63 of room width like the techdemo tuning
vis.glow_alpha = 0.35;
vis.glow_pulse = 1;

// entry glide: seed the camera 0.6 OOM out so entry is a glide IN to
// native zoom. feed the focus once now - Step re-feeds it every frame.
vis.set_focus_value(g.profit);
vis.lod.wm = max(vis.lod.wm_min, vis.focus_mag - vis.lod.band_anchor) + 0.6;
