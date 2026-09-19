/// @description exped_fight_new(trip, [kind], [count], [lvadd]) -> a fight (cbt_fight_new)
/// THE CREW THAT IS STILL UP, as pawns off their sheets (sprite_pawn:
/// class, level, gear, skills - the tech demo's engine, his call
/// 2026-09-14), against A PACK of the region's level: one to three
/// (count -1; his call: never the party's size) or a given number, of a given kind ("" = the
/// roster's roll), lvadd levels above the world (foe_gen). A crew of two
/// or three carries a little of its BONDS into every member's hit
/// (exped_bond, up to +10), and the notepad's studied kinds. The struct
/// is what the combat window reads; each party pawn remembers its trip
/// index (mi) for the hp write-back. The pack's xp is the kill's pay.
/// THE HAZARD (2026-09-15): the place's (exped_hazard) cuts a bare
/// member's lane (cbt_hazards); who holds it and who is bare goes on the
/// fight (f.hazard) and into the diary once a place.
/// opts (2026-09-15) = { boss : true, name : "..." } - the first foe is a
/// BOSS (foe_gen's budget x1.4) under that name (the bounty kind).
function exped_fight_new(_tr, _kind = "", _count = -1, _lvadd = 0, _opts = undefined) {
	var _d  = _tr.dest;
	var _party = [];
	var _bal = cbt_balance();
	var _hzr = exped_hazard(_tr), _hz = _hzr.hz, _bare = [], _held = [];
	var _n = array_length(_tr.sids);
	var _bsum = 0, _bn = 0;
	for (var _a = 0; _a < _n; _a++) for (var _b = _a + 1; _b < _n; _b++) { _bsum += exped_bond(_tr.sids[_a], _tr.sids[_b]); _bn++; }
	var _bonus = (_bn > 0) ? min(10, (_bsum / _bn) / 10) : 0;
	for (var _k = 0; _k < _n; _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _pw = sprite_pawn(_sp, _tr.hp[_k], (is_array(_tr[$ "mp"]) && _k < array_length(_tr.mp)) ? _tr.mp[_k] : undefined);
		if (_pw.ab.rest_hp != 0 && _pw.hp > 0) { _pw.hp = clamp(_pw.hp + _pw.maxhp * _pw.ab.rest_hp / 100, 1, _pw.maxhp); _tr.hp[_k] = _pw.hp; }   // (well-rested: a little back walking in - 2026-09-17; walks in tired, the flaw, the other way)
		// THE AURAS (the second roster, 2026-09-17): captain / shieldwall / cheerleader / lucky charm / medic - the crew's summed, itself included
		var _aur = exped_party_ab(_tr);
		if (_aur.aura_atk > 0) { _pw.atk *= 1 + _aur.aura_atk / 100; _pw.mag *= 1 + _aur.aura_atk / 100; }
		if (_aur.aura_def > 0) { _pw.def *= 1 + _aur.aura_def / 100; _pw.mdef *= 1 + _aur.aura_def / 100; }
		if (_aur.aura_hit > 0) _pw.hit *= 1 + _aur.aura_hit / 100;
		if (_aur.aura_luck > 0) { _pw.luck += _aur.aura_luck; _pw.crit_rate += _aur.aura_luck * .5; }
		_pw.heal_aura = _aur.aura_heal;   // (cbt_heal reads it - the ab struct itself is never touched)
		_pw.hit += _bonus;
		_pw.mi = _k;
		_pw.studied = sprite_notes_kinds(_sp);
		if (is_struct(_hz)) {
			var _ho = cbt_hazard_hold(_sp, _hz);
			// no hold: a TONIC in the pocket is drunk at the door (2026-09-16); a NOTE on the hazard halves the bite
			if (!_ho.ok) {
				var _shz = sprite_sheet(_sp);
				for (var _tj = 0; _tj < array_length(_shz.inv); _tj++) if ((_shz.inv[_tj][$ "slot"] ?? "") == "use" && _shz.inv[_tj].kind == "tonic") { array_delete(_shz.inv, _tj, 1); _ho = { ok : true, by : "a tonic" }; array_push(_tr.log, _sp.name + " drank a tonic at the door. " + _hz.name + " will not bite"); save_mark_dirty(); break; }
			}
			if (_ho.ok) array_push(_held, _sp.name + " (" + _ho.by + ")");
			else if (sprite_note_has(_sp, "haz:" + _hz.key) || _pw.ab.hazard > 0) {   // (a note, or danger sense - 2026-09-17)
				_pw[$ _hz.lane] *= sqrt(_hz.f);
				if (_hz.lane == "spd") { _pw.eva = _pw.spd * _bal.spd_to_eva; _pw.tic_spd = _bal.tic_spd_base + sqrt(max(0, _pw.spd)) / _bal.tic_spd_div; }
				array_push(_held, _sp.name + (sprite_note_has(_sp, "haz:" + _hz.key) ? " (a note, half)" : " (danger sense, half)"));
			}
			else {
				_pw[$ _hz.lane] *= _hz.f;
				if (_hz.lane == "spd") { _pw.eva = _pw.spd * _bal.spd_to_eva; _pw.tic_spd = _bal.tic_spd_base + sqrt(max(0, _pw.spd)) / _bal.tic_spd_div; }   // (the derived pair follows)
				_pw.haz = _hz.key;
				array_push(_bare, _sp.name);
			}
		}
		array_push(_party, _pw);
	}
	var _foes = [], _xp = 0;
	// THE PACK (his call, 2026-09-15: "not based off my party size"): a
	// count asked for, or one to three - one 35%, two 40%, three 25%
	var _nf = _count;
	if (_nf <= 0) { var _pr = random(100); _nf = (_pr < EXPED_PACK_W1) ? 1 : ((_pr < EXPED_PACK_W1 + EXPED_PACK_W2) ? 2 : 3); }
	_tr.fights = (_tr[$ "fights"] ?? 0) + 1;
	// THE LAND'S OWN (the foes pass, 2026-09-15): no kind asked for = each of
	// the pack is one of the kinds that haunt the place the crew stands on
	// (or the road's far end) - picked by the foe's seed, so the pack replays
	var _lrg = exped_region(_tr), _lni = exped_hazard(_tr).ni;
	var _lseas = region_season(_tr.dest, _lrg).idx;   // (the season's visitors - foe_kinds_at, 2026-09-16)
	if (!region_season(_tr.dest, _lrg).on) _lseas = -1;
	var _lkinds = foe_kinds_at(is_struct(_tr[$ "road"]) ? "road" : _lrg.nodes[clamp(_lni, 0, array_length(_lrg.nodes) - 1)].kind, _lseas);
	// A PLAGUE OF RATS (region_event, 2026-09-16): rats in every fight the region rolls, three times over
	var _lev = region_event(_tr.dest, _tr[$ "rgi"] ?? 0);
	if (is_struct(_lev) && _lev.kind == "rats") repeat (3) array_push(_lkinds, "rat");
	if (is_struct(_tr[$ "road"])) { var _rk = foe_kinds_at(_lrg.nodes[clamp(_lni, 0, array_length(_lrg.nodes) - 1)].kind, _lseas); for (var _q2 = 0; _q2 < array_length(_rk); _q2++) if (!array_contains(_lkinds, _rk[_q2])) array_push(_lkinds, _rk[_q2]); }   // (a road: the road's own and the land it crosses)
	for (var _j = 0; _j < _nf; _j++) {
		var _seed = (_d.seed ^ (_tr.id * 7919) ^ (_tr.fights * 104729) ^ (_j * 15485863)) & $7fffffff;
		var _fk = (_kind == "") ? _lkinds[hash_mix(_seed, 313) mod array_length(_lkinds)] : _kind;
		var _foe = foe_gen(exped_trip_lv(_tr) + _lvadd + ((_seed mod 3 == 0) ? 1 : 0), _seed, _fk, (_j == 0 && is_struct(_opts)) ? (_opts[$ "boss"] ?? undefined) : undefined, (_j == 0 && is_struct(_opts)) ? (_opts[$ "variant"] ?? "") : "");
		if (_j == 0 && is_struct(_opts) && is_string(_opts[$ "name"])) { _foe.name = _opts.name; _foe.named = true; }
		// LEADERLESS (q262): a kind without its chief in this region comes in at FOE_LEADERLESS of itself
		var _wk = foe_weak(_d, _tr[$ "rgi"] ?? 0, _fk);
		if (_wk < 1) {
			_foe.hp *= _wk; _foe.maxhp *= _wk; _foe.hpmax *= _wk; if (!is_undefined(_foe[$ "maxhp_real"])) _foe.maxhp_real *= _wk;
			_foe.atk *= _wk; _foe.def *= _wk; _foe.mag *= _wk; _foe.mdef *= _wk; _foe.hit *= _wk;
			_foe.leaderless = true;
		}
		array_push(_foes, _foe);
		_xp += foe_xp(_foe);
	}
	var _f = cbt_fight_new(_party, _foes);
	if (_foes[0][$ "leaderless"] ?? false) cbt_log(_f, "the " + _foes[0].kind + " here are leaderless - weaker for it");   // (q262)
	_f.tr = _tr;   // (the trip, for the pocket: exped_drink at a turn's start, the totem when one falls - 2026-09-16; a fight is never saved)
	_f.xp = _xp;
	// the hazard on the fight, and the diary's word on it (once a place: the
	// crew notices it going in, not every room)
	if (is_struct(_hz)) {
		var _rg = exped_region(_tr);
		var _pn = _rg.nodes[clamp(_hzr.ni, 0, array_length(_rg.nodes) - 1)].name;
		_f.hazard = { key : _hz.key, name : _hz.name, hold : _hz.hold, bare : _bare, held : _held, place : _pn };
		var _hk = string(_hzr.ni) + ":" + _hz.key;
		if ((_tr[$ "haz_said"] ?? "") != _hk) {
			_tr.haz_said = _hk;
			var _where = _hz.name + " of " + _pn + ": ";
			if (array_length(_bare) == 0)      array_push(_tr.log, _where + "the crew holds it - " + exped_crew_txt(_held));
			else if (array_length(_held) == 0) array_push(_tr.log, _where + exped_crew_txt(_bare) + " " + _hz.bite);
			else                               array_push(_tr.log, _where + exped_crew_txt(_bare) + " " + _hz.bite + "; " + exped_crew_txt(_held) + ((array_length(_held) > 1) ? " hold it" : " holds it"));
			if (array_length(_bare) > 0) exped_say(_tr, "hazard", undefined, .6);   // (the voice pass: a bare one speaks)
		}
		if (array_length(_bare) > 0) cbt_log(_f, _hz.name + ": " + exped_crew_txt(_bare) + " " + _hz.bite);
	}
	exped_drink_open(_tr, _f);   // THE POCKET AT THE DOOR (2026-09-17): the buffs, the wards, the regen, the growth
	return _f;
}
