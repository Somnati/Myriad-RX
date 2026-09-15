/// @description sprite_inv_trim(sprite) -> the name of what was dropped ("" = nothing)
/// THE POCKET'S RULE (sprite_take): past SPRITE_INV the lowest-scored item goes
function sprite_inv_trim(_sp) {
	var _sh = sprite_sheet(_sp);
	var _gone = "";
	while (array_length(_sh.inv) > SPRITE_INV) {
		var _worst = infinity, _at = 0;
		for (var _i = 0; _i < array_length(_sh.inv); _i++) { var _s = gear_score(_sp, _sh.inv[_i]); if (_s < _worst) { _worst = _s; _at = _i; } }
		_gone = _sh.inv[_at].name;
		array_delete(_sh.inv, _at, 1);
	}
	return _gone;
}
