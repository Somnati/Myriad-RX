/// @description exped_fork_choose(trip, k, [by_player]) - THE CHOICE MADE: the diary's line (who chose), the fork cleared, its held seconds owed to the agent, the template resolved (q258)
function exped_fork_choose(_tr, _k, _player = false) {
	var _fk = _tr[$ "fork"];
	if (!is_struct(_fk)) return;
	var _rg = exped_region(_tr);
	_k = clamp(_k, 0, array_length(_fk.choices) - 1);
	_fk.chosen = _k; _fk.by = _player ? "you" : "";
	var _lead = "the crew";
	for (var _i = 0; _i < array_length(_tr.sids); _i++) if (_tr.hp[_i] > 0) { _lead = _tr.names[_i]; break; }
	array_push(_tr.log, (_player ? "you chose " : (_lead + " chose ")) + _fk.choices[_k].txt + ".");
	_tr.fork = undefined;
	_tr.fork_pay = (_tr[$ "fork_pay"] ?? 0) + (_fk[$ "held"] ?? 0);
	if (_fk.kind == "shortcut") exped_fork_shortcut(_tr, _rg, _fk, _k);
	else exped_fork_encounter(_tr, _rg, _fk, _k);
}
