/// push a message to the LOG page. keeps the newest 100.
function debug_pro_log(_msg) {
    if (!variable_global_exists("__dbgpro_log")) global.__dbgpro_log = [];
    var _log = global.__dbgpro_log;
    array_push(_log, { t: current_time div 1000, msg: string(_msg) });
    var _over = array_length(_log) - 100;
    if (_over > 0) array_delete(_log, 0, _over);
}