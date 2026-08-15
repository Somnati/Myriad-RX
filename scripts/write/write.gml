/// @description  write(key,value);
/// @param key
/// @param value
function write(argument0, argument1) {

	if is_real(argument1) ini_write_real(section,argument0,argument1)
	else
	ini_write_string(section,argument0,argument1);

}
