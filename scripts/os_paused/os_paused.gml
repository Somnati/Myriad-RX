function os_paused() {
	var _pause;
	
	if os_type = os_windows return false;
	if os_type = os_android {
		_pause = os_is_paused(); 
		if _pause = true {show("os was paused"); mouse_clear(mb_left) return true} 
		if _pause != true return false
	}
}