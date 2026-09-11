/// @description battery_lasts([charge]) - seconds of absence the charge
/// covers at the current offline rates: charge / battery_draw. With
/// nothing drawing it lasts forever (returns a very large number, so
/// the panel prints "no draw" rather than dividing by zero).
/// @param [charge]   defaults to the charge held
function battery_lasts(_charge = -1) {
	battery_init();
	if (_charge < 0) _charge = g.battery.charge;
	var _d = battery_draw();
	if (_d <= 0) return 1000000000000;
	return _charge / _d;
}
