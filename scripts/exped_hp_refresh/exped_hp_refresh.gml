/// @description exped_hp_refresh(trip, sid) - a member's hp ceiling re-read off its sheet (a piece worn), its hp clamped under it - by the sprite's id, so a find handed round refreshes the one who WEARS it (q268)
function exped_hp_refresh(_tr, _sid) {
	var _k = array_get_index(_tr.sids, _sid);
	if (_k < 0) return;
	var _sp = exped_sprite(_sid);
	if (is_undefined(_sp)) return;
	_tr.hpmax[_k] = sprite_pawn(_sp).maxhp;
	_tr.hp[_k] = min(_tr.hp[_k], _tr.hpmax[_k]);
}
