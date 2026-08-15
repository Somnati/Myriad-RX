/// @description pillbox_init();
/// pillbox 2.0 (ported from Myriad, rebuilt struct-based + arbitrated).
/// owner-side reset: call this, declare options with set_pill(), then
/// spawn the popup with do_pillbox(x, y). the pick comes back on YOU:
///   if (_pselid != -1) { ...switch on _pselval...; _pselid = -1; }
/// _pselval is the pill's value tag - a stable token that doesn't move
/// when a list conditionally drops entries (the old framework's id/name
/// contract broke exactly there). closing always routes through the
/// owner's _popen, never the object name, so two boxes can't cross-talk.
function pillbox_init() {
	_pills    = [];        // built by set_pill(), consumed by do_pillbox()
	_pselid   = -1;        // index of the pick, -1 = nothing yet
	_pselname = "";        // its label
	_pselval  = undefined; // its value tag: switch on THIS
	_popen    = false;     // authoritative open flag; pills poll it
}
