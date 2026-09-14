/// top-down: the shadow under it softening as it rises; height as a
/// gentle scale-up; sh_coin raycasts straight down
if (!unfold_has("coin")) exit;
var _hh = max(0, pz - ct);
var _gw = sprite_get_width(spr_vis_glow_soft);
var _gh = sprite_get_height(spr_vis_glow_soft);
// the shadow: a disc's, squashed by the tilt (the up axis' lean)
var _lean = sqrt(max(0, 1 - orient[8] * orient[8]));
draw_sprite_ext(spr_vis_glow_soft, 0, x, y,
	(r * 2.9 + _hh * .3) / _gw, (r * 2.9 * (1 - .45 * _lean) + _hh * .3) / _gh, 0,
	c_black, clamp(.36 - _hh * .006, .12, .36));

var _sc = clamp(1 + _hh * .011, 1, 1.7);
var _qh = r * QP * _sc;
var _ot = mat3_transpose(orient);
shader_set(sh_coin);
shader_set_uniform_f(u_quad2, x - _qh, y - _qh, _qh * 2, _qh * 2);
shader_set_uniform_f_array(u_or2, _ot);
shader_set_uniform_f(u_light2, -.42, -.62, .66);
shader_set_uniform_f(u_col2, colour_get_red(tint) / 255, colour_get_green(tint) / 255, colour_get_blue(tint) / 255);
shader_set_uniform_f(u_metal2, metal);
shader_set_uniform_f(u_pad2, QP);
shader_set_uniform_f(u_cells2, px_cell > 0 ? (_qh * 2) / px_cell : 0);
scene_light_bind(s_scene2, s_scene2w, u_sceneuv2, u_sceneam2);
draw_sprite_ext(spr_pixel_1x1, 0, x - _qh, y - _qh, _qh * 2, _qh * 2, 0, c_white, 1);
shader_reset();
scene_light_unbind();
