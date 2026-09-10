/// @description faq_section(name, col) - a tab in the FAQ's rail. Every
/// faq_entry after it files under it. Runs in syst_faq's scope.
function faq_section(_name, _col) {
	array_push(sections, { name : _name, col : _col });
	cur_sec = array_length(sections) - 1;
}
