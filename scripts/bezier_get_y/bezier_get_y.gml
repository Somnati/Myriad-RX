/// @description  bezier_get_y(y);
/// @param y

function bezier_get_y() {
    _b1 = _ly[0] + (_ly[1] - _ly[0]) * _zero;
    _b2 = _ly[1] + (_ly[2] - _ly[1]) * _zero;

    if (argument0 <= 2) {
        return _b1;
    }

    _c1 = _b1 + (_b2 - _b1) * _zero;

    if (argument0 == 3) {
        return _c1;
    }

    _b3 = _ly[2] + (_ly[3] - _ly[2]) * _zero;
    _c2 = _b2 + (_b3 - _b2) * _zero;

    if (argument0 == 4) {
        return _c1 + (_c2 - _c1) * _zero;
    }
}
