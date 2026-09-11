/// @description sprite_personalities() - THE ROSTER OF TEMPERAMENTS, as
/// data. A sprite rolls one at birth (sprite_spawn). Each is:
///   name   the word on its card
///   work   the fraction of its time it spends working (the lazy knob)
///   pace   a multiplier on its tap cadence while it does
///   lines  what it says when you poke it
/// The average rate a sprite taps at is work x pace / SPRITE_TAP_T -
/// sprite_rate - and both the live state machine (obj_blob) and the
/// headless runner (sprites_tick) and the offline law (sprites_offline)
/// derive from that one number, so a sprite is worth the same whether
/// you are watching it or not.
function sprite_personalities() {
	if (variable_global_exists("sprite_pers_cfg")) return g.sprite_pers_cfg;
	g.sprite_pers_cfg = [
		{ name : "eager",    work : .80, pace : 1.30, lines : ["on it!", "more!", "tap tap tap", "faster!"] },
		{ name : "sleepy",   work : .45, pace : .80,  lines : ["mm... five more", "zz", "wha?", "so cozy"] },
		{ name : "smug",     work : .60, pace : 1.00, lines : ["easy", "watch this", "i know", "obviously"] },
		{ name : "curious",  work : .60, pace : 1.00, lines : ["ooh", "what's that", "shiny", "why?"] },
		{ name : "grumpy",   work : .55, pace : .90,  lines : ["fine", "again?", "hmph", "don't."] },
		{ name : "cheerful", work : .70, pace : 1.10, lines : ["hi!!", "boop", "yay", "best day"] },
		{ name : "shy",      work : .50, pace : 1.00, lines : ["...", "oh! hi", "eep", "um"] },
		{ name : "greedy",   work : .75, pace : 1.20, lines : ["profit!", "mine", "more coins", "cha-ching"] },
	];
	return g.sprite_pers_cfg;
}
