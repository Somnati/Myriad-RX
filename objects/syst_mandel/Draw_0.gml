/// one full-room quad through sh_mandel, then the readout.
/// Drawn at ROOM size - 480x270 is ~130k pixels, and the display scale
/// blows it up for free. Rendering this at native window resolution is
/// the single most common reason a fractal viewer crawls.

var _it = __iter();
var _p  = pal_list[pal_set];

shader_set(sh_mandel);
shader_set_uniform_f(u_centre, cx, cy);
shader_set_uniform_f(u_scale,  scale);
shader_set_uniform_f(u_res,    room_width, room_height);
shader_set_uniform_f(u_iter,   _it);
shader_set_uniform_f(u_time,   current_time / 1000);
shader_set_uniform_f(u_pal,    _p.r, _p.g, _p.b, pal_shift);
shader_set_uniform_f(u_glow,   glow);
// the view again as hi/lo float pairs. Split every frame rather than
// cached: cx/cy change every frame while a zoom is easing, and a stale
// pair would put the deep view somewhere the shallow one is not.
var _dd = __dd_on();
var _sx = __split(cx);
var _sy = __split(cy);
var _ss = __split(scale);
shader_set_uniform_f(u_cdd, _sx[0], _sx[1], _sy[0], _sy[1]);
shader_set_uniform_f(u_sdd, _ss[0], _ss[1]);
shader_set_uniform_f(u_dd,  _dd ? 1 : 0);
// ⚖️ A HAND-BUILT QUAD, not draw_sprite_ext, and the texture
// coordinates are the entire reason. A stretched sprite carries the UVs
// of its ATLAS PAGE - for spr_pixel_1x1 that is one texel, effectively
// constant across the screen - so the shader had nothing to work with.
// Supplying the corners explicitly makes v_vTexcoord exactly 0..1
// across the quad, in the room's own orientation, independent of the
// atlas, of application_surface's size, and of whether the render
// target counts y from the top or the bottom. That last part is what
// makes the shader's pixel-to-complex mapping agree with __at()'s,
// which is what makes zoom-toward-cursor land where the cursor is.
// The texture is bound but never sampled; it is only here because
// draw_vertex_texture needs one.
draw_set_colour(c_white);
draw_set_alpha(1);
draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(spr_pixel_1x1, 0));
draw_vertex_texture(0,          0,           0, 0);
draw_vertex_texture(room_width, 0,           1, 0);
draw_vertex_texture(0,          room_height, 0, 1);
draw_vertex_texture(room_width, room_height, 1, 1);
draw_primitive_end();
shader_reset();

if (!show_hud) exit;

// ---- the readout ----
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// magnification, as a multiple of the opening view - the number that
// actually means something to a person, rather than the raw scale
var _mag = 1.35 / max(scale, SCALE_MIN);
var _mag_s = (_mag < 1000) ? string(round(_mag)) + "x" : crunch_arb(arb(round(_mag)));

var _pad = 4;
var _lines = [
	"mandelbrot  -  " + _p.name,
	"zoom " + _mag_s + "   iter " + string(round(_it))
		+ "   " + (_dd ? "f32x2" : "f32"),
];
// THE HONEST LIMIT. float32 stops resolving neighbouring pixels down
// here, and past it the image goes blocky and looks broken. Saying so
// is better than either letting it melt or silently refusing the wheel
// with no explanation.
// the floor now belongs to the double-double path, and past IT the
// honest answer is perturbation theory rather than more mantissa
var _at_floor = (scale_to <= SCALE_MIN * 1.001);
if (_at_floor) array_push(_lines, _dd
	? "f32x2 floor - deeper needs perturbation"
	: "f32 floor");

var _w = 0;
for (var _i = 0; _i < array_length(_lines); _i++)
	_w = max(_w, string_width(_lines[_i]));

draw_sprite_ext(spr_pixel_1x1, 0, _pad, _pad, _w + 10,
	array_length(_lines) * 10 + 6, 0, c_black, .55);
for (var _i = 0; _i < array_length(_lines); _i++) {
	draw_set_color((_i == 2) ? c_horange : ((_i == 0) ? c_gold : sett_ink));
	draw_set_alpha((_i == 0) ? .95 : .8);
	draw_text(_pad + 5, _pad + 4 + _i * 10, _lines[_i]);
}

// controls, bottom left, quiet
draw_set_color(sett_ink);
draw_set_alpha(.45);
draw_text(_pad + 5, room_height - 22, "drag pan   wheel zoom   space tour");
draw_text(_pad + 5, room_height - 12, "c palette   g glow   h hud   q back");

draw_set_alpha(1);
draw_set_color(c_white);
