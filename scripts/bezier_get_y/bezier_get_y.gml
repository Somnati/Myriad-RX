/// @description  bezier_get_y(points);
/// @param points

// Mirrors bezier_get_x exactly. It did not before: the y version
// declared no parameter while using argument0, and it computed _b2 -
// which reads _ly[2] - BEFORE the 2-point early return, so a straight
// 2-point curve indexed a point that was never set. bezier_get_x
// already returned _b1 first and was correct; this now matches it, so
// the two evaluators can be read side by side and trusted alike.
function bezier_get_y(argument0) {
    _b1 = _ly[0] + (_ly[1] - _ly[0]) * _zero;

    if (argument0 <= 2) {
        return _b1;
    }

    _b2 = _ly[1] + (_ly[2] - _ly[1]) * _zero;

    if (argument0 <= 3) {
        return _b1 + (_b2 - _b1) * _zero;
    }

    _b3 = _ly[2] + (_ly[3] - _ly[2]) * _zero;
    _c1 = _b1 + (_b2 - _b1) * _zero;
    _c2 = _b2 + (_b3 - _b2) * _zero;

    if (argument0 >= 4) {
        return _c1 + (_c2 - _c1) * _zero;
    }
}
