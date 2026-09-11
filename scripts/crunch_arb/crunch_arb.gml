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
		if (_fmt == 4) {
			// logarithmic: the log10 itself, two decimals
			return "e" + string_format(_aexp + log10(_acoe), 1, 2);
		}
		if (_fmt == 2) {
			// scientific: 1.23e15 - a mantissa that rounds up to 10 carries
			var _m = round(_acoe * 100) / 100;
			var _x = _aexp;
			if (_m >= 10) { _m = 1; _x += 1; }
			return string_format(_m, 1, 2) + "e" + string(_x);
		}
		// engineering: the exponent held to threes, the mantissa 1..999.9
		var _x3 = _aexp - (_aexp mod 3);
		var _m3 = _acoe * power(10, _aexp mod 3);
		var _d3 = (_m3 >= 100) ? 0 : ((_m3 >= 10) ? 1 : 2);
		_m3 = round(_m3 * power(10, _d3)) / power(10, _d3);
		if (_m3 >= 1000) { _m3 = 1; _x3 += 3; _d3 = 2; }
		return string_format(_m3, 1, _d3) + "e" + string(_x3);
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
