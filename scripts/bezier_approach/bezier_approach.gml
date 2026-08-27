function bezier_approach() {

	_zero += ((_zero_adj*(clamp_min(300/_point_dist,1)))*_move_scale)*delta;
	if _zero > 1 _zero = 1;

}
