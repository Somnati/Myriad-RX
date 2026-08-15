/// @description  trickle(feed,compared,adjust,clamp)
/// @param feed
/// @param compared
/// @param adjust
/// @param clamp
function trickle() {

	___a = argument[0];
	___b = argument[1];
	___c = argument[2];

	___val = ___b;

	if ___a != ___b{

	if ___c >= 1 ___adj = (1/(___c))*delta;
	if ___c < 1 ___adj = ___c*delta
	if ___adj > 1 ___adj = 1;

	___val = lerp(___a,___b,___adj);


	//hardpoint
	if argument_count != 4
	if abs(___a-___b) < .01
	___val = ___b;



	//clamp
	if argument_count != 4 if ___val-___b <= .01 and ___val-___b >= -.01 ___val = ___b;
	if argument_count = 4 if ___val-___b <= argument[3] and ___val-___b >= -argument[3] ___val = ___b;

	//if on_return ___val = ___b;
	}

	return ___val;




}
