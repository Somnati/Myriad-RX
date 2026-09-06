
if (!instance_exists(syst_menu2)) { kill; exit; }
var _a = syst_menu2.am;
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, .48 * _a);

// THE EDGE GRADIENTS (his ask 2026-09-06). The techdemo's OLD menu
// backdrop drew these and menu v2 never picked them up - the sprite had
// not even been ported. spr_menu_back_3 is a 144x1 strip, opaque at
// column 0 and fading out by column 143: drawn twice with its single
// pixel row stretched to the room's full height, once inward from each
// side edge. The right-hand copy takes a NEGATIVE x scale anchored at
// room_width, which is what mirrors it.
// _s keeps each fade spanning HALF the room at any width - 144 is the
// portrait width, so the scale is 1 in rm_clicker and larger in the
// landscape twin, and neither has to know about the other.
// ⚖️ THE GRADIENT RIDES THE BLUR, and must. This backing sits at -450
// specifically so the menu_blur layer (-500) passes over it - the
// techdemo's own note on the same object says the split exists because
// "the gaussian smooths the gradient banding that showed when the
// backing sat above the blur". A wide, dark, low-contrast ramp is the
// textbook 8-bit banding case in this project, and the gaussian is what
// dithers it.
// So when the player turns menu blur OFF there is nothing left to
// smooth it, and the ramp breaks into visible steps (his report
// 2026-09-06). Rather than ship a banded gradient, the backing falls
// back to the flat plate alone: the blur toggle now switches the whole
// fancy backdrop, which is honest - both halves cost gpu and both go
// together. A gradient that stands up WITHOUT the gaussian needs a real
// dithered pass; that is a separate job.
if (variable_global_exists("blur") ? g.blur : true) {
	var _s = room_width / 144;
	draw_sprite_ext(spr_menu_back_3, 0, 0, 0, _s / 2, room_height, 0,
		c_black, .65 * _a);
	draw_sprite_ext(spr_menu_back_3, 0, room_width, 0, -(_s / 2), room_height, 0,
		c_black, .65 * _a);
}
