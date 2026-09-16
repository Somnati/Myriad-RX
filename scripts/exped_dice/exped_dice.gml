/// @description exped_dice(trip) -> true when a game was played: THE TAVERN'S DICE (his pick, 2026-09-16)
/// Somebody sits down to a game of chance - the greedy and the brave
/// first - for a stake the stance sets (cautious one, steady one or
/// two, greedy two or three, never more than the pocket); the odds are
/// the house's, bent by the player's luck (sprite_luck: 42% + 2 a point,
/// 30..62). Won, the stake comes back doubled; lost, it is gone. A
/// greedy crew doubles or nothing once, half the time. The hand is
/// composed: the opponent, the game, the turn, the sum. Counts in the
/// ledger ("dice") and the tally (earned, or nothing).
function exped_dice(_tr) {
	if (_tr.credits < 1) return false;
	var _rg = exped_region(_tr), _nd = _rg.nodes[clamp(_tr.pos, 0, array_length(_rg.nodes) - 1)];
	var _stn = exped_stance(_tr), _pl = sprite_personalities();
	var _cand = [];
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp0 = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp0)) continue;
		array_push(_cand, _k);
		var _pn = _pl[clamp(_sp0[$ "pers"] ?? 0, 0, array_length(_pl) - 1)].name;
		if (_pn == "greedy" || _pn == "brave") array_push(_cand, _k);
	}
	if (array_length(_cand) == 0) return false;
	var _k2 = _cand[irandom(array_length(_cand) - 1)];
	var _sp = exped_sprite(_tr.sids[_k2]), _nm = _tr.names[_k2];
	var _stake = min(_tr.credits, (_stn.key == "greedy") ? irandom_range(2, 3) : ((_stn.key == "cautious") ? 1 : irandom_range(1, 2)));
	var _opp = choose("a drover", "a soldier with one boot", "the keeper's cousin", "a sprite with no eyebrows", "a very calm nun", "two farmers who turned out to be one farmer in a coat", "a tinker", "somebody's grandmother", "a man who said he never played");
	var _game = choose("dice", "cards", "knucklebones", "a coin", "the shell game", "dice again");
	var _p = clamp(42 + sprite_luck(_sp) * 2, 30, 62);
	var _won = roll_perc(_p);
	var _turn = _won ? choose("threw two sixes and looked surprised", "drew the one card that mattered", "called the coin in the air", "found the pea. it was under that one", "rolled doubles twice", "did not blink once")
	                 : choose("threw a six, then a one", "drew the queen of nothing", "called heads. it was a hen", "found the pea. it was not under that one", "knocked the dice into the fire", "blinked");
	var _line = _nm + " sat down to " + _game + " with " + _opp + " in the tavern at " + _nd.name + ". " + _turn + ". ";
	if (_won) {
		_tr.credits += _stake; exped_tally(_tr, "earned", _stake);
		_line += string(_stake) + ((_stake == 1) ? " credit" : " credits") + " won";
		// double or nothing: the greedy, once, half the time
		if (_stn.key == "greedy" && roll_perc(50)) {
			if (roll_perc(_p)) { _tr.credits += _stake; exped_tally(_tr, "earned", _stake); _line += ". doubled it. greedy, and right"; }
			else { var _back = min(_tr.credits, _stake * 2); _tr.credits -= _back; _line += ". went double or nothing and lost the lot. greedy"; exped_tally(_tr, "mist"); }
		}
	} else {
		_tr.credits -= _stake;
		_line += string(_stake) + ((_stake == 1) ? " credit" : " credits") + " gone" + choose("", ". " + _opp + " did not gloat. much", ". the pocket is lighter", ". " + _nm + " wants a rematch");
	}
	exped_stat("dice");
	array_push(_tr.log, _line);
	save_mark_dirty();
	return true;
}
