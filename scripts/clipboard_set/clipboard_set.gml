/// @description clipboard_set(txt)
/// @param txt

function clipboard_set(argument0) {
	if os_type = os_android Clipboard_SetClipString(argument0);
	if os_type = os_windows clipboard_set_text(argument0);
}
