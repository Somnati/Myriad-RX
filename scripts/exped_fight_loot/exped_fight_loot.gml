/// @description exped_fight_loot(trip, fight) - what a won fight leaves behind (his ask, 2026-09-15)
/// EXPED_DROP% of wins: credits (a few, by the pack's size and the
/// world's tier) or a piece of gear at the fight's level (the house
/// rarity ladder), handed to a random member who is up (sprite_take:
/// worn / pocketed / binned) - the diary's "+ temoo acquired ..." line.
/// A boss always drops, and drops gear.
function exped_fight_loot(_tr, _f) {
	var _boss = false;
	for (var _j = 0; _j < array_length(_f.foes); _j++) if (_f.foes[_j][$ "boss"] ?? false) _boss = true;
	var _fab = exped_party_ab(_tr);   // (magpie / treasure sense, 2026-09-17)
	if (!_boss && !roll_perc(EXPED_DROP * max(0, 1 + _fab.finds / 100))) {
		// THE PICKPOCKET (the second roster): when nothing dropped, a chance of a coin or two off the bodies anyway
		if (_fab.pick > 0 && roll_perc(_fab.pick)) { var _pc = 1 + irandom(1); _tr.credits += _pc; exped_tally(_tr, "earned", _pc); array_push(_tr.log, "+ " + string(_pc) + " credits, picked off the bodies"); }
		return;
	}
	var _d = _tr.dest;
	var _nf = array_length(_f.foes);
	if (!_boss && roll_perc(55)) {
		var _c = irandom_range(1, 2) * _nf + _d.tier - 1;
		_c = max(1, round(_c * (1 + _fab.scav / 100)));   // (the scavenger - 2026-09-17)
		_tr.credits += _c;
		exped_stat("finds"); exped_tally(_tr, "earned", _c);
		array_push(_tr.log, "+ " + string(_c) + " credits " + choose("off the bodies", "in a pouch one of them had", "scattered in the fight", "that they will not need now"));
		return;
	}
	var _up = [];
	for (var _k = 0; _k < array_length(_tr.hp); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
	if (array_length(_up) == 0) return;
	var _who = _up[irandom(array_length(_up) - 1)];
	var _sp = exped_sprite(_tr.sids[_who]);
	if (is_undefined(_sp)) return;
	// a NAMED boss's drop carries its name, a rung higher again (the proc-gear pass, 2026-09-15); everything is tagged by the place
	var _own = "";
	for (var _j = 0; _j < array_length(_f.foes); _j++) if ((_f.foes[_j][$ "named"] ?? false) && _own == "") _own = _f.foes[_j].name;
	var _rar = clamp(calculate_rarity(luck_rate(_d.rate) + (exped_party_luck(_tr) + _fab.loot) * 12, .3, .03, 800, 14) + (_boss ? 1 : 0) + ((_own != "") ? 1 : 0), 0, 13);
	var _rgf = exped_region(_tr), _tagf = _rgf.nodes[clamp(_tr[$ "pos"] ?? 0, 0, array_length(_rgf.nodes) - 1)].kind;
	// a treasure off the bodies three times in ten (2026-09-17), else a piece of gear
	var _ist = (_own == "" && roll_perc(30));
	var _it = _ist ? treasure_gen(irandom($7fffffff), _rar, _d.tier) : gear_gen(choose("w1", "w2", "armor", "talis"), exped_trip_lv(_tr), _rar, irandom($7fffffff), _tagf, _own);
	var _tk = sprite_take(_sp, _it, exped_party_up(_tr));   // (the party hands it round - 2026-09-16)
	if (_tk[$ "dumb"] ?? false) exped_tally(_tr, "mist", 1, _sp); else exped_tally(_tr, "items");   // (the tally, 2026-09-16)
	exped_stat("finds"); if (!_ist) exped_stat("gear_found"); sprite_led(_sp, "finds");
	array_push(_tr.finds, { kind : "gear", rar : _rar, txt : _tk.txt, col : _it.col, item : _it });
	// THE LINE IS sprite_take's TRUTH (q268; his report: "Nene acquired a slingshot and put it on... turns out noobroo was
	// given it"): a find handed round says who took it; the hp ceiling follows the one who WEARS it
	array_push(_tr.log, "+ " + ((_tk[$ "given"] ?? -1) >= 0 ? _tk.txt : (_sp.name + " acquired \"" + _it.name + "\"" + (_tk.worn ? " - and put it on" : (_tk.kept ? " - into the pocket" : " - and threw it away")))));
	if (_tk.worn) exped_hp_refresh(_tr, _tk[$ "given"] ?? _sp.id);
	exped_note_beat(_tr, "find", .15, _it.name);
}
