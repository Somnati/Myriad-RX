/// @description dice_mat_apply() - seat the chosen finish on the calling
/// die. Runs in obj_dice's scope; sets tint, metal, iri and ink.
///
/// Called from the Create AND whenever the setting changes, so switching
/// material in settings repaints dice already on the table rather than
/// waiting for a room change - see obj_dice's Step.
///
/// THE INK RULE is the tech demo's and it is worth keeping: unless a
/// finish names its own pip colour, the pips flip white or black by the
/// body's LUMINANCE. A fixed pip colour looks wrong on half a roster,
/// and picking it per material by hand is work that a contrast test
/// does correctly every time.
function dice_mat_apply() {
	var _t = dice_mat_config();
	var _id = variable_global_exists("dice_mat") ? g.dice_mat : "random";
	var _m = _t[0];
	for (var _i = 0; _i < array_length(_t); _i++)
		if (_t[_i].id == _id) { _m = _t[_i]; break; }

	mat_id = _m.id;

	if (_m.col < 0) {
		// the roll: the tech demo's own, kept exactly - a random hue and
		// a random point on the matte/metal slide, so no two dice match
		tint  = color_set_random();
		metal = random(1);
		iri   = 0;
	} else {
		tint  = _m.col;
		metal = _m.metal;
		iri   = _m.iri;
	}

	if (is_array(_m.ink)) {
		ink = _m.ink;
	} else {
		var _lum = (.299 * colour_get_red(tint) + .587 * colour_get_green(tint)
			+ .114 * colour_get_blue(tint)) / 255;
		ink = (_lum < .42) ? [.94, .94, .97] : [.08, .08, .12];
	}
}
