
// ⚖️ ONE BACKING FOR THE MENU AND EVERY OVERLAY (his report, three
// times over, 2026-09-10: "blur the background when opening those"
// - settings, statistics, automation, rebirth, time bank). The blur
// layer itself was riding every overlay's ease (ui_blur_tick), but the
// LOOK of the menu is this object: the plate and the edge gradients
// drawn UNDER the blur so the gaussian softens them with the room.
// The overlays each painted their own plate ABOVE the blur instead -
// a sharp black sheet over a blurred room reads as a dark room, not a
// frosted one. So the overlays draw no ground of their own any more;
// ui_blur_tick keeps one of these alive whenever anything wants the
// room softened, and it rides whichever ease is higher - the menu's
// fold or the overlay's oa. What you see behind the menu is now, by
// construction, what you see behind every panel.
var _a = 0;
if (instance_exists(syst_menu2)) _a = syst_menu2.am;
var _ov = ui_overlay();
if (_ov != noone) _a = max(_a, _ov.oa);
if (_a <= .002) { kill; exit; }
draw_sprite_ext(spr_pixel_1x1, 0, 0, 0, room_width, room_height, 0, c_black, UI_GROUND_A * _a);

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
