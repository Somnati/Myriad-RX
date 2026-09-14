/// scr_bignum_vis_renderer
/// BignumVisRenderer v3: flush counting field for seamless zoom.
///
/// A field is a 10x10 arrangement of large squares anchored at a fixed
/// TOP-LEFT, filling left to right, top to bottom, with NO gaps: squares
/// advance flush, exactly like the old vis (xx += des_cs). This is what
/// makes the zoom handoff invisible: 100 flush squares of one field are
/// pixel-identical in size and position to a single square of the field
/// above it.
///
/// Square count reads THREE digits (magnitudes offset+4..offset+2) and
/// clamps to 100, so a field fading out at a handoff fills completely
/// solid instead of wrapping back to 0 through the digit pair. Partial
/// units read the bottom pair (offset+1, offset): rows top to bottom via
/// the line sprite, remainder units left to right.
///
/// Grids, two per field, matching the old vis (which drew one grid per
/// telescoping level): a SMALL grid behind the partial square (units
/// assembling into a square) and a BIG grid spanning the whole 10x10
/// field (squares assembling into the super square of the tier above).
/// Each grid is tinted the tier color of the square it is becoming, and
/// its alpha is shaped the old way: base 0.6..0.8 dimming as it fills,
/// fading in as it grows past ~100px, fading back out toward ~750px.
/// Sprite assumptions (spr_vis_grid): 300x300 canvas, origin at (100,100)
/// which is the top-left of a 100x100 grid block with 10px cells.
///
/// THE OFFSET FIX still lives here: all positions derive from the unit
/// size handed in THIS frame. No persistent smoothed pan term anywhere.

function BignumVisRenderer() constructor {
    square_sprite    = spr_pixel_1x1;  // 1x1 px, stretched per unit or per square
    line_sprite      = spr_line_10;    // assumed 10x1 px, one full row of 10
    grid_sprite      = -1;             // spr_vis_grid2, wired by the host.
                                       // 3 subimages: 0 = bright border
                                       // outlining each 100-block, 1 =
                                       // internal 10x10 lines, 2 =
                                       // external surrounding lattice.
                                       // Legacy 1-image sprites still work
    grid_px_per_unit = 10;             // grid cell size in sprite px
    grid_alpha       = 0.75;           // master multiplier on the shaped
                                       // alpha, applied to every piece

    // per-piece alpha multipliers (on top of grid_alpha and the shaped
    // fade) and per-piece placement: over = draws on top of the fills,
    // under = draws behind them. Defaults keep the verified old look
    // (subdivision lines readable over blocks) while the surrounding
    // lattice stays tucked behind everything.
    grid_border_alpha = 1.0;    // image 0
    grid_inner_alpha  = 0.6;    // image 1
    grid_outer_alpha  = 0.35;   // image 2
    grid_border_over  = true;
    grid_inner_over   = false;   // internal lines behind the fills
    grid_outer_over   = false;

    base_unit = 4.5;  // px per small unit at camera center: THE overall
                      // size knob. 4.5 keeps a full 10-square row inside a
                      // 480px room at the widest point of the band (count
                      // ~10, camera centered). Raise for chunkier, lower
                      // for further out everywhere
    per_row   = 10;   // squares per field row

    recurse_min_unit = 1;  // recursion starts fading in at this unit px.
                           // (2 / 3 below made a sub-level fully in only at
                           // 5 px a unit; his report, 2026-09-13: the white
                           // squares faded a zoom level out. 1 / 1.2 has a
                           // 2 px unit 80% in and a 4 px one fully)
                           // 2 puts the first sub-level ~80% visible at
                           // the RESTING unit size (~4.5px) and brings
                           // the level below it in with a modest zoom:
                           // a couple layers deeper than the old 8,
                           // which never showed depth at rest at all
    recurse_fade     = 1.2; // and reaches full over this many px more.
                           // Each level shows 2 more digits at 1/10 scale,
                           // like the old telescoping levels, and now
                           // CROSSFADES in and out instead of hard-cutting,
                           // so no zoom position can pop a layer
    label_font       = fnt;
    label_alpha      = 0.8;   // old Draw Begin set draw_set_alpha(.8)
    label_floor_dark = 0.65;  // how far toward black a floor-tier label
                              // sinks when no tier exists below it

    // ---- spawn settle FX (value-driven, zero per-block state) ----
    // The newest block at each level is born small and translucent, and
    // settles to full presence as the NEXT block's fill progresses. Age
    // is read from the value's deeper digits, so the animation speed is
    // automatically tied to income rate and the renderer stays a pure
    // function of value + camera. Known limitation: pure integer values
    // have no deeper digits at the finest level, so the newest unit
    // rests at its spawn state there; real fractional income settles
    // everything continuously.
    spawn_fx    = false;  // master toggle (off by preference)
    spawn_alpha = 0.25;   // alpha a block is born at
    spawn_scale = 0.80;   // scale a block is born at (grows to 1, centered)
    settle_span = 0.30;   // how much of the next block's fill completes
                          // the settle: 0.3 = settled once the next block
                          // is 30% full. Lower = snappier, higher = lazier

    follow_lag    = 1;   // camera focus at the bottom chain level:
                         // 1 = the most recently CREATED square (default,
                         //     matches the old vis),
                         // 0 = the assembling (next empty) slot

    unit_floor    = 0;   // lowest magnitude a UNIT can exist at: keep
                         // equal to DigitWindow.fake_floor. A level whose
                         // units would live below this draws no small
                         // grid, because that grid's cells subdivide the
                         // assembling square into sub-tier units that do
                         // not exist. The level's BIG grid (framing its
                         // atomic blocks) is unaffected: the terminus
                         // keeps its own frame, nothing below it

    min_fill_px   = 0.4; // partial rows/units smaller than this many px
                         // are skipped: below it they render as
                         // sub-pixel shimmer, the old vis gated the same
                         // way (if des_cs > .05). Full squares and grids
                         // are unaffected (they self-limit by size)

    debug         = false;  // see the debug block at the end of draw_window
    dbg_row       = 0;      // host resets this each frame
    tier_color_cb = undefined;   // host-supplied: function(tier) -> color
    label_cb      = undefined;   // host-supplied: function(tier, count) -> string

    /// @func set_tier_color_callback(cb)
    static set_tier_color_callback = function(_cb) {
        tier_color_cb = _cb;
    };

    /// @func get_tier_color(tier)
    static get_tier_color = function(_tier) {
        if (tier_color_cb != undefined) return tier_color_cb(_tier);
        return c_white;
    };

    /// @func set_label_callback(cb)
    /// @desc Host game supplies its own formatter (crunch_arb equivalent)
    ///       when ready: function(tier_mag, count) -> string. Until then
    ///       the plain fallback below is used.
    static set_label_callback = function(_cb) {
        label_cb = _cb;
    };

    /// @func get_label(tier_mag, count)
    static get_label = function(_tier_mag, _count) {
        if (label_cb != undefined) return label_cb(_tier_mag, _count);
        return string(_count) + "e" + string(_tier_mag);
    };

    /// @func label_color(subject_mag)
    /// @desc Old-style cutout coloring: a label wears the tier BELOW its
    ///       subject, as if the text were punched through the square to
    ///       the layer beneath (the legacy _tcolor used c+1, which in
    ///       the old descending arrays was the SMALLER tier). At the
    ///       floor no tier exists below, so the label wears a very dark
    ///       version of its own tier instead.
    static label_color = function(_subject_mag) {
        var _below = _subject_mag - 2;
        if (_below >= unit_floor) return get_tier_color(_below);
        return merge_colour(get_tier_color(_subject_mag), c_black, label_floor_dark);
    };

    /// @func draw_label(text, x, y, scale, col, alpha)
    /// @desc Old-style square label: right/bottom aligned, clamped so it
    ///       slides back on screen instead of leaving it, colored like the
    ///       tier above so it reads as a cutout of the larger square.
    static draw_label = function(_text, _x, _y, _scale, _col, _alpha, _max_px = -1) {
        draw_set_font(label_font);

        // cap so the rendered string never exceeds one block of its own
        // level in either dimension: single-digit labels fit naturally,
        // but crunched strings ("910K", "3.2e45") are several characters
        // wide at the same per-character scale and would sprawl
        if (_max_px > 0) {
            var _w = max(string_width(_text), 1);
            var _h = max(string_height(_text), 1);
            _scale = min(_scale, _max_px / _w, _max_px / _h);
        }

        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_set_color(_col);
        draw_set_alpha(_alpha);
        draw_text_transformed(clamp(_x, 0, room_width), _y, _text, _scale, _scale, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
    };

    /// @func unit_for(layer_offset, world_mag)
    /// @desc Pixel size of one small unit for a field anchored at
    ///       layer_offset. One OOM of camera travel scales linear size by
    ///       sqrt(10), so at a handoff (|wm - offset| = 1) one field's
    ///       square exactly equals the neighboring field's unit.
    static unit_for = function(_layer_offset, _world_mag) {
        return base_unit * power(10, (_layer_offset - _world_mag) * 0.5);
    };

    /// @func grid_fade(super_px, fill)
    /// @desc Old-style grid alpha shaping. super_px is the pixel size of
    ///       the square this grid is becoming, fill is how full it is
    ///       (0..1). Base 0.8 dimming to 0.6 as it fills, fading in as it
    ///       grows past 100px, fading back out from 50px toward 750px.
    static grid_fade = function(_super_px, _fill) {
        var _in  = clamp(_super_px / 100, 0, 1);
        var _out = 1 - clamp((_super_px - 50) / 700, 0, 1);
        return lerp(0.8, 0.6, clamp(_fill, 0, 1)) * _in * _out;
    };

    /// @func draw_grid_set(x, y, scale, col, base_alpha, over_pass)
    /// @desc Draws whichever of the three grid pieces belong to this
    ///       pass (under or over the fills), each at its own alpha.
    ///       Order within a pass: external lattice, internal lines,
    ///       border on top.
    static draw_grid_set = function(_x, _y, _s, _col, _a, _over) {
        if (_a <= 0) return;
        if (grid_outer_over  == _over) draw_sprite_ext(grid_sprite, 2, _x, _y, _s, _s, 0, _col, _a * grid_outer_alpha);
        if (grid_inner_over  == _over) draw_sprite_ext(grid_sprite, 1, _x, _y, _s, _s, 0, _col, _a * grid_inner_alpha);
        if (grid_border_over == _over) draw_sprite_ext(grid_sprite, 0, _x, _y, _s, _s, 0, _col, _a * grid_border_alpha);
    };

    /// @func __dbg_col(col)
    /// @desc A colour as "r.g.b" for the field ledger. Screenshots are how
    ///       this project reports, so the number has to be readable IN the
    ///       screenshot - a swatch would just be another colour to argue
    ///       about, which is the thing being debugged.
    static __dbg_col = function(_c) {
        return string(colour_get_red(_c)) + "."
             + string(colour_get_green(_c)) + "."
             + string(colour_get_blue(_c));
    };

    /// @func draw_square_clipped(spr, x, y, size, col, alpha)
    /// @desc Solid square clipped to a screen margin before drawing.
    ///       Giant spanning squares at deep zoom carry raw coordinates
    ///       beyond float32's precision on the GPU (edges crawl by
    ///       hundreds of px); clipping in double precision first keeps
    ///       every submitted coordinate small and exact. Assumes the
    ///       1x1 px square sprite, where scale = size in px.
    static draw_square_clipped = function(_spr, _x, _y, _size, _col, _a) {
        var _x2 = min(_x + _size, room_width + 64);
        var _y2 = min(_y + _size, room_height + 64);
        var _cx = max(_x, -64);
        var _cy = max(_y, -64);
        if (_x2 <= _cx || _y2 <= _cy) return;
        draw_sprite_ext(_spr, 0, _cx, _cy, _x2 - _cx, _y2 - _cy, 0, _col, _a);
    };

    /// @func settle_t(progress)
    /// @desc Eased settle amount for a newborn block, from how far the
    ///       block after it has filled. Smoothstepped so blocks arrive
    ///       gently rather than linearly.
    static settle_t = function(_p) {
        var _t = clamp(_p / settle_span, 0, 1);
        return _t * _t * (3 - 2 * _t);
    };

    /// @func active_point_chain(win, top_offset, bot_offset, world_mag)
    /// @desc Shared-coordinate center of the assembling square at
    ///       bot_offset, reached by walking the partial chain down from
    ///       the content field at top_offset: each level's assembling
    ///       slot nests inside the previous level's. This is where new
    ///       squares are actually appearing at the camera's current level
    ///       of detail, which a single saturated field cannot report
    ///       (its clamped slot 99 is not where the action is).
    static active_point_chain = function(_win, _o_top, _o_bot, _wm) {
        var _px = 0;
        var _py = 0;
        for (var _s = _o_top; _s >= _o_bot; _s -= 2) {
            var _d    = _win.get_digits(_s, 5);
            var _slot = (_s == _o_top)
                ? min(_d[0] * 100 + _d[1] * 10 + _d[2], 99)  // content field
                : (_d[1] * 10 + _d[2]);                       // chain child
            // lag back to the newest completed square only when the
            // assembling square is EMPTY (same rule as the grid): if it
            // has live contents, that square is the action, follow it
            if (_s == _o_bot) {
                var _bot_contents = _d[3] * 10 + _d[4];
                if (_bot_contents == 0) _slot = max(_slot - follow_lag, 0);
            }
            var _sq = 10 * unit_for(_s, _wm);
            _px += (_slot mod per_row) * _sq;
            _py += (_slot div per_row) * _sq;
        }
        var _sqb = 10 * unit_for(_o_bot, _wm);
        return { x: _px + _sqb * 0.5, y: _py + _sqb * 0.5 };
    };

    /// @func draw_window(win, offset, unit, x0, y0, alpha, [as_child])
    /// @desc Draw one field. x0/y0 is the TOP-LEFT anchor. Everything
    ///       positional derives from the args this frame. Pure.
    ///
    ///       as_child distinguishes the two count semantics:
    ///       - top-level layer (false): 3-digit count clamped to 100, so
    ///         a field saturates solid at a handoff instead of wrapping
    ///       - recursion child (true): 2-digit count ONLY (offset+3,
    ///         offset+2). A child lives inside its parent's assembling
    ///         square and must count just that square's contents, which
    ///         is the parent's partial by construction, never 100+.
    ///         Reading the 3rd digit would count the parent's completed
    ///         squares too and falsely saturate the child solid.
    static draw_window = function(_win, _offset, _unit, _x0, _y0, _alpha, _as_child = false, _above_drawn = false) {
        if (_alpha <= 0) return;

        // extent cull: a field entirely outside a generous screen margin
        // skips all work (digits, fills, grids, its whole recursion
        // subtree). At deep zoom this is what keeps a dozen giant upper
        // fields from costing anything but their on-path chain.
        var _ext = _unit * 10 * per_row;
        if (_x0 > room_width + 64 || _y0 > room_height + 64
         || _x0 + _ext < -64      || _y0 + _ext < -64) return;

        // magnitudes [offset+4 .. offset-2], most significant first:
        // indexes 0..4 drive counts as before, 5..6 are the sub-digits
        // that drive spawn settle progress. NOTE the anchor: get_digits
        // spans [anchor + count - 1 .. anchor], so a 7-digit window that
        // keeps index 0 at offset+4 must anchor at offset - 2. Anchoring
        // at offset (an earlier bug) shifts every count two magnitudes
        // high: content draws 100x small and disagrees with the camera.
        var _d       = _win.get_digits(_offset - 2, 7);
        var _raw3    = _d[0] * 100 + _d[1] * 10 + _d[2];
        var _full    = _as_child
            ? (_d[1] * 10 + _d[2])
            : min(_raw3, 100);
        var _partial = (_full >= 100) ? 0 : (_d[3] * 10 + _d[4]);

        // NOTE: empty fields deliberately do NOT early-out. Unreached
        // tiers above the value draw their grids (the big frame plus the
        // small grid on slot 0 where the first square will land), the
        // old vis's empty-space lattice. This is safe because empty
        // recursion children can no longer be invoked at all (_child_has
        // gates them), so only intentional top-level empties get here,
        // and the value gate still blanks everything at zero gold.

        var _sq_size  = _unit * 10;                   // squares are flush: pitch = size
        var _col_full = get_tier_color(_offset + 2);  // one square = 10^(offset+2)
        var _col_part = get_tier_color(_offset);      // one unit  = 10^offset

        // ⚖️ A CLAMPED FIELD WEARS ITS PARENT'S COLOUR, FLATLY. This is
        // the fix for "the same square shows up in different colours at
        // different zoom levels" (his three screenshots, 102M profit,
        // one completed square, measured orange / gold / peach).
        //
        // WHAT IS ACTUALLY HAPPENING. A field at offset o-2 spans
        // unit_for(o-2) * 10 * 10 px, and the field at offset o draws its
        // squares at unit_for(o) * 10 px. Those are THE SAME NUMBER - it
        // is the whole telescoping design, 100 squares here being exactly
        // 1 square there. Both fields anchor at the same x0/y0, so the
        // lower field's entire 100-square block lands precisely on the
        // upper field's FIRST square (which is why he saw it on the first
        // square in a row and nowhere else), and it paints SECOND, since
        // visible_layers walks largest offset first.
        //
        // So that one square is painted twice, and the two colours have
        // to agree or the square is whatever the overdraw makes it. They
        // did not agree. The lower field's colour ramped from its OWN
        // tier to its parent's over three counts past the hundred, which
        // means at counts 100, 101 and 102 - a leading mantissa of 1.00
        // to 1.02, entirely ordinary numbers to be sitting on - it
        // painted a BLEND of two tiers over a square that had already
        // been painted its own single correct tier. At 102M that blend is
        // two thirds of the way from tier(6) to tier(8): a third of a
        // purple square laid over a gold one.
        //
        // And the amount of it you see is the lower layer's LOD alpha,
        // which is a pure function of the camera. Hence the same square,
        // the same value, three zoom levels, three colours.
        //
        // THE RAMP WAS SOFTENING A POP THAT DOES NOT EXIST. Crossing 100
        // is a real tier change and both layers make it on the same
        // count: at 99 the field above shows 99 units of tier(o), at 100
        // it shows 1 square of tier(o+2), and the field below completes
        // its hundredth square in the same instant. There was nothing to
        // ease. All the ramp did was hold the two layers in disagreement
        // for three counts. Clamped means redundant means it IS one
        // square of the tier above - so it says so, immediately.
        //
        // It also makes the overdraw harmless in a second way: two
        // opaque paints of the SAME colour cannot show a seam between
        // them, whichever way the sub-pixel edges round.
        // The colour to wear is the colour of THE TOP SQUARE, and that is
        // one number for the whole picture: the value's most significant
        // digit sits at magnitude mag (an exact integer from the digit
        // window, no log rounding), fields sit on even offsets, so the
        // largest completed square is magnitude mag rounded down to the
        // grid. Every clamped field, however deep, is a subdivision of
        // that same square and says so.
        //
        // Paying tier(_offset + 4) instead - the field immediately above
        // - is right for the shallowest clamped field and WRONG for the
        // ones under it, which are subdivisions of a subdivision. Zoom
        // in far enough (lower fields go fully opaque by design, they
        // are the world being zoomed into) and each one would repaint
        // the same square a rung lower. datafiles/vis_twin.py enumerates
        // every stacked pair and fails on exactly that.
        if (!_as_child && _raw3 >= 100) {
            var _top_sq = 2 * (max(_win.magnitude(), 0) div 2);
            _col_full   = get_tier_color(_top_sq);
        }

        // recurse into the assembling square while units stay legible:
        // the sub-field's squares ARE this field's units, flush and
        // identically colored, so it overdraws seamlessly and adds two
        // more digits of detail (plus its own grids and labels).
        // _rec_a ramps 0..1 across recurse_fade px of unit size, so the
        // sub-level fades in/out with zoom instead of popping
        var _rec_a   = clamp((_unit - recurse_min_unit) / recurse_fade, 0, 1);

        // a child with nothing to show (assembling square empty AND no
        // sub-digits beneath it, which is exactly the state at the
        // fake_floor bottom) does not exist: no recursion, and _rec_a
        // zeroes so the grid crossfade hands the small grid BACK to this
        // level instead of fading it toward a child that never arrives.
        // The lowest tier is a terminus: its own grid, no sub-blocks.
        var _child_has = (_partial > 0) || (_d[5] * 10 + _d[6] > 0);
        var _recurse   = (_rec_a > 0) && (_full < 100) && _child_has;
        if (!_recurse) _rec_a = 0;
        var _px      = _x0 + (_full mod per_row) * _sq_size;
        var _py      = _y0 + (_full div per_row) * _sq_size;

        // ---- grid setup + UNDER pass ----
        // Alphas and placement are computed once here; pieces flagged
        // under draw now, pieces flagged over draw after the fills.
        var _grid_n   = (grid_sprite != -1) ? sprite_get_number(grid_sprite) : 0;
        var _ga_big   = 0;
        var _ga_small = 0;
        var _ggx = 0;
        var _ggy = 0;
        var _gs_small = _unit / grid_px_per_unit;
        var _col_big  = get_tier_color(_offset + 4);
        if (_grid_n > 0) {
            var _vgate    = clamp(_win.magnitude(), 0, 1);
            var _field_px = per_row * _sq_size;
            _ga_big = grid_fade(_field_px, _full / 100) * grid_alpha * _vgate * _alpha;
            if (_full < 100 && _rec_a < 1 && _offset >= unit_floor) {
                _ga_small = grid_fade(_sq_size, _partial / 100) * grid_alpha * _vgate * _alpha * (1 - _rec_a);
                var _gslot = (_partial > 0) ? _full : max(_full - 1, 0);
                _ggx = _x0 + (_gslot mod per_row) * _sq_size;
                _ggy = _y0 + (_gslot div per_row) * _sq_size;
            }
            if (_grid_n >= 3) {
                draw_grid_set(_x0, _y0, _unit, _col_big, _ga_big, false);
                draw_grid_set(_ggx, _ggy, _gs_small, _col_full, _ga_small, false);
            }
        }

        // ⚖️ A CLAMPED FIELD DRAWS NO FILLS WHEN THE FIELD ABOVE IS ALSO
        // BEING DRAWN. Its 100 squares span exactly that field's first
        // square, which that field has already painted - they are pure
        // redundancy, and redundant paint is the whole hazard: two paints
        // of one rectangle are only invisible while they agree, and what
        // you see when they disagree is decided by LOD alpha, which is the
        // camera. Painting once makes the agreement structural instead of
        // a promise, and skips up to 100 draw calls a layer.
        //
        // SAFE BY THE EXTENT CULL, not by hope: every field shares _x0/_y0
        // and a higher offset has a LARGER extent, so any field that
        // survives the cull is survived by every field above it. And a
        // field above a clamped one always has at least one full square
        // (that is what clamped MEANS), so slot 0 is always painted. When
        // the host says the field above is absent - the layer cull can
        // drop middles - the fills draw, in the colour set below.
        // NOTHING DIMS, and that is provable rather than hoped: layer
        // alpha rises with offset, so the field above is never fainter -
        // and it is never merely fainter either. alpha(o+2) < 1 needs
        // wm > o + 2.85, alpha(o) > 0 needs wm < o + 1.15, and no camera
        // is in both places. Whenever a clamped field can be seen at all,
        // the field above it is at alpha exactly 1. One opaque paint.
        var _fill_n = (!_as_child && _full >= 100 && _above_drawn) ? 0 : _full;

        // full squares: one draw call each, left to right, top to bottom.
        // The newest settles in as the assembling square fills behind it
        for (var s = 0; s < _fill_n; s++) {
            var _sx = _x0 + (s mod per_row) * _sq_size;
            var _sy = _y0 + (s div per_row) * _sq_size;
            if (spawn_fx && s == _full - 1 && _full < 100) {
                var _t  = settle_t((_d[3] * 10 + _d[4]) / 100 + (_d[5] * 10 + _d[6]) / 10000);
                var _ss = _sq_size * lerp(spawn_scale, 1, _t);
                var _so = (_sq_size - _ss) * 0.5;
                draw_square_clipped(square_sprite, _sx + _so, _sy + _so, _ss, _col_full, _alpha * lerp(spawn_alpha, 1, _t));
            } else {
                draw_square_clipped(square_sprite, _sx, _sy, _sq_size, _col_full, _alpha);
            }
        }

        if (_partial > 0 && _rec_a < 1) {
            // flat partial square: rows top to bottom, units left to right.
            // Drawn under the fading sub-field; at rest layers are opaque
            // so the overdraw is invisible
            var _rows = _partial div 10;
            var _rem  = _partial mod 10;

            // dissolve toward the sub-pixel floor instead of gating:
            // fills fade over [min_fill_px .. 2.5x] so zooming never
            // snaps a whole partial in or out of existence
            var _fill_a = clamp((_unit - min_fill_px) / (min_fill_px * 1.5), 0, 1);
            if (_fill_a <= 0) {
                _rows = 0;
                _rem  = 0;
            }

            // newest row settles by alpha only (scaling a row sprite
            // would shrink its length and break alignment)
            for (var r = 0; r < _rows; r++) {
                var _ra = _alpha * _fill_a;
                if (spawn_fx && r == _rows - 1) {
                    _ra *= lerp(spawn_alpha, 1, settle_t((_rem * 10 + _d[5]) / 100));
                }
                port_vis_line(line_sprite, _px, _py + r * _unit, _unit, _col_part, _ra);
            }

            // newest unit settles by alpha and centered scale
            for (var u = 0; u < _rem; u++) {
                var _ux = _px + u * _unit;
                var _uy = _py + _rows * _unit;
                if (spawn_fx && u == _rem - 1) {
                    var _ut = settle_t((_d[5] * 10 + _d[6]) / 100);
                    var _us = _unit * lerp(spawn_scale, 1, _ut);
                    var _uo = (_unit - _us) * 0.5;
                    port_vis_square(square_sprite, _ux + _uo, _uy + _uo, _us, _col_part, _alpha * _fill_a * lerp(spawn_alpha, 1, _ut));
                } else {
                    port_vis_square(square_sprite, _ux, _uy, _unit, _col_part, _alpha * _fill_a);
                }
            }

            // row label at the right end of the last full row, old
            // vis_line style: only once rows are legible, handing off to
            // the sub-field's labels as recursion fades in
            if (_rows > 0 && _unit > 5) {
                var _rlfa = clamp((_unit - 5) / 3, 0, 1);   // fade in, no pop
                var _rls  = (_unit / 10) * 1.1;
                draw_label(get_label(_offset + 1, _rows),
                           _px + per_row * _unit, _py + _rows * _unit, _rls,
                           label_color(_offset + 2), _alpha * label_alpha * (1 - _rec_a) * _rlfa,
                           _sq_size);
            }
        }


        // ---- grid OVER pass ----
        if (_grid_n >= 3) {
            draw_grid_set(_x0, _y0, _unit, _col_big, _ga_big, true);
            draw_grid_set(_ggx, _ggy, _gs_small, _col_full, _ga_small, true);
        } else if (_grid_n > 0) {
            // legacy single-image grid sprite: one draw, over the fills
            if (_ga_big > 0) {
                draw_sprite_ext(grid_sprite, 0, _x0, _y0, _unit, _unit, 0, _col_big, _ga_big);
            }
            if (_ga_small > 0) {
                draw_sprite_ext(grid_sprite, 0, _ggx, _ggy, _gs_small, _gs_small, 0, _col_full, _ga_small);
            }
        }

        // full-square label: bottom-right of the last full square, colored
        // the tier above (cutout look), sized by how full the field is.
        // Suppressed at saturation (full == 100): a solid field's corner
        // coincides exactly with its parent square's corner, and the
        // parent's label there already states the same quantity one tier
        // up. The old vis never had this case since levels held single
        // digits, so "100" was always expressed by the level above.
        if (_full > 0 && _full < 100 && _sq_size > 5) {
            var _lfa = clamp((_sq_size - 5) / 3, 0, 1);   // fade in, no pop
            var _ls  = (_sq_size / 10) * lerp(0.1, 1.1, _full / 100);
            var _lx  = _x0 + (((_full - 1) mod per_row) + 1) * _sq_size;
            var _ly  = _y0 + (((_full - 1) div per_row) + 1) * _sq_size;
            draw_label(get_label(_offset + 2, _full), _lx, _ly, _ls,
                       label_color(_offset + 2), _alpha * label_alpha * _lfa,
                       _sq_size);
        }

        if (_recurse) {
            // sub-field on top, fading with _rec_a, counted in child mode
            draw_window(_win, _offset - 2, _unit / 10, _px, _py, _alpha * _rec_a, true, false);
        }

        // ---- THE FIELD LEDGER (debug) ----
        // Claude cannot run the game, so when a colour is wrong on screen
        // and provably right in the source, the missing evidence is what
        // the numbers actually were. This prints one line per field per
        // frame - offset, layer alpha, unit px, recursion mix, the counts,
        // and the two colours the field is painting with - which is
        // exactly the set that decides every pixel it draws.
        //
        // Turn it on in obj_bignum5's Create: vis.renderer.debug = true;
        if (debug) {
            var _w = per_row * _sq_size;
            draw_set_alpha(_alpha * 0.5);
            draw_rectangle(_x0, _y0, _x0 + _w, _y0 + _w, true);

            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_set_font(label_font);
            draw_text(4, 40 + dbg_row * 10,
                (_as_child ? "  ch " : "top ")
                + "o" + string(_offset)
                + " a" + string_format(_alpha, 1, 2)
                + " u" + string_format(_unit, 1, 2)
                + " r" + string_format(_rec_a, 1, 2)
                + " f" + string(_full) + "/" + string(_raw3)
                + " p" + string(_partial)
                + " sq " + __dbg_col(_col_full)
                + " un " + __dbg_col(_col_part));
            dbg_row++;
        }
    };
}
