/// @description  line(name,desc);
/// @param name
/// @param desc
function line() {


	name[l] = ""; 
	_sec_text[l] = "";
	if argument_count >= 1 if argument[0] != "" {name[l] = argument[0];}
	if argument_count >= 2 if argument[1] != "" {_sec_text[l] = argument[1];}
	cname[l] = name[l];
	ctexta[l] = rgb(195, 205, 235)//rgb(186, 209, 218); //rgb(100 ,105 ,110); 
	ctextb[l] = rgb(238, 210, 130); //rgb(124 ,130 ,162);
	
	//has_line[l] = false;
	//type[l] = -1;
	//folder[l] = -100; 
	//tog[l] = -1;
	
	if argument[2] != -1{
		if argument_count >= 3
		if argument[2] != "" ctexta[l] = argument[2];
	
		if argument_count >= 4
		if argument[3] != "" ctextb[l] = argument[3];
	}
	
	//if argument_count = 4
	//cname[l] = argument[3];
	l++;






}
