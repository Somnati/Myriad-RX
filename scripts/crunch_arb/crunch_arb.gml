/// @description  crunch_arb(val);
/// @param val

function crunch_arb() {


	_aexp = floor(argument[0]);//exponent

	// dust-proof mantissa: snap once to 6 decimals, then never trust the
	// raw float again. frac() of a packed value carries binary dust
	// (2 + 4/10 is stored as 2.3999999999999998, which the old floor()
	// path truncated into "399"). The carry guard handles dust sitting
	// just under the next exponent (9.9999999x).
	_acoe = round((argument[0] - _aexp) * 10 * 1000000) / 1000000; //significant digit
	if _acoe >= 10 {_acoe /= 10; _aexp += 1;}

	_e = floor(_aexp/3);

	// ---- THE FORMAT (his ask, 2026-09-10; num_format_config is the
	// roster, g.num_format the pick). Everything under a thousand is
	// digits in every format; from there each format has its own idea
	// of where the digits stop.
	var _fmt = variable_global_exists("num_format") ? g.num_format : 0;
	if (_fmt >= 2 && _aexp >= 3) {
		// ---- the exponent formats: digits with commas under a million ----
		if (_aexp < 6) return crunch_arb_full(argument[0], 6);   // (the cap is an EXPONENT: digits under a million)
		// ⚖️ THE EXPONENT ABBREVIATES PAST 100k (his question: E1M). An
		// exponent of a million is seven digits, a billion ten - the
		// short suffix takes over on the exponent itself, DE's own move
		// (it crunched past 10k): 5.43e1.00m, e1.00m. The arb packs the
		// exponent as the whole part of a double, so a billion is exact
		// and the mantissa still has six digits of room beside it.
		if (_fmt == 3) {
			// logarithmic: the log10 itself, two decimals - or its short
			// form once the decimals stop meaning anything
			var _lgv = _aexp + log10(_acoe);
			if (_lgv >= 100000) return "e" + num_exp_short(_lgv);
			return "e" + string_format(_lgv, 1, 2);
		}
		// scientific: 1.23e15 - a mantissa that rounds up to 10 carries
		var _m = round(_acoe * 100) / 100;
		var _x = _aexp;
		if (_m >= 10) { _m = 1; _x += 1; }
		if (_x >= 100000) return string_format(_m, 1, 2) + "e" + num_exp_short(_x);
		return string_format(_m, 1, 2) + "e" + string(_x);
	}

	//abbreviation: short letters or the words, the groups of three
	_abr = num_suffix(_e, _fmt);
	_abr_id = _e + 1;   // (every group has a suffix now: the 3-digit path always runs)

	tot = 1; dec = 2;
	_val_ = _acoe;

		// non scientific numb calc
	    if _e < _abr_id{
	        //calculate 3's: integer mod, exact at any exponent (the old
	        //float dance ((_aexp/3)-floor(_aexp/3))*100 loses precision
	        //once exponents get huge)
	        var _te = _aexp mod 3;
	        if _te = 1 {tot = 2; dec = 1; _val_ *= 10;}
	        if _te = 2 {tot = 3; dec = 0; _val_ *= 100;}

	        //determine tot/dec
	        if _aexp = 0 {tot = 1; dec = 0;}
	        if _aexp = 1 {tot = 2; dec = 0;}
	        if _aexp = 2 {tot = 3; dec = 0;}
	    }

			// insignificant decimal removal
			if _aexp >= 500 if dec > 1 dec = 1
			if _aexp >= 1000 if dec > 0 dec = 0

		// round, never floor: any residual dust sits a hair BELOW the
		// true value, so floor eats a whole unit (400 -> 399) while
		// round recovers it. The dec > 0 paths were always safe because
		// string_format rounds them.
		if dec = 0 _val_ = round(_val_);
		_val_ = string_format(_val_,tot,dec);
	    _val_ = string_insert(_val_,_abr,0);

		return   _val_;
}
