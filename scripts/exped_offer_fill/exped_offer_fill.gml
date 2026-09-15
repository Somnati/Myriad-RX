/// @description exped_offer_fill(offer) - every slot's quest regenerated from its salt where missing (after a load)
function exped_offer_fill(_of) {
	if (!is_struct(_of[$ "d"])) return;
	for (var _i = 0; _i < array_length(_of.slots); _i++) {
		var _sl = _of.slots[_i];
		if (!is_struct(_sl.q)) _sl.q = exped_quest_gen(_of.d, _sl.salt, _of.ri, _sl.easy);
	}
}
