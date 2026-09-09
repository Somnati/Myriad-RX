/// the puck, its aim UI and its impact sparks. Draw-only: every number
/// here was decided in the Step.
///
/// ⚖️ EVERYTHING IS DRAWN FROM spr_pixel_1x1 SPANS, including the disc.
/// The house rule is hard pixels only - draw_circle's smooth vector ring
/// was the one shape in this game that did not match anything around it
/// (the settings "?" button is built the same way for the same reason).
/// The disc table is baked in the Create.

var _cx = __cx();
var _cy = __cy();
// ⚖️ THE DISC SNAPS, THE SOFT THINGS DO NOT. r is 9.5 on a 19px puck,
// and x arrives from a trickle, so an unfloored span lands on a half
// pixel: the edge shimmers and the width jitters by one as it moves.
// Hard-edged pixel art has to sit on the grid. The shadow, the smear
// and the sparks are all soft or sub-pixel by nature and stay
// fractional - snapping THOSE is what makes slow motion stutter (the
// title screen's rule, in the other direction).
var _px0 = floor(_cx);
var _py0 = floor(_cy);
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

// ---- THE DISC ----
// horizontal spans from the baked half-width table, mirrored about the
// centre row. Two passes: the body, then a lighter core inset by 3, so
// the puck reads as a rim and a face rather than as a flat blob.
draw_set_alpha(1);
var _rim  = merge_colour(tint, c_black, .35);
var _face = merge_colour(tint, c_white, .30);
for (var _dy = -(d div 2); _dy <= (d div 2); _dy++) {
	var _hw = disc[abs(_dy)];
	// ⚖️ ZERO IS A ROW, NOT AN ABSENCE. A half-width of 0 still draws
	// one pixel (_hw * 2 + 1), and that is the disc's cap row. Skipping
	// it made a 19-wide, 17-tall puck - an ellipse nobody asked for.
	if (_hw < 0) continue;
	draw_sprite_ext(spr_pixel_1x1, 0, _px0 - _hw, _py0 + _dy,
		_hw * 2 + 1, 1, 0, _rim, 1);
	var _iw = _hw - 3;
	if (_iw > 0)
		draw_sprite_ext(spr_pixel_1x1, 0, _px0 - _iw, _py0 + _dy,
			_iw * 2 + 1, 1, 0, _face, 1);
}
// the specular pip: one bright mark up and left, the whole reason the
// disc reads as convex rather than as a printed circle
draw_sprite_ext(spr_pixel_1x1, 0, _px0 - 3, _py0 - 4, 2, 2, 0,
	merge_colour(tint, c_white, .8), .85);

// ---- the combo ring ----
// While a throw still has bounce-resist banked, an arc of pips rides the
// rim - one per remaining near-frictionless bounce. It is the only
// visible trace of the combo resource, and watching it spend down is
// what makes a long throw tense rather than just long.
if (resist > 0) {
	for (var _i = 0; _i < min(resist, 12); _i++) {
		var _pa = -90 + (_i / max(1, min(resist0, 12))) * 360;
		draw_sprite_ext(spr_pixel_1x1, 0,
			floor(_px0 + lengthdir_x(r + 2, _pa)) - 1,
			floor(_py0 + lengthdir_y(r + 2, _pa)) - 1,
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
