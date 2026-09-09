/// the puck, its aim UI and its impact sparks. Draw-only: every number
/// here was decided in the Step.
///
/// ⚖️ THE PUCK IS A RAYMARCHED SOLID; EVERYTHING AROUND IT IS PIXEL
/// SPANS. It was spans too until it became 3D - the flat version stacked
/// a baked half-width table into a shaded circle, and that table is gone
/// with it. The house rule it was obeying still holds, though, and
/// sh_puck obeys it a different way: quantizing the QUAD COORDINATE
/// gives one exact ray per cell, so the solid is as hard-edged as the
/// spans were. A smooth 3D render dropped into a pixel game is the thing
/// that would not have matched anything around it.

var _cx = __cx();
var _cy = __cy();
// ⚖️ NOTHING HERE SNAPS TO A PIXEL (his ask, 2026-09-09: "no pixel
// snapping plz"). It used to, and the reason was sound at the time: the
// puck was a stack of hard-edged pixel SPANS, and a span whose left
// edge lands on a half pixel has its width jitter by one as it moves.
//
// That reason died with the flat draw. The solid's crispness now comes
// from sh_puck quantizing the quad COORDINATE - one exact ray per cell,
// and the cell grid is anchored to the quad, so it travels WITH the
// puck instead of the puck sliding across a fixed screen grid. The
// blocks stay razor-sharp at any sub-pixel position, and the floor was
// doing nothing but chopping the motion into whole-pixel steps.
//
// obj_dice never floored its quad either, for exactly this reason -
// this had simply outlived its own justification. Same conclusion the
// title screen reached from the other direction: snap what has to sit
// on the grid, and nothing else.
var _mx = max(room_width, room_height);
var _fr = clamp(spd / _mx, 0, 1);

// ---- the aim line, while the cannon is armed ----
// Drawn FIRST so the puck sits on top of its own shot line - the line
// comes out from under the disc rather than lying across it.
if (cannon && aim > 2) {
	var _len = min(aim, _mx * .55);
	var _tc  = vis_tier_color(4 + tier * 2);   // the rarity ladder as a
	                                           // power scale: a stronger
	                                           // shot is visibly a rarer
	                                           // colour, which is a
	                                           // language the player
	                                           // already reads fluently
	// a gradient strip along the aim, fading out at the far end
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		_cx, _cy - 1, _len, 2, dir,
		_tc, c_black, c_black, _tc, .55);

	// chevrons: one per power tier, marching out along the line. The
	// COUNT is the readout - you can tell how charged a shot is without
	// reading a number, which matters when your eyes are on the cursor.
	for (var _i = 0; _i <= tier; _i++) {
		var _at = _len * (.55 + _i * .16);
		var _px = _cx + lengthdir_x(_at, dir);
		var _py = _cy + lengthdir_y(_at, dir);
		for (var _k = 0; _k < 5; _k++) {
			var _b = _k * 1.6;
			draw_sprite_ext(spr_pixel_1x1, 0,
				_px + lengthdir_x(-_b, dir) + lengthdir_x(_b, dir - 90),
				_py + lengthdir_y(-_b, dir) + lengthdir_y(_b, dir - 90),
				2, 2, 0, _tc, .9 - _k * .1);
			draw_sprite_ext(spr_pixel_1x1, 0,
				_px + lengthdir_x(-_b, dir) + lengthdir_x(_b, dir + 90),
				_py + lengthdir_y(-_b, dir) + lengthdir_y(_b, dir + 90),
				2, 2, 0, _tc, .9 - _k * .1);
		}
	}
}

// ---- the ground shadow ----
// It does not move with the puck's height (there is no height here -
// this is a flat table seen from above), so it is a contact shadow: it
// TIGHTENS as the puck speeds up, which reads as the disc pressing into
// the surface. Cheap, and it stops the puck floating on the visualiser.
var _gw = sprite_get_width(spr_vis_glow_soft);
var _gs = (d * lerp(2.4, 1.7, _fr)) / _gw;
draw_sprite_ext(spr_vis_glow_soft, 0, _cx, _cy + 2, _gs, _gs, 0,
	c_black, lerp(.30, .16, _fr));

// ---- the motion smear ----
// A short trail behind a fast puck, sampled back along its own
// direction. Not a physical afterimage - it is the one cue that says
// "this is moving fast" at a glance, and it fades out entirely below
// half speed so a drifting puck stays clean.
if (!held && _fr > .18) {
	var _n = 5;
	for (var _i = 1; _i <= _n; _i++) {
		var _b = (_i / _n) * d * 1.6 * _fr;
		var _sa = (1 - _i / _n) * .22 * _fr;
		draw_sprite_ext(spr_pixel_1x1, 0,
			_cx - lengthdir_x(_b, dir) - r * .45,
			_cy - lengthdir_y(_b, dir) - r * .45,
			r * .9, r * .9, 0, tint, _sa);
	}
}

// ---- THE PUCK ITSELF ----
// ⚖️ A RAYMARCHED SOLID, not a stack of pixel spans (his ask: make it 3D
// like the dice). obj_dice's exact construction with a different SDF -
// draw one quad, let sh_puck cast an orthographic ray per CELL, and the
// silhouette, the shading, the knurled edge and the stamped crown all
// fall out of the same distance field. The cell quantizer is why this
// is still hard-edged pixel art rather than a smooth 3D render sitting
// in a pixel game: one exact sample per cell, never averaged.
//
// The stamp carries the throw's colour and the BODY stays black rubber.
// A puck that changes body colour stops looking like a puck; a puck
// with a coloured ring stamped in it still tells you which throw you
// are watching. State still reads at a glance, because tint (red
// stunned, aqua docked) is what feeds the ring.
draw_set_alpha(1);
var _qh = r * PUCK_QP;
shader_set(sh_puck);
shader_set_uniform_f(u_quad_p, _cx - _qh, _cy - _qh, _qh * 2, _qh * 2);
shader_set_uniform_f(u_yaw_p, degtorad(yaw));
shader_set_uniform_f(u_light_p, -.42, -.62, .66);
shader_set_uniform_f(u_col_p,
	colour_get_red(rubber) / 255,
	colour_get_green(rubber) / 255,
	colour_get_blue(rubber) / 255);
shader_set_uniform_f(u_ring_p,
	colour_get_red(tint) / 255,
	colour_get_green(tint) / 255,
	colour_get_blue(tint) / 255);
// rubber, unless the cannon is charging - a shot winding up polishes
// itself, which is a free tell that something is about to happen
shader_set_uniform_f(u_metal_p, cannon ? lerp(.06, .5, clamp(aim / 120, 0, 1)) : .06);
shader_set_uniform_f(u_pad_p, PUCK_QP);
shader_set_uniform_f(u_cells_p, _qh * 2);   // one cell per room pixel
draw_sprite_ext(spr_pixel_1x1, 0, _cx - _qh, _cy - _qh,
	_qh * 2, _qh * 2, 0, c_white, 1);
shader_reset();

// ---- the combo ring ----
// While a throw still has bounce-resist banked, an arc of pips rides the
// rim - one per remaining near-frictionless bounce. It is the only
// visible trace of the combo resource, and watching it spend down is
// what makes a long throw tense rather than just long.
if (resist > 0) {
	for (var _i = 0; _i < min(resist, 12); _i++) {
		var _pa = -90 + (_i / max(1, min(resist0, 12))) * 360;
		draw_sprite_ext(spr_pixel_1x1, 0,
			_cx + lengthdir_x(r + 2, _pa) - 1,
			_cy + lengthdir_y(r + 2, _pa) - 1,
			2, 2, 0, c_gold, .85);
	}
}

// ---- the sparks ----
for (var _i = 0; _i < array_length(sparks); _i++) {
	var _s = sparks[_i];
	var _a = clamp(_s.l / _s.l0, 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _s.x, _s.y, 1, 1, 0, _s.c, _a * .9);
}

// ---- the bounce counter ----
// Only while a throw is actually running, and only past the second
// bounce: a "1" on every toss is noise, a climbing number on a good
// throw is the score. It rides the puck rather than sitting in a
// corner, because the puck is where you are looking.
if (!held && spd > 0 && bounces > 1) {
	draw_set_font(fnt);
	draw_set_halign(fa_center);
	draw_set_color(c_gold);
	draw_set_alpha(clamp(_fr * 2.2, .3, .95));
	draw_text(_cx, _cy - r - 10, "x" + string(bounces));
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_set_color(c_white);
}
