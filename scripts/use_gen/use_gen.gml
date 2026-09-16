/// @description use_gen(kind, [size], [lv], [line]) -> a CONSUMABLE (his ask, 2026-09-16): a pocket item with slot "use"
///   hp      a red potion: back 40% of the sprite's hp (a big one 80%)
///   mp      a blue potion: back half the mp (a big one all of it)
///   tonic   a tonic: holds a hazard for the next fight (drunk at the door - exped_fight_new)
///   totem   the totem of don't die: a fallen sprite that carries one stands up at half hp; it cracks (cbt_hit)
///   elixir  an elixir of <line>: drunk on the spot, +1 to that line for good (sprite_elixir)
/// A consumable carries the gear shape the pocket and the popup read (pts empty, quirks none) and packs
/// as "use,<kind>,<size>,<lv>" (gear_pack / gear_unpack). The crew drinks them itself (exped_drink).
function use_gen(_kind, _size = 1, _lv = 1, _line = "") {
	var _big = (_size >= 2);
	var _it = { slot : "use", kind : _kind, size : _size, lv : _lv, line : _line, rar : _big ? 2 : 0, seed : 0, tag : "", own : "", gen : 2,
	            pts : {}, quirks : [], holds : "", crit : 0, cnt : 0, erode : 1, mp0 : 0, fam : "potion", score0 : 0, name : "", col : c_white };
	switch (_kind) {
		case "hp":     _it.name = _big ? "big red potion" : "red potion";   _it.col = c_hred;   break;
		case "mp":     _it.name = _big ? "big blue potion" : "blue potion"; _it.col = c_sblue;  break;
		case "tonic":  _it.name = "tonic";                                 _it.col = c_sgreen; _it.fam = "tonic"; break;
		case "totem":  _it.name = "totem of don't die";                   _it.col = c_gold;   _it.fam = "totem"; _it.rar = 4; break;
		case "elixir": _it.name = "elixir of " + ((_line == "mag") ? "int" : ((_line == "mdef") ? "res" : _line)); _it.col = c_lavender; _it.fam = "elixir"; _it.rar = 5; break;
		default:       _it.name = "a bottle of something"; break;
	}
	return _it;
}
