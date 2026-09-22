/// rm_collider - THE COLLIDER (q319; his ask: "a unique mechanic that utilizes the anti matter dimension framework").
/// THE FRAMEWORK whole (cas_*: the linear cascade, log10 storage, per-10 doubling on bought units, AD's cost ladder,
/// the EXACT closed-form advance, the e308 wall as a run) - and on it TWO cascades, matter and antimatter, EACH THE
/// OTHER'S FUEL: matter tiers cost antimatter stock, antimatter tiers cost matter stock. ENERGY, the score, comes only
/// from ANNIHILATION - [collide] takes min(matter, antimatter) x pct from both stocks for 2 energy a pair, x2 when the
/// beam is balanced - and those stocks are what buys tiers, so every press trades growth for score. Energy buys the
/// field (x1.15 every tier), the auto-collider (the idle lane, replayed offline) and the magnet (a wider clean window).
/// e308 energy = the horizon; the crunch keeps best + the crunch count, and every crunch shaves the tier cost steps x.99
/// (the residue - the framework's knife edge, gently). The controller is a VIEW. datafiles/collider_twin.py races it.
c = coll_init();
bby = obj_ui_header.sprite_height;
caught = coll_catchup(c);
note = ""; note_t = 0;
if (caught >= 120) { note = "away " + crunch_time_long(caught * 60) + ": the cascades ran on" + ((c.auto_lv > 0) ? ", the auto-collider fired" : ""); note_t = 6; }
tut = (c.collisions == 0 && c.crunches == 0);
buy_q = 1;                           // x1 / x10 / x100 / "max"
pillbox_init(); pill_kind = "";
// ---- layout ----
band_y = bby + 18;                   // the two stocks + the beam
ctl_y = bby + 44;                    // the controls row: buy qty, collide + pct, the report line
list_y = bby + 62;                   // the tiers, two columns
row_h = 19;
col_w = (room_width - 12 - 6) div 2; // 231 each
col_x = [6, 6 + col_w + 6];
buy_w = 66;
side_col = [c_sblue, c_hred];
side_name = ["matter", "antimatter"];
tier_name = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"];
tier_col = array_create(8);
for (var _i = 0; _i < 8; _i++) tier_col[_i] = make_colour_hsv((10 + _i * 27) mod 256, 150, 225);
upg_y = list_y + 8 * row_h + 3;      // the energy upgrades
foot_y = upg_y + 17;                 // the line
beam_x = 150; beam_w = room_width - 300; beam_y = band_y + 12;
inf_bx = room_width * .5 - 150; inf_by = 100; inf_bw = 300; inf_bh = 66;
__buyq_r   = function() { return { x : 6, y : ctl_y, w : 80, h : 14 }; };
__coll_r   = function() { return { x : room_width * .5 - 70, y : ctl_y, w : 100, h : 14 }; };
__pct_r    = function() { return { x : room_width * .5 + 34, y : ctl_y, w : 42, h : 14 }; };
__row_r    = function(_s, _i) { return { x : col_x[_s], y : list_y + _i * row_h, w : col_w, h : row_h - 2 }; };
__tbuy_r   = function(_s, _i) { var _r = __row_r(_s, _i); return { x : _r.x + _r.w - buy_w - 2, y : _r.y + 2, w : buy_w, h : row_h - 6 }; };
__upg_r    = function(_k) { return { x : 6 + _k * 157, y : upg_y, w : 154, h : 14 }; };
__crunch_r = function() { return { x : room_width * .5 - 50, y : inf_by + 42, w : 100, h : 16 }; };
__back_r   = function() { return { x : room_width - 62, y : bby + 1, w : 56, h : 13 }; };
__hit      = function(_r) { return point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h); };
__hms      = function(_s) { _s = max(0, floor(_s)); var _m = string((_s div 60) mod 60); if (string_length(_m) < 2) _m = "0" + _m; var _q = string(_s mod 60); if (string_length(_q) < 2) _q = "0" + _q; return string(_s div 3600) + ":" + _m + ":" + _q; };
