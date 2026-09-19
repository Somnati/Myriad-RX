/// @description exped_fork_shortcut(trip, region, fork, k) - THE SHORTCUT resolved: the road as planned (k 0), or the way through on a check - and its MISHAP WITH GEOGRAPHY when the check fails (q258)
/// Made it: the road to the far node in the shortcut's hours (a twenty:
/// four fifths of them), the plan picked up from there. Failed: the
/// mishap the land and the weather choose -
///   slip     (a wet pass or slope) a bruise on one (a one: two) and the
///            WRONG SIDE OF THE RIDGE - a neighbour of the wild node that
///            is not the one they wanted; the plan thrown away, decided
///            afresh where they come out
///   lost     (fog, the dark in the woods, a whiteout, a sandstorm) the
///            same wrong side, no bruise, the hours by a third more
///   stuck    (bogged in a wet marsh, a tree down in a storm, the ford up)
///            two hours on the way through
///   shut     (a storm on the pass or the shore) turned back: an hour lost
///            and then the road as planned
///   exposed  (snow on a pass, the tundra, the desert by day) the cold or
///            the heat on everyone bare of it (cbt_hazard_hold - hide, a
///            cloak, a robe, a torch hold the cold; a cloak, leather, a
///            bead the heat), an hour longer
///   scramble (fair weather, bad luck) an hour longer than the map said
/// A natural one adds an hour and a worse bruise. Never a death (a bruise
/// stops at 1 hp), never gear (his call). Every mishap is a mistake on
/// the tally
function exped_fork_shortcut(_tr, _rg, _fk, _k) {
	var _path = _tr.path, _pos = _tr.pos;
	if (_k == 0) {
		var _h0 = region_hours(_rg, _pos, _path[0]);
		_tr.road = { a : _pos, b : _path[0], d : _h0, t : 0 };
		array_push(_tr.log, "set out for " + _rg.nodes[_path[0]].name + " (" + string(_h0) + "h)");
		return;
	}
	var _land = _fk.land, _xnm = _rg.nodes[_fk.x].name, _ynm = _rg.nodes[_fk.y].name;
	var _ck = exped_check(_tr, _fk.dc, _fk.mods, "the " + _land + ((_fk.wx != "clear") ? " in the " + _fk.wx : "") + (_fk.night ? ", in the dark" : ""));
	array_push(_tr.log, _ck.txt);
	var _rest = [];
	for (var _i = _fk.k; _i < array_length(_path); _i++) array_push(_rest, _path[_i]);
	if (_ck.ok) {
		var _h = (_ck.crit == 1) ? max(1, round(_fk.through * .8)) : _fk.through;
		_tr.road = { a : _pos, b : _fk.y, d : _h, t : 0 }; _tr.path = _rest;
		array_push(_tr.log, (_ck.crit == 1) ? "clean through " + _xnm + ", faster than the map said. " + _ynm + " ahead." : "through " + _xnm + " toward " + _ynm + " (" + string(_h) + "h)");
		exped_stat("forks_made");
		// THE WAY WRITTEN DOWN (q260): a note on the land, one of the crew - exped_fork_mods reads it as +2 next time
		if (array_length(_tr.sids) > 0) { var _nsp = exped_sprite(_tr.sids[irandom(array_length(_tr.sids) - 1)]); if (!is_undefined(_nsp) && sprite_note(_nsp, "the " + _land + " by " + _xnm + ": there is a way through", "road:" + _land)) array_push(_tr.log, _nsp.name + " writes the way down."); }
		return;
	}
	var _bad = (_ck.crit == -1);
	var _up = [];
	for (var _i = 0; _i < array_length(_tr.sids); _i++) if (_tr.hp[_i] > 0) array_push(_up, _i);
	var _xn = region_neighbors(_rg, _fk.x), _cands = [];
	for (var _j = 0; _j < array_length(_xn); _j++) if (_xn[_j].j != _fk.y && _xn[_j].j != _pos) array_push(_cands, _xn[_j].j);
	var _wrong = (array_length(_cands) > 0) ? _cands[irandom(array_length(_cands) - 1)] : -1;
	var _mis = "scramble";
	switch (_land) {
		case "mountains": case "hills":
			_mis = (_fk.wx == "rain") ? "slip" : ((_fk.wx == "snow") ? "exposed" : ((_fk.wx == "fog") ? "lost" : ((_fk.wx == "storm") ? "shut" : "scramble"))); break;
		case "forest": _mis = (_fk.wx == "fog" || _fk.night) ? "lost" : ((_fk.wx == "storm") ? "stuck" : "scramble"); break;
		case "marsh":  _mis = (_fk.wx == "rain" || _fk.wx == "storm") ? "stuck" : ((_fk.wx == "fog") ? "lost" : "scramble"); break;
		case "desert": _mis = (_fk.wx == "storm") ? "lost" : (_fk.night ? "scramble" : "exposed"); break;
		case "tundra": _mis = (_fk.wx == "snow" || _fk.wx == "storm") ? "lost" : "exposed"; break;
		case "coast":  _mis = (_fk.wx == "storm") ? "shut" : ((_fk.wx == "rain") ? "stuck" : "scramble"); break;
	}
	if (_wrong < 0 && (_mis == "slip" || _mis == "lost")) _mis = "stuck";
	if (array_length(_up) == 0) _mis = "scramble";   // (nobody standing to bruise - the hours alone)
	var _hx = _fk.through, _to = _fk.y, _npath = _rest, _line = "";
	var _nm = (array_length(_up) > 0) ? _tr.names[_up[irandom(array_length(_up) - 1)]] : "someone";
	switch (_mis) {
		case "slip": {
			var _n = min(array_length(_up), _bad ? 2 : 1), _hit = [];
			for (var _i = 0; _i < _n; _i++) { var _w = _up[(_i + irandom(array_length(_up) - 1)) mod array_length(_up)]; if (array_contains(_hit, _w)) continue; array_push(_hit, _w); _tr.hp[_w] = max(1, _tr.hp[_w] - _tr.hpmax[_w] * (_bad ? .18 : .12)); }
			_to = _wrong; _npath = []; _hx = _fk.through + 1;
			_line = _tr.names[_hit[0]] + " slipped on the wet " + ((_land == "mountains") ? "scree" : "slope") + ((array_length(_hit) > 1) ? " and took " + _tr.names[_hit[1]] + " down too" : "")
			        + ". they came out on the wrong side, at " + _rg.nodes[_wrong].name + ".";
		} break;
		case "lost": {
			_to = _wrong; _npath = []; _hx = max(1, round(_fk.through * 1.3));
			var _in = (_fk.wx == "fog") ? "fog" : ((_fk.wx == "storm") ? ((_land == "desert") ? "sand" : "storm") : ((_fk.wx == "snow") ? "whiteout" : "dark"));
			_line = "lost the line in the " + _in + " and came out at " + _rg.nodes[_wrong].name + " instead.";
		} break;
		case "stuck": {
			_hx = _fk.through + 2;
			if (_land == "marsh") _line = "bogged to the knee for two hours. " + _nm + " lost a boot and got it back.";
			else if (_land == "coast") _line = "the ford was up. two hours waiting for it to drop.";
			else _line = "a tree across the way. two hours to get round it.";
		} break;
		case "shut": {
			_to = _path[0]; _npath = _path; _hx = region_hours(_rg, _pos, _path[0]) + 1;
			_line = (_land == "coast") ? "the storm turned them back at the water. an hour lost, then the road." : "the storm shut the pass. an hour lost, then the road.";
		} break;
		case "exposed": {
			_hx = _fk.through + 1;
			var _all = cbt_hazards(), _hz = undefined, _hk = (_land == "desert") ? "heat" : "cold";
			for (var _i = 0; _i < array_length(_all); _i++) if (_all[_i].key == _hk) _hz = _all[_i];
			var _bare = [];
			for (var _i = 0; _i < array_length(_up); _i++) {
				var _sp = exped_sprite(_tr.sids[_up[_i]]);
				if (is_undefined(_sp) || (is_struct(_hz) && cbt_hazard_hold(_sp, _hz).ok)) continue;
				_tr.hp[_up[_i]] = max(1, _tr.hp[_up[_i]] - _tr.hpmax[_up[_i]] * (_bad ? .10 : .06));
				array_push(_bare, _tr.names[_up[_i]]);
			}
			if (array_length(_bare) == 0) _line = (_land == "desert") ? "the heat across the flats. everyone had something against it. an hour longer." : "snow on the pass. everyone had something warm. an hour longer.";
			else _line = (_land == "desert") ? "the heat across the flats. " + exped_crew_txt(_bare) + " could not keep the pace." : "snow on the pass. an hour of it, and the cold got into " + exped_crew_txt(_bare) + ".";
		} break;
		default: _hx = _fk.through + 1; _line = "a scramble. an hour longer than the map said."; break;
	}
	if (_bad) { _hx += 1; _line += " everything that could go wrong did."; }
	_tr.road = { a : _pos, b : _to, d : _hx, t : 0 };
	_tr.path = _npath;
	exped_tally(_tr, "mist");
	array_push(_tr.log, _line);
	if (_mis == "lost" || _mis == "slip") exped_say(_tr, "lost", undefined, .5);
}
