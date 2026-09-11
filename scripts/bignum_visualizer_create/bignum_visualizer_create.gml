/// scr_bignum_visualizer_create
/// Public factory, v3.1. draw() renders every field the continuous camera
/// can see (at most two), largest scale first. set_position now sets the
/// FOCAL POINT: the square currently being assembled centers itself on
/// this point, so parenting it to an object's x/y makes the vis follow
/// the action wherever the object sits (e.g. snapped to room center).
///
/// Usage from a host object:
///
///   Create:
///     vis = bignum_visualizer_create();
///     vis.set_position(8, 7);
///     vis.renderer.grid_sprite = spr_vis_grid;
///     vis.renderer.set_tier_color_callback(function(_oom) { return tier_get_color(_oom div 2); });
///
///   Step:
///     vis.set_position(x, y);                      // follow this object
///     vis.set_display_value(g.resin);
///     vis.set_focus_value(g.all_gps_equivalent);   // whatever rate you track
///     if (mouse_wheel_up())   vis.set_zoom_input(-0.5);
///     if (mouse_wheel_down()) vis.set_zoom_input( 0.5);
///     vis.update(delta_time / 1000000);
///
///   Draw (regular Draw event, room space, NOT Draw GUI):
///     vis.draw();

function bignum_visualizer_create() {
    return {
        display_win: new DigitWindow(),
        lod:         new LODController(),
        renderer:    new BignumVisRenderer(),
        vx:          0,
        vy:          0,
        focus_mag:   0,
        alpha:       1,   // master alpha, multiplied into every layer.
                          // Host can ease this for fade-in (old salpha).

        // ---- additive glow (old spr_glow_sw pass) ----
        glow_sprite: -1,    // 144x144, ORIGIN MUST BE CENTERED (72,72)
        glow_size:   300,   // rendered diameter in px 300
        glow_alpha:  0.1,  // old pass peaked at .35
        glow_pulse:  0,     // 0 = steady. 1 = the old sawtooth: alpha
                            // ramps up across each tier pair and resets,
                            // replicating .35 * frac(gold/2) exactly
                            // (including its hard reset at each pair)
        follow_smooth: 6, // camera ease toward the assembling square
                          // at the auto zoom; the ease goes to INSTANT
                          // as the wheel approaches the freeze (below)

        // ---- THE FREEZE (his ask, 2026-09-11: "the visualizer camera
        // is all over the place due to profit being earned and moving
        // the origin") ----
        // Zoomed in, the camera follows the assembling square at the
        // level nearest it, and that square is placed by the LOW digits
        // - which churn every frame while profit lands. So past
        // freeze_oom of manual zoom-in the display value is a SNAPSHOT:
        // every digit below the leading one is held, and the focus
        // (the auto zoom) is held with it, so nothing on screen moves
        // until you zoom back out. The leading digit stays live: when
        // it (or the magnitude) changes the picture has changed anyway,
        // so the snapshot is retaken. The counter in the header keeps
        // counting - the blocks are the thing being inspected.
        //   zin  0 at the auto zoom .. 1 at the freeze (manual_bias /
        //        -freeze_oom, clamped); the camera's follow ease goes
        //        from follow_smooth to instant along it, so the camera
        //        is exactly ON the target the moment the picture
        //        freezes - no glide finishing over a frozen picture
        freeze_oom:  1,      // wheel OOMs in (two clicks) to freeze
        live_val:    0,      // what the host fed this frame
        frozen:      false,
        frozen_lead: "",     // the snapshot's leading digit
        frozen_mag:  0,      // ...and magnitude
        frozen_focus: 0,
        zin:         0,
        cam_x:       0,   // follow point in pixels, DERIVED each frame
        cam_y:       0,   // from the eased invariant coords below
        cam_kx:      0,   // eased follow point in zoom-INVARIANT space
        cam_ky:      0,   // (units of the content field's square size)
        cam_oc:      -2,  // content-field reference the k coords use

        /// what gets drawn as squares (total profit). Held back while
        /// the freeze is on - see update, which decides per frame
        set_display_value: function(_bignum) {
            live_val = _bignum;
            if (!frozen) display_win.set_value(_bignum);
        },

        /// profit/sec rate: drives the camera target ONLY, never drawn.
        /// Held at the snapshot's while frozen (or the auto zoom would
        /// still creep out under a frozen picture)
        set_focus_value: function(_bignum) {
            focus_mag = frozen ? frozen_focus : bignum_vis_magnitude(_bignum);
        },

        /// startup framing as ONE continuous knob: how many px a single
        /// unit of the lowest field renders at while the camera rests on
        /// the floor. Converts px to the wm_min the LOD needs, clamped to
        /// field -2's clean plateau so resting never straddles a field
        /// crossfade. Wanting units smaller than ~0.4 * base_unit means
        /// lowering renderer.base_unit instead (which scales everything).
        set_start_scale: function(_unit_px) {
            _unit_px   = max(_unit_px, 0.01);   // guard log10(0)
            lod.wm_min = clamp(-2 - 2 * log10(_unit_px / renderer.base_unit), -2.8, -1.2);
            lod.wm     = max(lod.wm, lod.wm_min);
        },

        /// FOCAL POINT in room coordinates: the assembling square centers
        /// here. Call every step with the host object's x/y to parent it.
        set_position: function(_x, _y) {
            vx = _x;
            vy = _y;
        },

        /// endless zoom: negative = in, positive = out, in OOM steps.
        /// scroll wheel now; feed pinch deltas here later.
        set_zoom_input: function(_delta) {
            lod.apply_zoom_input(_delta);
        },

        update: function(_dt) {
            // ---- the freeze (see the fields) ----
            zin = clamp(-lod.manual_bias / max(freeze_oom, .01), 0, 1);
            if (zin >= 1) {
                var _lead = string_char_at(bignum_vis_mantissa_string(live_val), 1);
                var _lmag = bignum_vis_magnitude(live_val);
                if (!frozen || _lead != frozen_lead || _lmag != frozen_mag) {
                    // take (or retake) the snapshot: the leading digit
                    // or the magnitude moved, or the freeze just began
                    display_win.set_value(live_val);
                    frozen       = true;
                    frozen_lead  = _lead;
                    frozen_mag   = _lmag;
                    frozen_focus = _lmag;
                    focus_mag    = _lmag;
                }
            } else if (frozen) {
                // zoomed back out: the live value is the picture again
                frozen = false;
                display_win.set_value(live_val);
                focus_mag = bignum_vis_magnitude(live_val);
            }

            lod.set_focus_magnitude(focus_mag);
            lod.update(_dt);

            // follow the assembling square via the partial CHAIN: from
            // the content field (derived from the display value's
            // magnitude) down to the even level nearest the camera. Zoomed
            // out this is the big partial square; zoomed in it is the spot
            // where the small squares are spawning. One shared pan keeps
            // the flush geometry locked; smoothing is safe because scale
            // never jumps.
            var _wm  = lod.world_magnitude();
            var _mag = display_win.magnitude();
            var _dpb = lod.digits_per_band;
            var _oc  = max(_dpb * floor((_mag - 2) / _dpb), -2);   // content field
            var _ot  = _dpb * floor(_wm / _dpb + 0.5);             // nearest even to camera
            _ot = clamp(_ot, _oc - 300, _oc);
            // effectively unbounded descent: the fake digit strata supply
            // content at any depth and the chain walk is cheap per level,
            // so the camera follows however deep the zoom goes. The 300
            // is only a double-precision overflow guard on the chain's
            // accumulated position (~600 magnitudes of headroom), not a
            // feature limit
            var _p  = renderer.active_point_chain(display_win, _oc, _ot, _wm);

            // EASE IN ZOOM-INVARIANT SPACE. Shared-pixel coordinates
            // rescale exponentially with wm, so easing them directly
            // makes the camera chase a sprinting target while zooming:
            // that lag reads as the view bowing sideways, worse at depth.
            // Instead: divide out the zoom scale, ease the invariant
            // part, multiply the CURRENT frame's scale back on. Zooming
            // then rescales the already-converged camera exactly, and
            // the ease only smooths real changes (slots, chain levels).
            var _ref = renderer.base_unit * power(10, (_oc - _wm) * 0.5);
            var _tkx = _p.x / _ref;
            var _tky = _p.y / _ref;

            // rebase stored coords if the content field stepped
            if (cam_oc != _oc) {
                var _rb = power(10, (cam_oc - _oc) * 0.5);
                cam_kx *= _rb;
                cam_ky *= _rb;
                cam_oc  = _oc;
            }

            // the follow ease: follow_smooth at the auto zoom, INSTANT
            // at the freeze, lerped along the wheel's approach (zin)
            var _k = lerp(min(1, follow_smooth * _dt), 1, zin);
            cam_kx += (_tkx - cam_kx) * _k;
            cam_ky += (_tky - cam_ky) * _k;
            cam_x   = cam_kx * _ref;
            cam_y   = cam_ky * _ref;
        },

        /// call from a room Draw event so surf_scale / camera scale apply
        draw: function() {
            if (alpha <= 0) return;

            var _wm     = lod.world_magnitude();
            var _layers = lod.visible_layers(display_win.magnitude());
            var _n      = array_length(_layers);

            // shared anchor: focal point minus the smoothed follow point
            var _x0 = vx - cam_x;
            var _y0 = vy - cam_y;

            // which offsets are in this frame's list, so each field can
            // be told whether the field above it is drawing. A clamped
            // field's squares exactly cover that field's first square, so
            // when it IS drawing they are redundant paint - and redundant
            // paint over a crossfading layer is a colour that moves with
            // the camera. See BignumVisRenderer's _above_drawn.
            renderer.dbg_row = 0;   // the field ledger stacks per frame

            var _present = {};
            for (var i = 0; i < _n; i++) {
                variable_struct_set(_present, string(_layers[i].offset), true);
            }

            for (var i = 0; i < _n; i++) {
                var _L = _layers[i];
                var _u = renderer.unit_for(_L.offset, _wm);
                var _ab = variable_struct_exists(_present, string(_L.offset + 2));
                renderer.draw_window(display_win, _L.offset, _u, _x0, _y0,
                                     _L.alpha * alpha, false, _ab);
            }

            // additive glow, centered on the focal point. Color is a
            // smooth blend between the dominant on-screen tier and its
            // neighbor: the biggest visible blocks are always the
            // squares around wm + 2, so the camera's continuous
            // magnitude doubles as an average-screen-color proxy that
            // tracks both profit growth and manual zoom, no pixel
            // reads needed.
            if (glow_sprite != -1) {
                var _mc = _wm + 2;
                var _m0 = 2 * floor(_mc / 2);
                var _ft = (_mc - _m0) / 2;
                var _gc = merge_colour(renderer.get_tier_color(_m0),
                                       renderer.get_tier_color(_m0 + 2), _ft);
                var _ga = glow_alpha * lerp(1, _ft, glow_pulse) * alpha;
                if (_ga > 0) {
                    var _gs = glow_size / sprite_get_width(glow_sprite);

                    gpu_set_blendmode(bm_add);
                    draw_sprite_ext(glow_sprite, 0, vx, vy, _gs, _gs, 0, _gc, _ga);
                    gpu_set_blendmode(bm_normal);
	
                }
            }
        }
    };
}
