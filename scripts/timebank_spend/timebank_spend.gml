/// @description timebank_spend();
/// This frame's SIM SECONDS - called ONCE per frame by syst_production,
/// before anything ticks.
///
/// At multiplier m each real second simulates m seconds and CONSUMES
/// (m-1) banked seconds. The result is handed to prod_dials and
/// credit_tick as their seconds budget - THE SAME LANES offline_replay
/// drives - so x10 for a minute is, by construction, the replay of ten
/// minutes. There is no second formula to drift.
///
/// An empty bank drops to x1 by itself, spending whatever was left over
/// exactly rather than stopping a frame early. That last honest frame
/// is worth the branch: a multiplier that vanished mid-second and left
/// a sliver unspent would be a rounding error the player paid for.
///
/// DELIBERATELY NOT MULTIPLIED: anything on the wall clock (the credit
/// dropper's cooldown is fine, it rides the same budget; the autosave
/// timer and the away clock are not), render/delta, and the REBIRTH RUN
/// CLOCK - the timeclamp measures the player's attention, not the sim's,
/// and accelerating it would let banked time buy its way past the
/// penalty the clamp exists to impose.
function timebank_spend() {
	timebank_init();
	var _tb = g.timebank;
	var _dt = delta / 60;            // real seconds this frame
	var _m  = max(1, _tb.spd);
	if (_m > 1) {
		var _need = (_m - 1) * _dt;
		if (_tb.bank >= _need) _tb.bank -= _need;
		else {
			_m = 1 + _tb.bank / max(_dt, 0.00001);
			_tb.bank = 0;
			_tb.spd  = 1;
			save_mark_dirty();
		}
	}
	_tb.live_m = _m;
	return _dt * _m;
}
