/// @description create_obj(x, y, obj)
/// @param x
/// @param y
/// @param obj
/// can use 1 argument with only obj. will spawn at x/y cord of object calling it
function create_obj() {
	if argument_count = 1 return instance_create_depth( x, y, depth, argument0);
	if argument_count = 3 return instance_create_depth( argument0, argument1, depth, argument2 );
}
