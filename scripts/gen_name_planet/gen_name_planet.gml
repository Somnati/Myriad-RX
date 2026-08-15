/// @description gen_name_planet(val);
/// @param val
function gen_name_planet(){
	
	has_suffix = false; has_m = false;

	_name = "";
	n_type = choose(0,1)

	// __s E "LETTER"
	if n_type = 0{
	letter_get_s_planet();
	letter_get_e_planet();

	if roll_perc(5) if has_suffix = false{_name = string_insert(_name," ",0); _name = string_insert(_name,letter_get_roman(choose(1,2,3,4,5,6,7)),0); has_suffix = true;}
	}

	// __s M E "II"
	if n_type = 1{has_m = true;
	letter_get_s_planet();
	letter_get_m_planet();
	letter_get_e_planet();

	if roll_perc(5) if has_suffix = false{_name = string_insert(_name," ",0); _name = string_insert(_name,letter_get_roman(choose(1,2,3,4,5,6,7)),0); has_suffix = true;}
	}

	// "Va " SE
	/*if n_type = 2{
	letter_get_s_material(1);
	letter_get_v_material(1);
	if roll_perc(30) _name = string_insert(_name,"h",0)
	else if roll_perc(30) letter_get_v_material(1);
	_name = string_insert(_name," ",0);
	pre = _name; _name = ""

	letter_get_s_planet();
	letter_get_e_planet();

	//set uppercase letter
	__str = string_char_at(_name,1);//first letter
	__str = string_upper(__str);//upper
	_name = string_delete(_name,1,1);//delete first letter
	_name = string_insert(__str,_name,1);
	_name = string_insert(pre,_name,0);

	}*/

	// __s E "prime"
	if n_type = 0
	    if roll_perc(2.5)
	        if has_suffix = false{has_suffix = true;
	_name = "";
	letter_get_s_planet();
	letter_get_e_planet();

	__s = round(random_range(0,4)); __ss = 0;

	if __s = __ss _name = string_insert(_name," mu",0); __ss += 1;
	if __s = __ss _name = string_insert(_name," nu",0); __ss += 1;
	if __s = __ss _name = string_insert(_name," pi",0); __ss += 1;
	if __s = __ss _name = string_insert(_name," tau",0); __ss += 1;
	if __s = __ss _name = string_insert(_name," psi",0); __ss += 1;
	}

	//set uppercase letter
	__str = string_char_at(_name,1);//first letter
	__str = string_upper(__str);//upper
	_name = string_delete(_name,1,1);//delete first letter
	_name = string_insert(__str,_name,1);

	return _name;




}