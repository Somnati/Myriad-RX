// THE CLOCKWORK, a frame at a time
syz_tick(s, delta / 60, true);
if (note_t > 0) note_t -= delta / 60;
if (tut && s.life >= 1) tut = false;
next_t -= delta / 60;
if (next_t <= 0) { s.next = syz_next(s); next_t = .5; }
// ---- input (region pattern, arbitrated) ----
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (__hit(__back_r())) { play_sound_ext(snd_matclick2, .8, .9, .5, 1); back_room(); exit; }
var _buy = function(_ok, _what) { if (_ok) { play_sound_ext(snd_softclick, 1.05, 1.2, .5, 1); note = _what; note_t = 3; } else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = "not enough"; note_t = 2; } };
for (var _i = 0; _i < array_length(s.cycles); _i++) {
	if (__hit(__per_m(_i))) { _buy(syz_buy(s, "per", _i, -1), "cycle " + string(_i + 1) + ": period " + string(s.cycles[_i].per) + "s"); exit; }
	if (__hit(__per_p(_i))) { _buy(syz_buy(s, "per", _i, 1), "cycle " + string(_i + 1) + ": period " + string(s.cycles[_i].per) + "s"); exit; }
	if (__hit(__lv_r(_i)))  { _buy(syz_buy(s, "lv", _i), "cycle " + string(_i + 1) + ": level " + string(s.cycles[_i].lv)); exit; }
	if (__hit(__anc_r(_i))) { _buy(syz_buy(s, "anchor", _i), "cycle " + string(_i + 1) + " anchored"); exit; }
}
if (__hit(__sync_r())) { _buy(syz_buy(s, "sync"), "sync: one second"); exit; }
if (__hit(__cyc_r()))  { _buy(syz_buy(s, "cycle"), "a new cycle at " + string(s.cycles[array_length(s.cycles) - 1].per) + "s"); exit; }
if (__hit(__harm_r())) { _buy(syz_buy(s, "harm"), "the harmonic: x" + string_format(s.harm, 1, 1) + " a cycle aligned"); exit; }
if (__hit(__nin_r()))  { _buy(syz_buy(s, "ninth"), "a ninth cycle may be bought"); exit; }
