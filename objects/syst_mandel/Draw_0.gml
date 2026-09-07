/// one full-room quad through sh_mandel, then the readout.

var _it   = __iter();
var _p    = pal_list[pal_set];
var _pert = __pert_on();
var _dd   = __dd_on();

shader_set(sh_mandel);

// ⚖️ u_res IS THE RENDER TARGET'S SIZE, NOT THE ROOM'S. gl_FragCoord
// counts pixels of whatever surface is being drawn into, and
// application_surface is sized to the WINDOW - so dividing it by the
// room gave a coordinate wrong by the window/room ratio. That made the
// picture a stretched crop AND made zoom-toward-cursor point somewhere
// the cursor was not: GML normalises the mouse by the room, so the two
// only agree when the shader normalises by its own target.
var _rw = room_width, _rh = room_height;
if (surface_exists(application_surface)) {
	_rw = surface_get_width(application_surface);
	_rh = surface_get_height(application_surface);
}
shader_set_uniform_f(u_res,    _rw, _rh);
// the aspect is the ROOM's - it decides the shape the player sees, and
// should not change if the surface is ever letterboxed
shader_set_uniform_f(u_aspect, room_width / room_height);
shader_set_uniform_f(u_dbg,    dbg ? 1 : 0);

// the shallow path reads the centre as plain floats. Flattening a dd
// pair is safe here BECAUSE it is only reached above 2e-5, where a
// float32 centre is fine anyway.
shader_set_uniform_f(u_centre, __bnreal(cx), __bnreal(cy));
shader_set_uniform_f(u_scale,  scale);
shader_set_uniform_f(u_iter,   _it);
shader_set_uniform_f(u_time,   current_time / 1000);
shader_set_uniform_f(u_pal,    _p.r, _p.g, _p.b, pal_shift);
shader_set_uniform_f(u_glow,   glow);

// ---- the f32x2 fallback path ----
// Split every frame rather than cached: cx/cy move every frame while a
// zoom eases, and a stale pair would put the deep view somewhere the
// shallow one is not.
var _sx = __split(__bnreal(cx));
var _sy = __split(__bnreal(cy));
var _ss = __split(scale);
shader_set_uniform_f(u_cdd, _sx[0], _sx[1], _sy[0], _sy[1]);
shader_set_uniform_f(u_sdd, _ss[0], _ss[1]);
shader_set_uniform_f(u_dd,  _dd ? 1 : 0);

// ---- the perturbation path ----
// THE ONLY THING THE SHADER NEEDS FROM THE CENTRE is its offset from
// the reference point - and that is a DIFFERENCE of two nearby dd
// values, so it is small, and a plain float carries it exactly. That is
// the whole trick: all the precision stays on this side, and what
// crosses the uniform is a number small enough not to need any.
shader_set_uniform_f(u_pert, _pert ? 1 : 0);
if (_pert) {
	// ⚖️ THE ONLY THING THAT CROSSES IS A DIFFERENCE. cx and ref_cx are
	// both bignums with a hundred digits between them, and neither would
	// survive a float uniform - but their DIFFERENCE is at most a view
	// span, which is exactly the size a float carries perfectly. That is
	// the whole reason perturbation makes the depth a CPU question.
	shader_set_uniform_f(u_dcoff,
		__bnreal(__bnsub(cx, ref_cx)), __bnreal(__bnsub(cy, ref_cy)));
	shader_set_uniform_f(u_reflen, ref_len);
	shader_set_uniform_f(u_reftex, REF_W, surface_get_height(ref_surf));
	texture_set_stage(s_ref, surface_get_texture(ref_surf));
	// NEAREST, and no repeat: the orbit is sampled at exact texel
	// centres and a filtered read would blend two unrelated iterations
	// of the reference into one - which is not a soft error, it is a
	// wrong number in the middle of a recurrence.
	gpu_set_tex_filter_ext(s_ref, false);
	gpu_set_tex_repeat_ext(s_ref, false);
} else {
	shader_set_uniform_f(u_dcoff,  0, 0);
	shader_set_uniform_f(u_reflen, 0);
	shader_set_uniform_f(u_reftex, 1, 1);
}

draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_white, 1);
shader_reset();

if (!show_hud) exit;

// ---- the readout ----
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// magnification as a multiple of the opening view - the number that
// means something to a person. Formatted by hand rather than through
// crunch_arb: past ~1e15 the packing helpers are being asked to do
// something they were built for money, not for this.
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
// the reference's health is the thing to look at when a deep view
// looks wrong or runs slow: a SHORT escaped orbit means the shader is
// rebasing constantly and perturbation is buying nothing, and a
// rebuild counter climbing every frame means the rebuild rule is
// thrashing.
if (_pert) array_push(_lines,
	"ref " + string(ref_len) + (ref_esc ? " esc" : " full")
	+ "   rebuilt " + string(ref_built) + "x");

// the floor, and what would be needed to pass it
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
	if (_lines[_i] == "bignum floor - raise BN_MAX for more"
	 || _lines[_i] == "f32x2 floor" || _lines[_i] == "f32 floor") _c = c_horange;
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
