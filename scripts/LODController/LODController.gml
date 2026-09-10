/// scr_lod_controller
/// LODController v3: continuous camera, seamless endless zoom.
///
/// DEPARTURE FROM THE ORIGINAL SPEC, on purpose: the STABLE/TRANSITIONING
/// state machine is gone. Discrete timed transitions can never feel like
/// endless zoom, so the model is now one continuous number:
///
///   wm  (world magnitude): the camera's position along the OOM axis,
///        eased toward (focus magnitude + manual zoom bias - band_anchor),
///        unbounded upward, floored at wm_min.
///
/// Fields exist at every even offset. A field anchored at offset o is
/// centered at wm = o, fully visible for |wm - o| < 1 - fade_width, and
/// crossfades linearly to its neighbor across a 2*fade_width region at
/// |wm - o| = 1. Complementary alphas: they always sum to 1 through a
/// handoff. Combined with flush squares in the renderer, 100 squares of
/// one field are geometrically identical to 1 square of the next, so the
/// handoff is invisible.
///
/// The spec's goals all still hold, just without machinery:
///   - no pop: geometry is continuous through boundaries by construction
///   - no double-fire: there is nothing to fire; alpha is a pure function
///     of camera position
///   - multi-tier: a 4 OOM rate jump just means the camera sweeps through
///     two boundaries on its way to the new target

function LODController() constructor {
    // ---- tuning ----
    zoom_smooth     = 5.0;    // camera ease speed (higher = snappier)
    // ⚖️ A FALLING VALUE ZOOMS IN SLOWLY (his report, 2026-09-10: "a
    // weird zoom when autobuy buys something... snaps the zoom really
    // close after it buys something that eats most of what it's earned").
    // Growth is continuous, so the one ease read as a glide; a purchase
    // is a STEP down of an order of magnitude or two, and the same ease
    // ran the camera in over it in half a second. The focus magnitude
    // is eased on its own first - at zoom_smooth when it rises, at this
    // when it falls - so a spend drifts the camera in over a few seconds
    // while earning still tracks as it did. The wheel (manual_bias) is
    // not in that ease and stays as snappy as before.
    zoom_smooth_drop = 0.8;
    band_anchor     = 3;      // MUST stay 3. This aligns field handoffs
                              // to land exactly at count 100: a field
                              // finishes filling at the same moment its
                              // successor fades in. Any other value opens
                              // a saturation gap where a solid field sits
                              // alone with growth invisible inside it.
                              // Overall zoom feel is renderer.base_unit,
                              // startup framing is vis.set_start_scale
    fade_width      = 0.15;   // crossfade half-width at handoffs, in OOMs
    digits_per_band = 2;      // OOMs per field
    wm_min          = -1.5;   // camera floor. Do not hand-tune this:
                              // use vis.set_start_scale(px) instead, which
                              // converts a desired startup unit size in px
                              // to the right floor and keeps it inside
                              // field -2's clean plateau. Raising the
                              // floor zooms the start OUT; bias and
                              // band_anchor cannot affect startup because
                              // the floor swallows the unclamped target
                              // until the value grows.

    // ---- state ----
    wm          = -1.5; // continuous world magnitude (the camera)
    focus_mag   = 0;
    focus_eased = undefined; // focus_mag through the asymmetric ease (update)
    manual_bias = 0;    // scroll zoom, in OOMs, unbounded: endless both ways

    /// @func set_focus_magnitude(mag)
    static set_focus_magnitude = function(_mag) {
        focus_mag = _mag;
    };

    /// @func apply_zoom_input(delta)
    /// @desc Positive = zoom out (higher OOMs), negative = zoom in.
    static apply_zoom_input = function(_delta) {
        manual_bias += _delta;
    };

    /// @func world_magnitude()
    static world_magnitude = function() {
        return wm;
    };

    /// @func update(dt)
    static update = function(_dt) {
        // the focus, eased asymmetrically (see zoom_smooth_drop): the
        // first frame seats it, a rise chases at the camera's own speed,
        // a fall drifts
        if (focus_eased == undefined) focus_eased = focus_mag;
        var _k = (focus_mag < focus_eased) ? zoom_smooth_drop : zoom_smooth;
        focus_eased += (focus_mag - focus_eased) * min(1, _k * _dt);
        if (abs(focus_mag - focus_eased) < .0005) focus_eased = focus_mag;
        var _target = max(wm_min, focus_eased + manual_bias - band_anchor);
        wm += (_target - wm) * min(1, zoom_smooth * _dt);
    };

    /// @func layer_alpha(offset)
    /// @desc Visibility of the field at `offset`. ASYMMETRIC on purpose:
    ///       a field only fades as the camera rises ABOVE it (the field
    ///       shrinking into a unit, handing off upward). A field the
    ///       camera has dropped BELOW stays fully opaque: its giant
    ///       squares are the world being zoomed into, and it is the only
    ///       layer holding the content beyond the lower field's 100-square
    ///       capacity. Symmetric fading here loses that content on manual
    ///       zoom-in (the vanishing-remainder bug).
    static layer_alpha = function(_off) {
        var _d = wm - _off;
        return clamp((-_d + 1 + fade_width) / (2 * fade_width), 0, 1);
    };

    /// @func visible_layers(max_mag)
    /// @desc Every field to draw, largest scale first so finer layers
    ///       overdraw on top. Spans from the smallest visible field up to
    ///       the display value's own magnitude (fields above that are
    ///       empty), capped: layers far above the camera only paint the
    ///       occluded interior of one offscreen square.
    static visible_layers = function(_max_mag) {
        // Always spans up to the CONTENT field: it carries the recursion
        // chain that supplies everything near a deeply zoomed camera, so
        // it can never be evicted (a previous +10 span cap dropped it at
        // ~12 bands of manual zoom and the whole view went empty). When
        // the span is large, MIDDLE fields are dropped instead: their
        // chains duplicate the content field's chain, and their own
        // blocks sit offscreen at the slot-0 corner at that depth.
        var _out = [];
        var _lo  = digits_per_band * ceil((wm - 1 - fade_width) / digits_per_band);
        var _hi  = digits_per_band * ceil(_max_mag / digits_per_band);
        // the ceiling also follows the CAMERA, not just the content:
        // zooming out past the value ascends into unreached tiers, and
        // those must be enumerated so their empty grids can draw (the
        // old vis showed the coming tiers' lattice in empty space)
        _hi = max(_hi, digits_per_band * ceil((wm + 1 + fade_width) / digits_per_band));
        _hi = max(_hi, _lo);
        var _keep_top    = 4;   // fields kept at the content end
        var _keep_bottom = 3;   // fields kept nearest the camera
        for (var _o = _hi; _o >= _lo; _o -= digits_per_band) {
            if (_o > _hi - digits_per_band * _keep_top
             || _o < _lo + digits_per_band * _keep_bottom) {
                var _a = layer_alpha(_o);
                if (_a > 0) array_push(_out, { offset: _o, alpha: _a });
            }
        }
        return _out;
    };
}
