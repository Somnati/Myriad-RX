/// @description frame_bearing(az, el) -> [x, y, z]: a MAP bearing (GM's point_direction degrees: 0 east, 90 north, y-down map) and an elevation above the galactic plane, as a unit direction in the SKY'S WORLD FRAME
/// THE FRAME'S LAWS (q216 - written down at last; every handedness bug of
/// 2026-09-17/18 came from these being implicit):
///   - the world: the galactic plane is y = 0; UP is -y (a star's height off
///     the plane, its elevation, goes to -sin el); x is the map's EAST;
///     z is the map's SOUTH (z = -sin az): the view frame below is
///     left-handed seen from above, and +sin put the map's north at the
///     bottom of the page - the whole sky was the map's mirror (q197)
///   - the view: x right, y down, z TOWARD the eye. A sky direction is
///     visible with view z < -.2 (away); the system painter's depth is
///     sy_D - view z (+z nearer). Screen = (cx + vx * 230 / -vz, cy + vy * 230 / -vz)
///   - the camera: cam maps view -> world; world -> view is mat3_apply(mat3_transpose(cam), v);
///     WORLD UP into the view is cam's second ROW (cam[3..5]) - a shader
///     wanting it takes u_cam[1] (the column turned the hole's disc with the
///     camera, q192)
///   - mat3_rot(ax, ay, az, deg) rotates by MINUS deg (the screen-y flip)
///   - an off-centre billboard must be framed by ITS line of sight, not
///     the view's forward (hole_frame, q196)
/// The system's own frame (orbits, the sun, the siblings) is a different
/// thing: orbit angles as (cos a, 0, sin a) with no map meaning
function frame_bearing(_az, _el = 0) {
	var _ce = dcos(_el);
	return [_ce * dcos(_az), -dsin(_el), -_ce * dsin(_az)];
}
