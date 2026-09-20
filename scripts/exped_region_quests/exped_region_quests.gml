/// @description exped_region_quests(dest, [ri]) -> the region's OFFER: EXPED_QUESTS slots [{ q, salt, left, taken, easy }]
/// THE QUEST BOARD (his ask, 2026-09-15: "5 quests per region with each
/// slot refreshing off a timer whether it's completed or not... other
/// towns having people doing quests"). A slot holds a quest (regenerated
/// from its salt - exped_quest_gen), the seconds it has left on the
/// expedition clock (exped_offer_tick: online, offline, x the debug
/// speed), and who took it (taken = the trip's id, 0 = nobody). When
/// its clock runs out it re-deals, taken or not. AT LEAST ONE EASY
/// quest is always up (a re-deal goes easy when none would be). The
/// offer lives in g.exped.offers by "seed:ri" and is saved (ex_offer).
function exped_region_quests(_d, _ri = 0) {
	exped_init();
	var _e = g.exped;
	if (!is_struct(_e[$ "offers"])) _e.offers = {};
	_ri = max(0, _ri);   // (region_get clamps to the world's own count - q287)
	var _k = string(_d.seed) + ":" + string(_ri);
	var _of = _e.offers[$ _k];
	if (!is_struct(_of)) {
		// the first deal: five, their clocks staggered so they do not all turn at once
		_of = { seed : _d.seed, ri : _ri, slots : [], next : 0, d : _d };
		for (var _i = 0; _i < EXPED_QUESTS; _i++) array_push(_of.slots, { salt : 0, left : 0, taken : 0, easy : false, q : undefined });
		for (var _i = 0; _i < EXPED_QUESTS; _i++) { exped_offer_deal(_of, _i); _of.slots[_i].left *= random_range(.35, 1); }   // (dealt one by one: distinct places, the one-easy law)
		_e.offers[$ _k] = _of;
		save_mark_dirty();
	}
	_of.d = _d;
	exped_offer_fill(_of);
	// THE PERSONAL CARD (2026-09-16) rides after the five: the same structs, so a take through the index lands on it
	if (is_array(_of[$ "pq"]) && array_length(_of.pq) > 0) return array_concat(_of.slots, _of.pq);
	return _of.slots;
}
