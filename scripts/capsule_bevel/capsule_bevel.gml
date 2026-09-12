/// @description capsule_bevel(h) -> the inset table that rounds a plate of height h
/// THE ROUND END, by height. One entry per row in from the top (and,
/// mirrored, the bottom): how many pixels the row starts in from the
/// plate's edge. It is a circle's profile - a quarter round of radius
/// h/2, capped at 9 so a tall plate (the inspector) gets a rounded
/// CORNER rather than a semicircular end - stamped to whole pixels.
/// At the deck's 11 it gives [3, 1], within a pixel of the endcap
/// sprite; at DE's 13 [4, 2, 1] against its [5, 3, 1, 1]; at the
/// upgrade rows' 18 [6, 4, 3, 2, 1, 1] - the "well rounded" ends he
/// asked for (2026-09-12). draw_capsule uses it when no table is given.
/// @param h   the plate's height in px
function capsule_bevel(_h) {
	var _r = min(_h * .5, 9);
	var _o = [];
	for (var _k = 0; _k < ceil(_r); _k++) {
		var _d = _r - .5 - _k;             // the row's centre, from the arc's centre
		var _in = _r - sqrt(max(0, _r * _r - _d * _d));
		_in = round(_in);
		if (_in <= 0) break;
		array_push(_o, _in);
	}
	return _o;
}
