/// @description  bezier_set_point(x, y);
/// @param x
/// @param y

function bezier_set_point(argument0, argument1) {

        _lx[_bpoints] = argument0;
        _ly[_bpoints] = argument1;

        if (_bpoints != 0) {
            _point_dist += point_distance(_lx[_bpoints - 1], _ly[_bpoints - 1], _lx[_bpoints], _ly[_bpoints]);
        }

        _bpoints += 1;

}



