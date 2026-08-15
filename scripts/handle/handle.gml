/// @description  handle("name",var,write_whole);
/// @param "name"
/// @param var
/// @param write_whole

function handle(){
	
	if action = sv_load return read(argument[0],argument[1]);
	
	if action = sv_save {
		if argument_count = 3
			and argument[2] = true
		write(argument[0],string_format(argument[1],string_length(argument[1]),0))
		else
		write(argument[0],argument[1]);
		return argument[1];
	}
}