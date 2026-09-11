/// @description num_suffix(e, fmt) - the suffix for the e-th group of
/// three decades (e = 1 is thousands) under the short or words format.
/// Returns "" for e = 0. The two tables that crunch_arb hangs its
/// mantissa on; see num_format_config for what each format is.
/// @param e     floor(log10 / 3)
/// @param fmt   0 short (letters), 1 words (names)
function num_suffix(_e, _fmt) {
	if (_e <= 0) return "";
	if (_e == 1) return "k";
	if (_e == 2) return "m";
	if (_e == 3) return "b";
	if (_e == 4) return "t";

	if (_fmt == 1) {
		// ---- the short-scale names, by rule ----
		// 5 qa .. 10 dc, then dc/vg/tg/... each carry nine prefixed rungs
		// (un..nv), ce at 101; past that the letters take over rather
		// than inventing names nobody has read
		static _low  = ["qa", "qi", "sx", "sp", "oc", "no", "dc"];     // e 5..11
		static _pre  = ["", "un", "du", "tr", "qa", "qi", "sx", "sp", "oc", "nv"];
		static _tens = ["dc", "vg", "tg", "qag", "qig", "sxg", "spg", "ocg", "nog"]; // e 11, 21, 31 ...
		if (_e <= 11) return _low[_e - 5];
		if (_e == 101) return "ce";
		if (_e < 101) {
			var _t = (_e - 11) div 10;      // which tens name
			var _u = (_e - 11) mod 10;      // which prefix on it
			return _pre[_u] + _tens[_t];
		}
		// (falls through to the letters past the centillion)
	}

	// ---- the letters: aa = e 5, ab = 6 ... az = 30, ba = 31 ... zz = 680 ----
	var _i = _e - 5;
	var _a = _i div 26, _b = _i mod 26;
	if (_a >= 26) {
		// three letters past zz (e 681+): aaa ... - the game never gets
		// here (e308 is e 102) but a table that ends is a table that lies
		var _c = _a div 26; _a = _a mod 26;
		return chr(97 + _c - 1) + chr(97 + _a) + chr(97 + _b);
	}
	return chr(97 + _a) + chr(97 + _b);
}
