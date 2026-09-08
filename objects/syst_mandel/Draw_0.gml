/// THE PROGRESSIVE RENDERER, then the readout.
///
/// ⚖️ WHY THIS EXISTS. The iteration budget at depth is enormous - the
/// formula asks for 2546 at 1e-26 and 11780 at 1e-130 - and a budget
/// that large cannot be spent every frame. Two things make it
/// affordable, and neither is a compromise on the image:
///
/// 1. IT RENDERS INTO ITS OWN SURFACE at display resolution. Drawing
///    "to the screen" in GM is already drawing into
///    application_surface, so owning the target changes nothing about
///    orientation or coordinates - it just makes the render
///    interruptible, which is the entire point.
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

// ---- the surface, at DISPLAY resolution ----
// Rendering at room size and stretching was a visibly softer picture
// than drawing to the display had been. The progressive pass is what
// makes full resolution affordable: the pixel count goes up eightfold
// and the per-frame cost does not, because the bands absorb it. Capped
// so a 4K panel does not ask for eight million pixels of fractal.
var _tw = room_width, _th = room_height;
if (surface_exists(application_surface)) {
	_tw = min(surface_get_width(application_surface), 1920);
	_th = min(surface_get_height(application_surface), 1080);
}
if (!surface_exists(rend_surf) || _tw != rend_w || _th != rend_h) {
	if (surface_exists(rend_surf)) surface_free(rend_surf);
	rend_w = _tw;
	rend_h = _th;
	rend_surf  = surface_create(rend_w, rend_h);
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

// ⚖️ BANDS ARE DERIVED FROM THE ACTUAL WORK - pixels times iterations -
// not from the iteration count alone. At the deep end that product is
// twelve billion pixel-iterations for one exact frame, which no frame
// can pay; split into bands of a fixed size it becomes a few seconds of
// visible sharpening instead. Tuned so a band is roughly 40 million
// pixel-iterations, which is a few milliseconds on anything modern.
var _bands = clamp(ceil(rend_w * rend_h * _it / 40000000), 1, 400);

surface_set_target(rend_surf);
if (rend_dirty) {
	// One coarse pass over the whole surface, so there is never a
	// half-drawn screen. It is deliberately cheap, and at depth it will
	// be FLAT - 200 iterations cannot tell deep pixels apart - which is
	// correct behaviour rather than a failure: a moving view gets a
	// whole image immediately, and the refine below is what has the
	// budget to resolve it once you stop.
	__shade(min(_it, 200), _p, _pert, _dd);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, rend_w, rend_h, 0, c_white, 1);
	shader_reset();
	rend_dirty = false;
	rend_band  = 0;
} else if (rend_band < _bands) {
	// the refine: full budget, one band, drawn at its real y so
	// gl_FragCoord still reports the whole-surface position
	__shade(_it, _p, _pert, _dd);
	var _y0 = floor(rend_h * rend_band / _bands);
	var _y1 = floor(rend_h * (rend_band + 1) / _bands);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, _y0, rend_w, _y1 - _y0, 0, c_white, 1);
	shader_reset();
	rend_band += 1;
}
surface_reset_target();

draw_surface_stretched(rend_surf, 0, 0, room_width, room_height);

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
	"zoom " + _mag_s + "   iter " + string(round(_it))
		+ (iter_mult != 1 ? " x" + string_format(iter_mult, 1, 2) : "") + "   " + _mode
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
draw_text(_pad + 5, room_height - 12,
	"c palette   g glow   o/p iterations   h hud   v coords   q back");

draw_set_alpha(1);
draw_set_color(c_white);
