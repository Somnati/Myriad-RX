/// @description sprite_take(sprite, item) -> { txt, worn, kept } - the sprite handles a find
/// AUTO-EQUIP (his spec): better than what is worn in that slot kind
/// (gear_score, the class's eye) goes on and the old one goes into the
/// pocket; armor / talismans fill the class's slots first and then
/// replace the worst. Otherwise into the inventory; past SPRITE_INV the
/// lowest-scored item is trashed. THE DUMB MOMENT (his ask: "lazy and
/// dumb... sometimes they trash a better one for a dumb reason"): a
/// personality-sized chance the sprite bins an upgrade with a reason.
/// txt is the diary's truth line about it.
/// party (2026-09-16, his ask): the sprites on the journey with it - a find the finder cannot use goes to one who can wear
/// it, and a full pocket hands it to one with room, before anything is dropped. The diary line says who took it.
function sprite_take(_sp, _it, _party = undefined) {
	// A CONSUMABLE (2026-09-16): an elixir is drunk on the spot; the rest go in the pocket, no dumb moment about it
	if ((_it[$ "slot"] ?? "") == "use") {
		if (_it.kind == "elixir") return { txt : sprite_elixir(_sp, _it.line), worn : false, kept : false, elixir : true };
		var _shu = sprite_sheet(_sp);
		array_push(_shu.inv, _it);
		var _dru = sprite_inv_trim(_sp);
		save_mark_dirty();
		return { txt : _sp.name + " pocketed the " + _it.name + ((_dru != "") ? (", dropping " + _dru) : ""), worn : false, kept : true };
	}
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _sc = gear_score(_sp, _it);
	// the dumb moment: by personality (sleepy and grumpy the worst)
	var _pl = sprite_personalities();
	var _pn = _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].name;
	var _dumb = .07;
	switch (_pn) { case "sleepy": _dumb = .14; break; case "grumpy": _dumb = .12; break; case "curious": _dumb = .10; break;
	               case "smug": _dumb = .09; break; case "greedy": _dumb = .03; break; case "eager": _dumb = .06; break;
	               case "brave": _dumb = .07; break; case "dreamy": _dumb = .13; break; case "nervous": _dumb = .09; break;
	               case "proud": _dumb = .08; break; case "kind": _dumb = .06; break; case "sly": _dumb = .04; break; }
	var _why = choose("it clashed with the hat", "it looked heavy", "it was the wrong shade of grey", "it smelled like a decision",
	                  "it had a face on it", "too many buttons", "it was tuesday", "it made a noise", "the old one has sentimental value",
	                  "someone might want it back", "it was slightly warm");
	// is it better than what is worn?
	var _better = false, _old = undefined, _at = -1;
	if (_it.slot == "w1" || _it.slot == "w2") {
		_old = _sh[$ _it.slot];
		_better = is_undefined(_old) || (_sc > gear_score(_sp, _old));
	} else {
		var _arr = _sh[$ _it.slot];
		var _cap = (_it.slot == "armor") ? _c.armor : _c.talis;
		if (array_length(_arr) < _cap) { _better = true; _at = -1; }
		else {
			var _worst = infinity;
			for (var _i = 0; _i < array_length(_arr); _i++) { var _ws = gear_score(_sp, _arr[_i]); if (_ws < _worst) { _worst = _ws; _at = _i; } }
			_better = (_sc > _worst);
			_old = _arr[_at];
		}
	}
	_dumb *= max(.5, 1 - sprite_luck(_sp) * .05);   // (the lucky make fewer - luck, 2026-09-16)
	if (_better && random(1) < _dumb) {
		return { txt : _sp.name + " found " + _it.name + " and threw it away - " + _why, worn : false, kept : false, dumb : true };
	}
	if (_better) {
		if (_it.slot == "w1" || _it.slot == "w2") _sh[$ _it.slot] = _it;
		else if (_at < 0) array_push(_sh[$ _it.slot], _it);
		else { var _arr2 = _sh[$ _it.slot]; _arr2[@ _at] = _it; }   // (the array by reference)
		if (!is_undefined(_old)) array_push(_sh.inv, _old);
		var _t = _sp.name + " found " + _it.name + " and put it on";
		if (!is_undefined(_old)) _t += " (" + _old.name + " goes in the pocket)";
		sprite_inv_trim(_sp);
		save_mark_dirty();
		return { txt : _t, worn : true, kept : true };
	}
	// THE HANDOVER (2026-09-16): not better for this one - a mate on the journey who WOULD wear it takes it; a full pocket
	// hands it to a mate with room; only then the pocket (and its drop)
	if (is_array(_party)) {
		for (var _m = 0; _m < array_length(_party); _m++) {
			var _ms = _party[_m];
			if (_ms.id == _sp.id) continue;
			if (sprite_would_wear(_ms, _it)) {
				var _mt = sprite_take(_ms, _it);
				if (_mt.worn) return { txt : _sp.name + " found " + _it.name + " and handed it to " + _ms.name + ", who put it on", worn : true, kept : true, given : _ms.id };
				return { txt : _sp.name + " found " + _it.name + " and handed it to " + _ms.name, worn : false, kept : _mt.kept, given : _ms.id };
			}
		}
		if (array_length(_sh.inv) >= SPRITE_INV) {
			for (var _m = 0; _m < array_length(_party); _m++) {
				var _ms = _party[_m];
				if (_ms.id == _sp.id || array_length(sprite_sheet(_ms).inv) >= SPRITE_INV) continue;
				array_push(sprite_sheet(_ms).inv, _it);
				save_mark_dirty();
				return { txt : _sp.name + " found " + _it.name + " - no room, so " + _ms.name + " carries it", worn : false, kept : true, given : _ms.id };
			}
		}
	}
	// not better: into the pocket, and the pocket keeps its size
	array_push(_sh.inv, _it);
	var _dropped = sprite_inv_trim(_sp);
	save_mark_dirty();
	if (_dropped != "") return { txt : _sp.name + " found " + _it.name + " and pocketed it, dropping " + _dropped, worn : false, kept : true };
	return { txt : _sp.name + " found " + _it.name + " and pocketed it", worn : false, kept : true };
}
