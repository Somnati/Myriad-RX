/// @description ram_oc(k) -> { mult, cost }
/// THE OVERCLOCK LADDER (his design, 2026-09-12): notch k (0..RAM_OC_N-1)
/// past the end of a track runs the thing at `mult` x the track's end
/// and costs `cost` x the track's end price. x1.2 / x1.5 / x2 for
/// x1.6 / x2.2 / x3 - the price per unit of gain climbs notch by notch
/// (the twin checks it), so the last notch is the expensive one. ONE ladder for every overclockable
/// track (speeds, the autotapper, the timers), so the panel can draw
/// them all the same way. Tune here (and datafiles/ram_twin.py).
/// @param k   the notch
function ram_oc(_k) {
	static _mult = [1.2, 1.5, 2];
	static _cost = [1.6, 2.2, 3];
	_k = clamp(floor(_k), 0, RAM_OC_N - 1);
	return { mult : _mult[_k], cost : _cost[_k] };
}
