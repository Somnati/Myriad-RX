
/// register a global variable for the GLOBALS page.
/// _name accepts "global.foo" or just "foo". _label is display text.
function debug_pro_watch(_name, _label) {
    if (!variable_global_exists("__dbgpro_watch")) global.__dbgpro_watch = [];
    array_push(global.__dbgpro_watch, { name: _name, label: _label });
}