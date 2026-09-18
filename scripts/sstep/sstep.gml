/// @description sstep(v, a, b) -> a smoothstep on a value (GML has none): 0 below a, 1 above b, the cubic between
function sstep(_v, _a, _b) { var _t = clamp((_v - _a) / max(.0001, _b - _a), 0, 1); return _t * _t * (3 - 2 * _t); }
