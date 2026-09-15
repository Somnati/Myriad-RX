/// @description exped_encounter(trip, [mult]) - something on the road (called once per road-hour crossed; mult scales the odds - night)
/// EXPED_ENC% a road-hour: a wild fight (45), a passer-by who talks (25),
/// a bandit sprite (15), a friendly sprite who asks to come along (15 -
/// a "sprite" find: the haul's recruit moment decides at home).
function exped_encounter(_tr, _mult = 1) {
	if (!roll_perc(EXPED_ENC * _mult)) return;   // (x1.5 at night: the road is busier in the dark)
	var _r = random(100);
	if (_r < 45) {
		_tr.fight = exped_fight_new(_tr, "", irandom_range(1, 2), 0);
		array_push(_tr.log, "on the road: " + _tr.fight.b.name + ((array_length(_tr.fight.foes) > 1) ? " and company" : "") + " " + choose("block the way", "come out of the trees", "were waiting", "had the same idea"));
		exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .7);
	} else if (_r < 70) {
		exped_stat("met");
		var _nm = exped_npc_name();
		array_push(_tr.log, "met a sprite called " + _nm + " going the other way. " + choose("they talked about the weather.", "it had a hat. nobody mentioned it.", "it asked for directions. nobody knew.", "it was carrying a fish.", "they compared sticks."));
	} else if (_r < 85) {
		var _nm = exped_npc_name();
		_tr.fight = exped_fight_new(_tr, "bandit", irandom_range(1, 2), 1);
		for (var _j = 0; _j < array_length(_tr.fight.foes); _j++) _tr.fight.foes[_j].name = (_j == 0) ? (_nm + " the bandit") : ("one of " + _nm + "'s");
		array_push(_tr.log, "on the road: a sprite called " + _nm + " wanted the pocket money");
		exped_say(_tr, "fight_open", { foe : _nm }, .7);
	} else {
		exped_stat("met");
		var _nm = exped_npc_name();
		array_push(_tr.finds, { kind : "sprite", rar : 0, txt : "a sprite called " + _nm + ", who asked to come along", col : c_white, name : _nm });
		array_push(_tr.log, "met a sprite called " + _nm + " who asked to come along. " + choose("nobody said no.", "it is carrying its own bag.", "it seems fine."));
	}
}
