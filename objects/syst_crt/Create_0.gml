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
///   over    depth CRT_OVER, under the pointer (-20000) and over
///           everything else (the deepest interface is syst_unfold at
///           -1500): the header, the menus, the drawers, the overlays
///           and the room are all on the glass; the pointer alone
///           stays a pointer. -15000 rather than -19000: GameMaker
///           documents its drawable depth range as -16000..16000, and
///           the first seat outside it went black on him (2026-09-10)
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

#macro CRT_OVER   -15000
#macro CRT_BEHIND      5

depth = CRT_OVER;
persistent = true;

// the shader's second texture: the frame blurred wide, for the bloom
u_blur_s = shader_get_sampler_index(sh_crt, "u_blur");

// ---- THE BLOOM CHAIN ----
// ⚖️ ITS OWN CHAIN, IN 16-BIT FLOAT (his report, 2026-09-10: "the bloom
// feels low res and doesnt fall off well... 8bit limit?"). Yes: the
// house blur chain is 8-bit, and a halo's tail is a handful of levels
// that a strength of .15 rounds to nothing - the glow stopped dead
// where it should have faded. And blur_snap's up-pass REPLACES each
// level with the coarsest one upscaled - one blur width, a tent - so
// the shape had no tail to begin with. This chain:
//   bright   the frame at half size, squared by a multiply draw (no
//            shader): the bright things spill, the dark field doesn't
//   down     five halvings, bilinear - each level is a wider blur
//   up       each level gets the coarser one ADDED (bm_add), so the
//            result is the SUM of five widths: a bright core, a long
//            soft tail - the sum-of-gaussians shape every real bloom
//            uses
// in surface_rgba16float where the GPU has it (every desktop one
// does; the 8-bit fallback keeps the sum shape at least).
bloom_fmt = surface_format_is_supported(surface_rgba16float)
	? surface_rgba16float : surface_rgba8unorm;
bloom_ch  = [];   // the levels, half size down to a thirty-second
bloom_key = "";
#macro CRT_BLOOM_STEPS 5

/// (re)build the chain for a bright pass of _w x _h
__bloom_chain = function(_w, _h) {
	var _key = string(_w) + "x" + string(_h);
	var _ok = (bloom_key == _key) && (array_length(bloom_ch) == CRT_BLOOM_STEPS);
	if (_ok) for (var _i = 0; _i < CRT_BLOOM_STEPS; _i++)
		if (!surface_exists(bloom_ch[_i])) { _ok = false; break; }
	if (_ok) return true;
	for (var _i = 0; _i < array_length(bloom_ch); _i++)
		if (surface_exists(bloom_ch[_i])) surface_free(bloom_ch[_i]);
	bloom_ch = [];
	for (var _i = 0; _i < CRT_BLOOM_STEPS; _i++) {
		_w = max(1, _w div 2); _h = max(1, _h div 2);
		array_push(bloom_ch, surface_create(_w, _h, bloom_fmt));
	}
	bloom_key = _key;
	return true;
};

/// bright (already drawn) -> the chain; returns the top link or -1
__bloom_run = function(_src) {
	if (!surface_exists(_src)) return -1;
	if (!__bloom_chain(surface_get_width(_src), surface_get_height(_src))) return -1;
	gpu_set_tex_filter(true);
	// down: each pass halves (the one ratio at which bilinear averages
	// honestly - blur_snap's lesson)
	var _from = _src;
	for (var _i = 0; _i < CRT_BLOOM_STEPS; _i++) {
		var _d = bloom_ch[_i];
		surface_set_target(_d);
		draw_clear_alpha(c_black, 1);
		draw_surface_ext(_from, 0, 0,
			surface_get_width(_d)  / surface_get_width(_from),
			surface_get_height(_d) / surface_get_height(_from), 0, c_white, 1);
		surface_reset_target();
		_from = _d;
	}
	// up, ADDING: level i keeps its own blur and gains the wider one
	gpu_set_blendmode(bm_add);
	for (var _i = CRT_BLOOM_STEPS - 2; _i >= 0; _i--) {
		var _d = bloom_ch[_i], _c = bloom_ch[_i + 1];
		surface_set_target(_d);
		draw_surface_ext(_c, 0, 0,
			surface_get_width(_d)  / surface_get_width(_c),
			surface_get_height(_d) / surface_get_height(_c), 0, c_white, 1);
		surface_reset_target();
	}
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(false);
	return bloom_ch[0];
};

bright = -1;    // the bloom's source: the frame squared, half size, in
                // bloom_fmt (see the Draw - a blend mode does the squaring)
scratch = -1;   // the frame's copy (the surface can't sample itself);
                // taken the way pixel_snap takes the drawer's backdrop
                // - surface_set_target + draw_surface_ext, the capture
                // this project has proven - not surface_copy
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
