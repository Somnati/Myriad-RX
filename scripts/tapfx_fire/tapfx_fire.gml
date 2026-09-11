/// @description tapfx_fire(x, y, crit, n) - a tap PERFORMED in the money
/// room (tap_fire's visual branch): hand it to syst_tapfx, which turns
/// it into whichever effect the room's [fx] dropdown has picked. Nothing
/// happens if the room has no syst_tapfx (every room but the money room).
function tapfx_fire(_x, _y, _crit = false, _n = 1) {
	if (!instance_exists(syst_tapfx)) return;
	if (!syst_tapfx.__live()) return;
	syst_tapfx.fire(_x, _y, _crit, _n);
}
