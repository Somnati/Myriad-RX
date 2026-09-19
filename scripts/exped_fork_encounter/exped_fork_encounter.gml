/// @description exped_fork_encounter(trip, region, fork, k) - THE ENCOUNTER resolved: fight (k 0), or go round on a check - failed, the fight anyway on their terms (the foes act first) (q258)
function exped_fork_encounter(_tr, _rg, _fk, _k) {
	if (_k == 1) {
		var _ck = exped_check(_tr, _fk.dc, _fk.mods, "going round" + ((_fk.wx != "clear") ? " in the " + _fk.wx : "") + (_fk.night ? ", in the dark" : ""));
		array_push(_tr.log, _ck.txt);
		if (_ck.ok) {
			if (is_struct(_tr[$ "road"])) _tr.road.t = max(0, _tr.road.t - EXPED_HOUR * ((_ck.crit == 1) ? .5 : 1));
			array_push(_tr.log, (_ck.crit == 1) ? "round them without a sound, and hardly a step out of the way." : "went round them the long way. an hour lost, nobody seen.");
			exped_stat("forks_made");
			return;
		}
		array_push(_tr.log, "tried to go round. " + ((_fk.n > 1) ? "they were" : "it was") + " waiting at the other end.");
		exped_tally(_tr, "mist");
	}
	_tr.fight = exped_fight_new(_tr, _fk.foe, _fk.n, 0);
	array_push(_tr.log, "on the road: " + _tr.fight.b.name + ((array_length(_tr.fight.foes) > 1) ? " and company" : "")
	          + ((_k == 1) ? " - on their terms" : " " + choose("block the way", "come out of the trees", "were waiting", "had the same idea")));
	if (_k == 1) for (var _j = 0; _j < array_length(_tr.fight.foes); _j++) _tr.fight.foes[_j].tic += _tr.fight.foes[_j].tic_spd * 2;
	exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .7);
}
