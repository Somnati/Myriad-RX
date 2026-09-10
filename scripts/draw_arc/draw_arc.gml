/// @description draw_arc(x, y, r, thick, frac, col, alpha, [start],
///              [clockwise], [segs]) - a circular bar: a ring of radius
///              r and thickness thick, filled frac (0..1) of the way
///              round from the start angle. Nothing is drawn at 0.
/// @param x
/// @param y
/// @param r          inner radius, px
/// @param thick      the band's width, px (grows outward from r)
/// @param frac       0..1 of the full turn
/// @param col
/// @param alpha
/// @param [start]    degrees, GM's compass (0 right, 90 up). Default 90:
///                   the bar starts at twelve o'clock, like a clock face
/// @param [clockwise] default true - twelve, three, six, nine
/// @param [segs]     segments for a FULL turn; the arc uses its share.
///                   Default 48: smooth at any radius this UI draws
///
/// ⚖️ THE REPLACEMENT FOR DE's draw_ring (his ask, 2026-09-10: "it did
/// use a script i grabbed somewhere else that drew a circular bar and
/// if you can build a better script i'd like you to"). That one took
/// ten positional arguments (maxsegments AND segments, a direction as
/// +1/-1, a total angle to divide), drew two draw_triangle_colour calls
/// per segment with a fourth colour argument that GM ignores, and left
/// its working variables (ax, ay, bx, i...) as INSTANCE variables on
/// whoever called it. This one is one triangle strip - the whole band
/// is a single primitive, so there are no seams between segments and
/// no doubled edges - takes a fraction rather than a segment count
/// (the caller has a 0..1 number and should not have to multiply it
/// by anything), and touches nothing outside its own locals.
///
/// Radians only at the trig; the interface is degrees, because every
/// other angle in this codebase is.
function draw_arc(_x, _y, _r, _th, _frac, _col, _a, _start = 90, _cw = true, _segs = 48) {
	_frac = clamp(_frac, 0, 1);
	if (_frac <= 0 || _a <= 0) return;
	var _n = max(1, ceil(_segs * _frac));
	var _sweep = 360 * _frac;
	var _dir = _cw ? -1 : 1;   // GM's angles grow counter-clockwise on screen
	var _r2 = _r + _th;
	draw_set_colour(_col);
	draw_set_alpha(_a);
	draw_primitive_begin(pr_trianglestrip);
	for (var _i = 0; _i <= _n; _i++) {
		var _ang = degtorad(_start + _dir * _sweep * (_i / _n));
		var _c = cos(_ang), _s = -sin(_ang);
		draw_vertex(_x + _c * _r,  _y + _s * _r);
		draw_vertex(_x + _c * _r2, _y + _s * _r2);
	}
	draw_primitive_end();
	draw_set_alpha(1);
}
