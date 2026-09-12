/// @description exped_fight_new(trip) -> a fight, ready for its first turn
/// TWO SIDES, THREE STATS EACH: hp / hit (the chance a swing lands) /
/// init (who swings first). The crew's come off the sprite (rarity
/// deepens hp, the personality's pace sharpens the hit - a busy sprite
/// is a quick one), the foe's off the destination's tier. DE's rules
/// where they were cheap: initiative opens, a counter chance, a
/// quality hit (double damage) at a small chance leaned by luck.
/// @param trip
function exped_fight_new(_tr) {
	var _d  = _tr.dest;
	var _sp = undefined;
	for (var _i = 0; _i < array_length(g.sprites); _i++) if (g.sprites[_i].id == _tr.sid) _sp = g.sprites[_i];
	var _pace = 1;
	if (_sp != undefined) {
		var _pl = sprite_personalities();
		_pace = _pl[clamp(_sp.pers, 0, array_length(_pl) - 1)].pace;
	}
	var _foes = ["a scrap crawler", "a hollow warden", "a shard mite", "a dust wraith", "a rust beetle", "a lantern moth"];
	return {
		a : { name : _tr.sname, hp : _tr.hp, hpmax : _tr.hpmax,
		      hit : clamp(60 + 15 * _pace, 40, 95), init : 5 + 3 * _pace, dmg : 2 },
		b : { name : _foes[irandom(array_length(_foes) - 1)],
		      hp : 5 + 3 * _d.tier, hpmax : 5 + 3 * _d.tier,
		      hit : clamp(45 + 5 * _d.tier, 30, 90), init : 4 + _d.tier, dmg : 1 + floor(_d.tier / 2) },
		turn : 0, over : false, won : false, log : [],
		t : 0,   // the clock toward the next turn (EXPED_FIGHT_T)
	};
}
