/// @description upgrade_meter_tick(dt) - THE INVISIBLE METER that turns
/// up new offers. Myriad DE's syst_handle_upgrades Step_2, ported with
/// its nuances (his ask, 2026-09-17: "spawn how they do in DE where a
/// invisible meter builds up based of gameplay and then spawns one...
/// implement that exactly how its done in myriad").
/// @param dt  real seconds this frame (delta / 60 - the time bank does
///            not hurry it; nothing DE had did)
///
/// TWO METERS, IN SERIES:
///   utic  a CLOCK in DE's tick units (5 a frame at 60 - DE's `tdiv`
///         quirk, its `ufull` count was commented out so tdiv is
///         always 5). At tmin x 2 x p it sets the HIT. p = lerp(1, .2,
///         credits held / 10000): a hoarded purse hurries the next
///         offer, DE's nudge to spend.
///   uxp   GAMEPLAY xp: +1 a second for being here, +1 a tap press,
///         +.05 a held tap, a share of every upgrade bought and sold
///         (upgrade_meter_feed). When the hit lands uxp starts from 0,
///         and the offer spawns once uxp reaches umax, rolled 50..100
///         each time.
/// So an offer is never sooner than ~24 s x p after the last, and then
/// as soon as you have PLAYED 50..100 xp worth.
///
/// DE's OTHER RULES, kept: a FULL table resets everything (fill it and
/// the clock waits for a sale or a purchase); no xp before the first
/// dial; the FIRST offer ever is handed over at once (DE's tutorial
/// sets uhit + uxp 100); before the first PURCHASE only one offer sits
/// at a time (DE pins the clock until total_upgrades > 0 - here it pins
/// only while an unbought offer is on the table, so selling that first
/// offer cannot strand the meter, which DE's rule would); OFFLINE owes
/// offers by thresholds (offline_replay -> uoff, forced one a frame on
/// return). Left out: the staged early rolls of DE's instant-install
/// ability and the chain-buy hit (neither ability is in the RX deck),
/// and the dial-autonomy hurry (RX has no autonomy upgrade).
function upgrade_meter_tick(_dt) {
	if (!variable_global_exists("dial")) return;
	upgrade_init();
	if (!unfold_has("upgrades")) return;
	var _m = g.upg.meter;

	// the open slot, top down - and whether an unbought offer sits
	var _n = upgrade_slots();
	var _os = -1, _offer = false;
	for (var _i = 0; _i < _n; _i++) {
		var _s = g.upg.slot[_i];
		if (!is_struct(_s)) { if (_os == -1) _os = _i; }
		else if (_s.tier <= 0) _offer = true;
	}
	// A FULL TABLE RESETS THE METER (DE: "if os = -1")
	if (_os == -1) { _m.uhit = false; _m.utic = 0; _m.uxp = 0; _m.uoff = 0; return; }

	// THE FIRST OFFER EVER is handed over (DE's tutorial moment)
	if (g.upg.rolls == 0) { _m.uhit = true; _m.uxp = 100; }

	// xp: one a second for being here
	_m.uxp += _dt;
	// nothing before the first dial (DE: level[0] = 0 and no upgrades)
	if (g.dial[0].level <= 0 && g.upg.total == 0) _m.uxp = 0;

	// the clock, DE's 5 ticks a frame
	_m.utic += 300 * _dt;
	// before the first purchase, one offer at a time
	if (g.upg.total == 0 && !_m.uhit && _offer) _m.utic = 0;

	// THE HIT: two minutes of DE ticks, hurried by the purse
	var _cr = (g.credits >= arb(1)) ? unarb(g.credits) : 0;
	var _p  = lerp(1, .2, clamp(_cr / 10000, 0, 1));
	var _was = _m.uhit;
	if (_m.utic >= 7200 * _p) _m.uhit = true;
	if (!_was && _m.uhit) _m.uxp = 0;   // DE: the hit opens the xp run from zero

	// THE SPAWN: the hit and the xp, or an offer owed from an absence
	var _force = (_m.uoff > 0);
	if ((_m.uhit && _m.uxp >= _m.umax) || _force) {
		_m.uxp  = 0;
		_m.uhit = false;
		_m.utic = 0;
		_m.umax = random_range(50, 100);
		if (_m.uoff > 0) _m.uoff -= 1;
		var _r = upgrade_roll(_os);
		if (is_struct(_r) && !_force) {
			var _e = upgrade_entry(_r.id);
			assign_banner("upgrade found - " + ((_e == -1) ? _r.id : _e.name),
				(_e == -1) ? c_white : _e.col, c_black);
			play_sound_ext(snd_obj_new, .9, 1.1, .5, 1);
		}
	}
}
