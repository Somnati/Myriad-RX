/// @description ability_flavor(value, "label", "add", color)
/// attaches a live stat line to the ability declared by the PREVIOUS
/// ability() call - the card documents its own current contribution
/// ("probe speed +25%"). up to 5 lines stack per card. the cursor
/// rewinds one and re-advances so consecutive flavor calls hit the
/// same card (Myriad's mechanism, kept).
/// color: -1 = default seagreen, else a color. label "" = bare line
/// (the red [requires ...] notes).
function ability_flavor(_val, _label, _add, _col) {
	if (a != _a - 1) exit;      // previous call didn't materialize here
	if (_input == -1) exit;     // previous ability is locked
	if (flavor >= 5) exit;
	_a -= 1;

	flavor_text[flavor] = string(_label) + " " + string(_val);
	if (_add != "") flavor_text[flavor] += " " + string(_add);
	if (_label == "") flavor_text[flavor] = string(_val);

	flavor_color[flavor] = c_seagreen;
	if (is_real(_col) && _col >= 0) flavor_color[flavor] = _col;

	flavor++;
	_a += 1;
}
