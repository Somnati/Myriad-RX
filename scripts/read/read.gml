/// @description  read("name",variable);
/// @param "name"
/// @param variable
function read(argument0, argument1) {
	

	
	if is_real(argument1) or is_bool(argument1) return ini_read_real(section,argument0,argument1)
	else
	return ini_read_string(section,argument0,argument1);
	
	

}
