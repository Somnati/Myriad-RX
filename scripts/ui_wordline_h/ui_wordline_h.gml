/// @description ui_wordline_h() - the height the word line under the
/// counter takes (see ui_wordline): 9 px while the words format is on, 0
/// otherwise. Reserved by FORMAT, not by value.
function ui_wordline_h() {
	return (variable_global_exists("num_format") && g.num_format == 1) ? 9 : 0;
}
