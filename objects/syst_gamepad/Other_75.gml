/// async system event - hotplug lands here ("gamepad discovered" /
/// "gamepad lost"). zeroing scan_t makes the next pad_tick rescan NOW
/// instead of waiting out the 30-step cadence; the scan itself owns
/// the logging + device bookkeeping (one code path for both the event
/// and the polling fallback).
var _t = string(async_load[? "event_type"] ?? "");
if (_t == "gamepad discovered" || _t == "gamepad lost") {
	if (variable_global_exists("pad")) g.pad.scan_t = 0;
}
