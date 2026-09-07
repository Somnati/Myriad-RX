/// THE PROGRESSIVE RENDERER, then the readout.
///
/// ⚖️ WHY THIS EXISTS. The iteration budget at depth is enormous - the
/// formula asks for 2546 at 1e-26 and 11780 at 1e-130 - and a budget
/// that large cannot be spent every frame. Two things make it
/// affordable, and neither is a compromise on the image:
///
/// 1. IT RENDERS INTO A ROOM-SIZED SURFACE, not to the screen.
///    gl_FragCoord counts render-target pixels, so drawing straight to
///    the display meant computing the fractal at WINDOW resolution -
///    about eight times the pixels for a picture that is then shown at
///    room scale anyway. (Drawing "to the screen" in GM is already
///    drawing into application_surface, so this changes nothing about
///    orientation or coordinates - it is the same kind of target, a
///    better size.)
/// 2. IT SPENDS THE BUDGET ACROSS FRAMES. While the view moves, one
///    cheap pass at a capped iteration count keeps a whole image on
///    screen. The moment it settles, the full budget is paid a BAND at
///    a time until the picture is exact. You watch it sharpen instead
///    of watching the framerate die, and a still view converges to a
///    render no single frame could have afforded.

var _it   = __iter();
var _p    = pal_list[pal_set];
var _pert = __pert_on();
var _dd   = __dd_on();

// ---- the surface ----
if (!surface_exists(rend_surf)) {
	rend_surf  = surface_create(room_width, room_height);
	rend_dirty = true;
}

// ---- has anything about the picture changed? ----
// The centre is compared as its OFFSET FROM THE REFERENCE, never as an
// absolute: at this depth cx itself is a hundred digits long and
// flattening it to a real would report "unchanged" for any pan smaller
// than the double it collapses into. The difference is small and exact.
var _kx = __bnreal(__bnsub(cx, ref_cx));
var _ky = __bnreal(__bnsub(cy, ref_cy));
if (scale != rend_k_scale || _kx != rend_k_dx || _ky != rend_k_dy
 || pal_set != rend_k_pal || glow != rend_k_glow || dbg != rend_k_dbg
 || ref_built != rend_k_ref || _pert != rend_k_pert || _it != rend_k_it) {
	rend_dirty  = true;
	rend_k_scale = scale;  rend_k_dx  = _kx;   rend_k_dy   = _ky;
	rend_k_pal   = pal_set; rend_k_glow = glow; rend_k_dbg = dbg;
	rend_k_ref   = ref_built; rend_k_pert = _pert; rend_k_it = _it;
}

// bands scale with the cost, so one band is always about the same
// amount of work no matter how deep the view is
var _bands = clamp(ceil(_it / 120), 1, 30);

surface_set_target(rend_surf);
if (rend_dirty) {
	// one coarse pass over the whole surface, so there is never a
	// half-drawn screen - a moving view gets an approximate picture
	// immediately and the refine below makes it exact once it stops
	__shade(min(_it, 260), _p, _pert, _dd);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_white, 1);
	shader_reset();
	rend_dirty = false;
	rend_band  = 0;
} else if (rend_band < _bands) {
	// the refine: full budget, one band, drawn at its real y so
	// gl_FragCoord still reports the whole-surface position
	__shade(_it, _p, _pert, _dd);
	var _y0 = floor(room_height * rend_band / _bands);
	var _y1 = floor(room_height * (rend_band + 1) / _bands);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, _y0, room_width, _y1 - _y0, 0, c_white, 1);
	shader_reset();
	rend_band += 1;
}
surface_reset_target();

draw_surface(rend_surf, 0, 0);

if (!show_hud) exit;

// ---- the readout ----
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// magnification as a multiple of the opening view. Formatted by hand
// rather than through crunch_arb: past ~1e15 the packing helpers are
// being asked to do something they were built for money, not for this.
var _mag = 1.35 / max(scale, SCALE_MIN_PERT);
var _mag_s;
if (_mag < 1000) _mag_s = string(round(_mag)) + "x";
else {
	var _e = floor(log10(_mag));
	_mag_s = string_format(_mag / power(10, _e), 1, 2) + "e" + string(_e) + "x";
}

var _mode = _pert ? "perturb" : (_dd ? "f32x2" : "f32");
var _pad = 4;
var _lines = [
	"mandelbrot  -  " + _p.name,
	"zoom " + _mag_s + "   iter " + string(round(_it)) + "   " + _mode
		+ (_pert ? "  " + string(bn_L) + " limbs" : ""),
];
// the reference's health, and whether a job is running. This is what to
// look at when a deep view runs slow or looks wrong: a SHORT escaped
// orbit means the shader is rebasing constantly and perturbation is
// buying nothing.
if (_pert || rj_on) array_push(_lines,
	"ref " + string(ref_len) + (ref_esc ? " esc" : " full")
	+ (rj_on ? "   building " + string(round(100 * rj_i / max(1, rj_lim))) + "%"
	         : "   built " + string(ref_built) + "x"));
// and whether the picture on screen is finished
if (rend_band < _bands) array_push(_lines,
	"refining " + string(round(100 * rend_band / _bands)) + "%");

var _at_floor = (scale_to <= SCALE_MIN * 1.001);
if (_at_floor) array_push(_lines, _pert
	? "bignum floor - raise BN_MAX for more"
	: (_dd ? "f32x2 floor" : "f32 floor"));

var _w = 0;
for (var _i = 0; _i < array_length(_lines); _i++)
	_w = max(_w, string_width(_lines[_i]));

draw_sprite_ext(spr_pixel_1x1, 0, _pad, _pad, _w + 10,
	array_length(_lines) * 10 + 6, 0, c_black, .55);
for (var _i = 0; _i < array_length(_lines); _i++) {
	var _c = sett_ink;
	if (_i == 0) _c = c_gold;
	if (string_pos("floor", _lines[_i]) > 0) _c = c_horange;
	draw_set_color(_c);
	draw_set_alpha((_i == 0) ? .95 : .8);
	draw_text(_pad + 5, _pad + 4 + _i * 10, _lines[_i]);
}

// controls, bottom left, quiet
draw_set_color(sett_ink);
draw_set_alpha(.45);
draw_text(_pad + 5, room_height - 22,
	"drag pan   wheel zoom   HOLD RIGHT dive (+shift out)   space tour");
draw_text(_pad + 5, room_height - 12, "c palette   g glow   h hud   v coords   q back");

draw_set_alpha(1);
draw_set_color(c_white);
