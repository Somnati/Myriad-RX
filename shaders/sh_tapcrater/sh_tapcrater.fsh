//
// THE IMPACT CRATER (his trial, 2026-09-10): a tap presses a shallow
// bowl into the table plane for a few frames, lit by the dice's light.
// The bowl is a height field z = -D (1 - r^2)^2 over the tap's radius;
// its normal is the field's slope, and what is DRAWN is only the
// lighting DIFFERENCE from the flat plane - a rim highlight where the
// bowl's wall faces the light, a shadow where it faces away - painted
// as white or black at that difference's strength. Nothing where the
// plane is flat, so the room shows through untouched, and the dent
// relaxes as D decays. One ray per room-pixel cell, the puck's
// quantizer, so the dent is as blocky as the table.
//
varying vec2 v_pos;

uniform vec4  u_quad;    // quad x, y, w, h in room px
uniform vec2  u_c;       // the tap, room px
uniform float u_r;       // the bowl's radius, px
uniform float u_depth;   // D, px (decays to 0)
uniform vec3  u_light;   // direction TO the light, view space
uniform float u_cells;   // cells across the quad

void main()
{
    vec2 q = (v_pos - u_quad.xy) / u_quad.zw;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 rp = u_quad.xy + q * u_quad.zw;

    vec2 d = rp - u_c;
    float rr = length(d) / u_r;
    if (rr >= 1.0 || rr < 0.001) discard;

    // z = -D (1 - rr^2)^2  ->  dz/drr = 4 D rr (1 - rr^2); per px: / u_r
    float slope = 4.0 * u_depth * rr * (1.0 - rr * rr) / u_r;
    vec2 g = (d / length(d)) * slope;             // the field rises outward: grad z
    vec3 n = normalize(vec3(-g, 1.0));
    float df  = dot(n, u_light);
    float df0 = u_light.z;                        // the flat plane's
    float delta = (df - df0) * 1.6;
    float edge = 1.0 - rr * rr * rr * rr;         // no hard rim at the bowl's lip
    if (delta > 0.0) gl_FragColor = vec4(1.0, 1.0, 1.0, clamp(delta, 0.0, 1.0) * edge);
    else             gl_FragColor = vec4(0.0, 0.0, 0.0, clamp(-delta, 0.0, 1.0) * edge);
}
