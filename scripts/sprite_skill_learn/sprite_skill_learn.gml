/// @description sprite_skill_learn(sprite) -> the diary's line ("" = nothing happened)
/// A skill picked up on the road (his ask, 2026-09-15: "randomly learn
/// them while on adventures... as well as swap skills out they dont think
/// they need... like how they acquire gear"). A template of the class's
/// own (its tmpls) or, one time in four, any; a fresh seed. Room on the
/// sheet: learned. Full: kept only if the class rates it above its worst
/// (sprite_skill_value) - that one is forgotten - else it goes the way of
/// a silly item. Marks the save.
function sprite_skill_learn(_sp) {
	var _sh = sprite_sheet(_sp);
	var _c  = sprite_classes()[_sh.cls];
	var _tmpl = (random(1) < .75) ? _c.tmpls[irandom(array_length(_c.tmpls) - 1)] : irandom(4);
	var _seed = irandom($7fffffff);
	var _new = cbt_skill_gen(_seed, _tmpl);
	var _cap = max(0, SPRITE_SKILLS - 1);
	if (array_length(_sh.learned) < _cap) {
		array_push(_sh.learned, { tmpl : _tmpl, seed : _seed });
		save_mark_dirty();
		return _sp.name + " learned " + _new.name;
	}
	// full: the worst of what is known against the new one
	var _wi = -1, _wv = infinity;
	for (var _i = 0; _i < array_length(_sh.learned); _i++) {
		var _old = cbt_skill_gen(_sh.learned[_i].seed & $7fffffff, _sh.learned[_i].tmpl);
		var _v = sprite_skill_value(_sp, _old);
		if (_v < _wv) { _wv = _v; _wi = _i; }
	}
	var _nv = sprite_skill_value(_sp, _new);
	if (_wi >= 0 && _nv > _wv * 1.05) {
		var _gone = cbt_skill_gen(_sh.learned[_wi].seed & $7fffffff, _sh.learned[_wi].tmpl);
		_sh.learned[_wi] = { tmpl : _tmpl, seed : _seed };
		save_mark_dirty();
		return _sp.name + " learned " + _new.name + " and forgot " + _gone.name + " to make room";
	}
	if (random(1) < .5) return _sp.name + " was shown " + _new.name + ", " + choose("did not see the point", "already has one of those", "could not get the hang of it", "decided it was silly");
	return "";
}
