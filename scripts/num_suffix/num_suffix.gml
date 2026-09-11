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

	// ---- the letters: aa = e 5, ab = 6 ... az, ba ... zz, aaa, aab ... ----
	// ⚖️ WITHOUT END (his question, 2026-09-10: "how does it hold up at
	// E1M"). The first cut hand-built two letters and a third, which ran
	// out at e 681 - exponent ~52,700 - and printed garbage past it. This
	// is the spreadsheet column rule, bijective base 26: a..z, aa..zz,
	// aaa..zzz, as many letters as the number needs. "aa" is column 27,
	// so the e-th group maps to column (e - 5) + 27. At an exponent of a
	// million (e 333,333) that is four letters; at a billion, six.
	var _k = (_e - 5) + 27;
	var _s = "";
	while (_k > 0) {
		var _r = (_k - 1) mod 26;
		_s = chr(97 + _r) + _s;
		_k = (_k - 1) div 26;
	}
	return _s;
}
