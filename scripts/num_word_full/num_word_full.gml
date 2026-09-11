/// @description num_word_full(e) - the full short-scale name of the e-th
/// group of three decades (e = 1 "thousand", 5 "quadrillion"), for the
/// word line under the counter (ui_wordline). "" for e = 0 and past the
/// centillion, where the abbreviation has fallen back to letters anyway.
/// Built by the same rule as num_suffix's abbreviations, so the two can
/// never disagree about which rung is which.
function num_word_full(_e) {
	if (_e <= 0) return "";
	static _low = ["thousand", "million", "billion", "trillion", "quadrillion",
	               "quintillion", "sextillion", "septillion", "octillion", "nonillion", "decillion"];
	static _pre = ["", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"];
	static _tens = ["decillion", "vigintillion", "trigintillion", "quadragintillion",
	                "quinquagintillion", "sexagintillion", "septuagintillion",
	                "octogintillion", "nonagintillion"];
	if (_e <= 11) return _low[_e - 1];
	if (_e == 101) return "centillion";
	if (_e > 101) return "";
	return _pre[(_e - 11) mod 10] + _tens[(_e - 11) div 10];
}
