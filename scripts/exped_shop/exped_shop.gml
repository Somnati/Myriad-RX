/// @description exped_shop(trip) - the crew consults the shops (his pitch: on their own, with their own credits)
/// One offer a member: an item of the region's level, rarer in bigger
/// places; the price 2 + lv/3 + 2 a rung. Bought only if the pocket
/// covers it AND it beats what is worn (gear_score, the class's eye) -
/// then sprite_take handles it, dumb moment included (yes, they can buy
/// it and bin it). Whatever is left of the pocket comes home.
function exped_shop(_tr) {
	var _rg = region_get(_tr.dest);
	var _nd = _rg.nodes[_tr.pos];
	var _rmax = 1;
	switch (_nd.kind) { case "village": _rmax = 1; break; case "town": _rmax = 2; break; case "city": _rmax = 3; break; }
	var _bought = 0;
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _slot = choose("w1", "w2", "armor", "talis");
		var _rar = irandom(_rmax);
		var _it = gear_gen(_slot, _rg.lv, _rar, irandom($7fffffff));
		var _price = 2 + floor(_rg.lv / 3) + 2 * _rar;
		// what it would replace
		var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
		var _cur = 0;
		if (_slot == "w1" || _slot == "w2") _cur = gear_score(_sp, _sh[$ _slot]);
		else {
			var _arr = _sh[$ _slot], _cap = (_slot == "armor") ? _c.armor : _c.talis;
			if (array_length(_arr) >= _cap) { _cur = infinity; for (var _i = 0; _i < array_length(_arr); _i++) _cur = min(_cur, gear_score(_sp, _arr[_i])); }
		}
		if (gear_score(_sp, _it) > _cur && _tr.credits >= _price) {
			_tr.credits -= _price;
			_bought += 1;
			var _tk = sprite_take(_sp, _it);
			array_push(_tr.log, _sp.name + " bought " + _it.name + " for " + string(_price) + " credits" + (_tk.worn ? "" : (_tk.kept ? " - and pocketed it" : " - " + string_delete(_tk.txt, 1, string_pos(" and ", _tk.txt) + 4))));
			if (_tk.worn) { _tr.hpmax[_k] = sprite_pawn(_sp).maxhp; _tr.hp[_k] = min(_tr.hp[_k], _tr.hpmax[_k]); }
		} else if (roll_perc(35)) {
			array_push(_tr.log, _sp.name + " looked at " + _it.name + " (" + string(_price) + " credits) and " + choose("walked out", "put it back", "decided against it", "could not afford it"));
		}
	}
	if (_bought == 0 && roll_perc(50)) array_push(_tr.log, "the shops of " + _nd.name + " had nothing worth the walk");
}
