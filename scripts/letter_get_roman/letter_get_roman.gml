/// @description  letter_get_roman(num,lower?);
/// @param num
/// @param lower?
function letter_get_roman() {

	_n = argument[0];
	if _n = -1 _n = round(random_range(0,15));
	_g = 0; _val = -1;
	if _n = _g _val =  "i"; _g ++
	if _n = _g _val =  "ii"; _g ++
	if _n = _g _val =  "iii"; _g ++
	if _n = _g _val =  "iv"; _g ++
	if _n = _g _val =  "v"; _g ++
	if _n = _g _val =  "vi"; _g ++
	if _n = _g _val =  "vii"; _g ++
	if _n = _g _val =  "viii"; _g ++
	if _n = _g _val =  "ix"; _g ++
	if _n = _g _val =  "x"; _g ++
	if _n = _g _val =  "xi"; _g ++
	if _n = _g _val =  "xii"; _g ++
	if _n = _g _val =  "xiii"; _g ++
	if _n = _g _val =  "xiv"; _g ++
	if _n = _g _val =  "xv"; _g ++
	if _n = _g _val =  "xvi"; _g ++
	if _n = _g _val =  "xvii"; _g ++
	if _n = _g _val =  "xviii"; _g ++
	if _n = _g _val =  "xix"; _g ++
	if _n = _g _val =  "xx"; _g ++
	if _n = _g _val =  "xxi"; _g ++
	if _n = _g _val =  "xxii"; _g ++
	if _n = _g _val =  "xxiii"; _g ++
	if _n = _g _val =  "xxiv"; _g ++
	if _n = _g _val =  "xxv"; _g ++
	if _n = _g _val =  "xxvi"; _g ++
	if _n = _g _val =  "xxvii"; _g ++
	if _n = _g _val =  "xxviii"; _g ++
	if _n = _g _val =  "xxix"; _g ++
	if _n >= _g _val = crunch_arb(arb(_n+1));

	//set uppercase letter
	if argument_count = 2
	if is_string(_val){
	if argument[1] = true _val = _val;
	if argument[1] = false  _val = string_upper(_val);//upper
	}

	if _val = -1 return(string(argument[0]));
	return string(_val);
	//name = string_insert(name,_val,0);






}
