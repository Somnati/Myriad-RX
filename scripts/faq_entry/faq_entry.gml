/// @description faq_entry(title, body, [art]) - one card under the
/// current faq_section. body wraps by itself; art is { spr, [frame],
/// [scale], [col] } or { fn : function(x, y, w, h) } - see faq_content.
/// Runs in syst_faq's scope.
function faq_entry(_title, _body, _art = undefined) {
	array_push(entries, { sec : cur_sec, title : _title, body : _body, art : _art });
}
