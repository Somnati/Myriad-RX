function clipboard_get() {
	if os_type = os_android return Clipboard_GetClipString();
	if os_type = os_windows return clipboard_get_text();
}
