/// top-down presentation: the shadow sits directly under the die and
/// softens as it rises; height reads as a gentle scale-up (the table
/// camera's fake perspective). the shader is unchanged - it raycasts
/// straight down, so the up face is the face you read.

var _hh = max(0, pz - r); // height above resting
var _gw = sprite_get_width(spr_vis_glow_soft);
var _gh = sprite_get_height(spr_vis_glow_soft);
draw_sprite_ext(spr_vis_glow_soft, 0, x, y,
	(r * 3.1 + _hh * .3) / _gw, (r * 3.1 + _hh * .3) / _gh, 0,
	c_black, clamp(.38 - _hh * .006, .12, .38));

var _sc = clamp(1 + _hh * .011, 1, 1.7);
var _qh = r * QP * _sc;
var _ot = mat3_transpose(orient); // object-from-view for the shader
shader_set(sh_dice);
shader_set_uniform_f(u_quad2, x - _qh, y - _qh, _qh * 2, _qh * 2);
shader_set_uniform_f_array(u_or2, _ot);
shader_set_uniform_f(u_light2, -.42, -.62, .66);
shader_set_uniform_f(u_col2,
	colour_get_red(tint) / 255,
	colour_get_green(tint) / 255,
	colour_get_blue(tint) / 255);
shader_set_uniform_f(u_ink2, ink[0], ink[1], ink[2]);
shader_set_uniform_f(u_metal2, metal);
shader_set_uniform_f(u_pad2, QP);
shader_set_uniform_f(u_cells2, px_cell > 0 ? (_qh * 2) / px_cell : 0);
draw_sprite_ext(spr_pixel_1x1, 0, x - _qh, y - _qh, _qh * 2, _qh * 2, 0, c_white, 1);
shader_reset();
