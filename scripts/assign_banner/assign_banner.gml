/// @description assign_banner(text,c_text,c_back);
/// @param text
/// @param c_text
/// @param c_back
function assign_banner() {



	if instance_exists(syst_banner){
	o_sb = syst_banner;
	lines = o_sb.lines;
	_l_ = lines-1; 
	repeat lines
	if _l_ >= 0{
	    if o_sb.text[_l_] != ""{
	    o_sb.text[_l_+1] = o_sb.text[_l_];
	    o_sb.c_text[_l_+1] = o_sb.c_text[_l_];
	    o_sb.c_back[_l_+1] = o_sb.c_back[_l_];
	    o_sb.alpha[_l_+1] = o_sb.alpha[_l_];
	    o_sb.hp[_l_+1] = o_sb.hp[_l_];
	    o_sb.glow[_l_+1] = o_sb.glow[_l_];
	    o_sb.dy[_l_+1] = o_sb.dy[_l_];
	    o_sb.dx[_l_+1] = o_sb.dx[_l_];
	    }
	_l_-=1;}

	o_sb.c_text[0] = c_white;
	o_sb.c_back[0] = c_black;

	o_sb.dx[0] = 0;

	o_sb.alpha[0] = 1;
	o_sb.hp[0] = tsec*3;
	o_sb.glow[0] = 1;
	o_sb.text[0] = argument[0];
	if argument_count = 2 
	or argument_count = 3 o_sb.c_text[0] = argument[1];
	if argument_count = 3 o_sb.c_back[0] = argument[2];

	}









}
