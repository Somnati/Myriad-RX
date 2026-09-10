//
// THE POINTER, RAYCAST (his ask, 2026-09-10: "a raycast mouse sprite
// that looks exactly like the one we got"). The dice and the puck are
// per-pixel raymarched solids seen top-down through orthographic rays;
// this is the same construction for the arrow - an EXTRUDED ARROW with
// rounded edges, lit by the same light with the same diffuse / specular
// / rim model - with two things decided differently, both for the word
// "exactly":
//
//  1. THE SILHOUETTE IS THE SPRITE'S. A polygon rasterised by one ray
//     per pixel would agree with the hand-placed pixels of spr_cursor
//     most of the time and disagree at a corner or two, and a pointer
//     that is one pixel different from the one he drew is not "exactly
//     the one we got". So coverage - and the black outline ring - are
//     READ FROM THE SPRITE TEXTURE, texel for texel. The raycast only
//     decides what the white pixels look like.
//
//  2. THE RAY IS SOLVED, NOT MARCHED. A top-down orthographic ray into a
//     shape with no overhangs hits the height field at the pixel it
//     started over: z = profile(distance to the edge). Marching 40
//     steps to find a point you can name in one line is the puck's
//     method for the puck's reason (it tumbles; this does not). The
//     normal is the profile's slope along the 2D gradient of the
//     arrow's signed distance - the same field the height came from,
//     so shading and silhouette cannot disagree, which is the dice's
//     rule too.
//
// The arrow's 2D field is a polygon SDF through the outline pixels'
// centres (in sprite px, origin the sprite's top-left), so distance 0
// runs through the black ring and the bevel of radius R spans that ring
// and the first white pixel in: the outline reads as the edge falling
// away, the white just inside catches the light on the lit side and
// shades on the other, and the flat top is a plain lit white. Every
// cell is one room pixel (the texel), the house pixelation rule.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  u_uv;    // the sprite's texel rect on its page: u0 v0 u1 v1
uniform vec4  u_trim;  // xoff yoff (trimmed origin, px) + w h (trimmed size, px)
uniform vec3  u_light; // direction TO the light, view space (the dice's)
uniform float u_on;    // 0 = the flat sprite, unlit (the setting)

const float R = 2.3;   // bevel radius, sprite px
const int   N = 7;     // the arrow's outline, clockwise from the tip

vec2 vert(int i)
{
    // spr_cursor's outline, pixel centres (16x16, tip at 3,2)
    if (i == 0) return vec2( 4.5,  2.5);   // the tip
    if (i == 1) return vec2(13.5,  7.5);   // right shoulder
    if (i == 2) return vec2(13.5, 10.5);   // right side, foot of the vertical
    if (i == 3) return vec2( 6.5, 14.5);   // tail, right
    if (i == 4) return vec2( 5.5, 14.5);   // tail, left
    if (i == 5) return vec2( 2.5,  8.5);   // left side, foot of the vertical
    return vec2( 2.5,  3.5);               // left shoulder
}

// signed distance to the polygon: negative inside (iq's construction)
float sd_arrow(vec2 p)
{
    float d = dot(p - vert(0), p - vert(0));
    float s = 1.0;
    for (int i = 0; i < N; i++) {
        int j = (i == 0) ? N - 1 : i - 1;
        vec2 a = vert(i);
        vec2 b = vert(j);
        vec2 e = b - a;
        vec2 w = p - a;
        vec2 c = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
        d = min(d, dot(c, c));
        bvec3 cnd = bvec3(p.y >= a.y, p.y < b.y, e.x * w.y > e.y * w.x);
        if (all(cnd) || all(not(cnd))) s = -s;
    }
    return s * sqrt(d);
}

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);
    if (tex.a < 0.5) discard;                 // the sprite decides coverage
    if (u_on < 0.5) { gl_FragColor = tex * v_vColour; return; }

    // the black ring is the sprite's own; it stays, catching only the rim
    float ink = step(tex.r + tex.g + tex.b, 1.2);

    // texel -> sprite px, at the texel's centre (one cell per room px)
    vec2 sp = u_trim.xy + (v_vTexcoord - u_uv.xy) / (u_uv.zw - u_uv.xy) * u_trim.zw;
    sp = floor(sp) + 0.5;

    // the height field: e = depth inside the edge; a quarter-round bevel
    // of radius R up to a flat top. The slope is dz/de; the normal tilts
    // OUTWARD along the field's gradient by it.
    float d = sd_arrow(sp);
    float e = clamp(-d, 0.0, R);
    float u = 1.0 - e / R;                    // 1 at the wall, 0 at the top
    float slope = (e < R) ? u / max(sqrt(1.0 - u * u), 0.08) : 0.0;
    vec2 h = vec2(0.35, 0.0);
    vec2 g = normalize(vec2(sd_arrow(sp + h.xy) - sd_arrow(sp - h.xy),
                            sd_arrow(sp + h.yx) - sd_arrow(sp - h.yx)) + vec2(0.00001));
    vec3 n = normalize(vec3(g * slope, 1.0));

    // ---- lighting, the dice's model, on a white matte body ----
    vec3 body = vec3(0.97);
    float df  = clamp(dot(n, u_light), 0.0, 1.0);
    vec3 col = body * (0.50 + 0.58 * df);   // flat top ~85% white, lit bevel to 100%
    vec3 rf = reflect(vec3(0.0, 0.0, -1.0), n);
    float sp2 = pow(clamp(dot(rf, u_light), 0.0, 1.0), 14.0);
    col += vec3(1.0) * sp2 * 0.22;
    float fr = pow(1.0 - clamp(abs(n.z), 0.0, 1.0), 2.0);
    col += vec3(1.0) * fr * 0.10;

    // the ring: ink, with the rim catch alone - the edge falling away
    vec3 ring = vec3(0.02) + vec3(0.14) * fr;   // stays ink; the rim only lifts it a shade
    col = mix(col, ring, ink);

    gl_FragColor = vec4(clamp(col, 0.0, 1.0), 1.0) * v_vColour;
}
