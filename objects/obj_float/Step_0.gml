/// pop in, drift up with decaying speed, fade in then out, shrink away

life -= 1 * delta;

if (life > 0) {
	if (alpha < 1) alpha += .2 * delta;
	if (alpha > 1) alpha = 1;
} else {
	alpha -= .25 * delta;
	scale_ = .5; // dying floats shrink as they fade
}
if (alpha <= 0) { kill; exit; }

// scale pops fast at birth, settles, then eases toward the death size
var _adj = 4;
if (pop > 0) { _adj = 10; pop -= 1 * delta; }
if (scale != scale_) scale = move_to(scale, scale_, _adj);

// rise is strongest when fresh and eases off with age
drift_y += rise * clamp(life / life_, 0, 1) * delta;
