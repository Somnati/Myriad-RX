/// @description num_format_config() - THE NUMBER FORMATS, as data (his
/// ask, 2026-09-10: "the most popular number formats... alphabetical like
/// DE's but build it better"). g.num_format indexes this roster; every
/// crunch_arb in the game reads it, so the pick is the whole game's.
///
///   short        k m b t, then letter pairs aa ab ... az ba ... zz, three
///                decades a step - the idle-game standard. DE's
///                "alphabetical" used capitals from AA and its own carry;
///                this one is the convention everyone else's readers
///                already know (aa = 1e15, ba = 1e93, zz = 1e2040)
///   words        the short-scale names, DE's "realistic": k m b t qa qi sx
///                sp oc no dc, then un/du/tr/qa/qi/sx/sp/oc/nv- prefixes on
///                dc vg tg qag qig sxg spg ocg nog, ce at 1e303 - built by
///                rule rather than as DE's forty-line table, so it cannot
///                skip a rung
///   scientific   1.23e15 - mantissa to two decimals, the true exponent.
///                Plain digits under a million (DE wrote 1.23$15)
///   engineering  123.4e15 - the exponent held to a multiple of three, so
///                the mantissa runs 1..999 and the suffix reads as k/m/b
///                did. Plain digits under a million
///   logarithmic  e15.09 - the log10 itself to two decimals; the one
///                format where a x10 is always "+1". Plain digits under a
///                million
function num_format_config() {
	return [
		{ id : "short",       name : "short",       help : "k m b t, then aa ab ac... - three decades a step" },
		{ id : "words",       name : "words",       help : "quadrillion, quintillion... the short-scale names, abbreviated" },
		{ id : "scientific",  name : "scientific",  help : "1.23e15 - the true exponent" },
		{ id : "engineering", name : "engineering", help : "123.4e15 - exponents in threes, like k m b" },
		{ id : "logarithmic", name : "logarithmic", help : "e15.09 - the log itself; x10 is always +1" },
	];
}
