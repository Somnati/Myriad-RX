/// @description ticket_config() -> the ticket rules, as data.
///   rars   the five-tier ladder (the gift's names and colours, so a
///          rare ticket reads like a rare gift): win = the printed odds
///          (percent - HONEST, on the ticket's face), mult = the prize
///          multiplier, foil = the scratch surface's colour
///   w_*    rarity weights by source: the daily gift, an objective batch
///          and an absence draw the common table; a rebirth milestone
///          never hands out a common
///   syms   the five symbols on every grid - match three of one and it
///          pays that kind (ticket_prize derives the amount NOW, off
///          the live rate / wallets, so a ticket kept a week pays at
///          today's numbers). flux / shards fall back to profit before
///          the tile room exists.
///   away_secs  an absence this long leaves a ticket on the desk
function ticket_config() {
	static _c = {
		rars : [
			{ name : "common",    col : rgb(200, 200, 200), win : 25,  mult : 1,  foil : rgb(172, 178, 194) },
			{ name : "uncommon",  col : c_rarity_uncommon,  win : 33,  mult : 2,  foil : rgb(172, 178, 194) },
			{ name : "rare",      col : c_rarity_rare,      win : 50,  mult : 4,  foil : rgb(172, 178, 194) },
			{ name : "epic",      col : c_rarity_epic,      win : 75,  mult : 9,  foil : rgb(196, 176, 214) },
			{ name : "legendary", col : c_rarity_legendary, win : 100, mult : 20, foil : rgb(220, 196, 128) },
		],
		w_common    : [60, 25, 10, 4, 1],
		w_milestone : [0, 30, 40, 22, 8],
		syms : [
			{ key : "profit",  name : "profit",  secs : 90 },   // seconds of the current rate x mult
			{ key : "credits", name : "credits", per : .75 },  // ceil(per x mult) credits
			{ key : "flux",    name : "flux",    pct : 1, min : 5 },   // % of held flux x mult
			{ key : "shards",  name : "shards",  pct : 2, min : 10 },  // % of held shards x mult
			{ key : "ticket",  name : "ticket" },               // another ticket (re-rolled)
		],
		away_secs : 4 * 3600,
	};
	return _c;
}
