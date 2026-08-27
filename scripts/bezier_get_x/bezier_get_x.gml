/// @description  bezier_get_x(x);
/// @param x

function bezier_get_x(argument0) {
    _b1 = _lx[0] + (_lx[1] - _lx[0]) * _zero;

    if (argument0 <= 2) {
        return _b1;
    }

    _b2 = _lx[1] + (_lx[2] - _lx[1]) * _zero;

    if (argument0 <= 3) {
        return _b1 + (_b2 - _b1) * _zero;
    }

    _b3 = _lx[2] + (_lx[3] - _lx[2]) * _zero;
    _c1 = _b1 + (_b2 - _b1) * _zero;
    _c2 = _b2 + (_b3 - _b2) * _zero;

    if (argument0 >= 4) {
        return _c1 + (_c2 - _c1) * _zero;
    }
}
