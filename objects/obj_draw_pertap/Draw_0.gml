/// DE's draw, coordinate for coordinate - both rooms are 144x296, so
/// the numbers port exactly. Two substitutions, both because RX simply
/// does not have DE's asset:
///   spr_glow_sw1 -> spr_vis_glow_soft (the house soft blob; 144px and
///     centre-origin against DE's 36px, so the scale and anchor are
///     rebuilt to land the same ~72px shadow in the same place)
///   set_color    -> draw_set_color   (DE's wrapper, never ported)
/// and one rename: DE's global.pre_syphon_gps is RX's g.click_gps, the
/// same quantity - profit per tap before anything downstream touches it.

// the ONE addition to DE's code: click_gps is seeded by create_clicker,
// and this draws every frame in a room that could in principle be
// reached before it. tap_fire guards the same global for the same
// reason - a readout is not worth a boot crash.
if (!variable_global_exists("click_gps")) exit;

// the soft shadow the readout sits on
var _gs = 72 / sprite_get_width(spr_vis_glow_soft);
draw_sprite_ext(spr_vis_glow_soft, 0, x + 39, y + 39 + ui_wordline_h(), _gs, _gs, 0, c_black, .25);

draw_set_font(fnt);
draw_set_alpha(alpha);
draw_set_halign(fa_left);
// a triad off the profit colour: related to the money, not the same as
// it, so the caption never reads as another profit figure
draw_set_color(color_set_triadic(g.profit_color, 1));
var _wo = ui_wordline_h();   // the word line under the counter (words format)
draw_text(3, 28 + _wo, "per tap");

draw_set_font(fnt_large);
var _t = crunch_arb(g.click_gps);
// THE GRADIENT: white across the top corners, c_glow-tinted gray across
// the bottom two. draw_text_color takes its own alpha, which is why the
// fade-in works on a call that ignores draw_set_alpha.
var _c = merge_colour(c_gray, c_glow, v_glow);
draw_text_color(5, 37 + _wo, _t, c_white, c_white, _c, _c, alpha);
text_width = string_width(_t);

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_color(c_white);
