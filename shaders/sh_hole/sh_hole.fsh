// sh_hole - A BLACK HOLE (2026-09-17, his ask: "some stars I want to be replaced with black holes"; the MARCHED
// RAY since q195 - his asks: "is the disc supposed to be bright all the way around", "a subtle black outline",
// "look a little more natural"). Every pixel casts a ray toward the hole and the ray FALLS: the Schwarzschild
// null geodesic (d2x = -3/2 rs h2 x / r^5, h the ray's angular momentum), stepped in units of the shadow's
// radius (the shadow, 2.6 rs, is 1; rs = .385). What the ray meets is what the pixel shows: the ACCRETION DISC
// where the ray crosses its plane (a flat annulus in the galactic plane - u_cam turns it to the view - banded and
// grained, Keplerian, Doppler-boosted: the side coming toward the eye bright and blue, the receding side dim and
// red), crossed twice by the rays that bend round the hole - so the disc's FAR SIDE stands up over and under the
// shadow, the look of the thing; the HORIZON if it falls in (black; the shadow is where the rays fall, not a drawn
// disc); else THE SKY, read from a copy of the page under the hole (hole_draw takes it: the quad's own texture)
// where the escaped ray meets a plane a way behind - so the sky bends by the same geometry as the disc, and the
// bend eases to nothing by the quad's edge (no seam: the old screen-space pull had one). A photon ring, a hairline
// of light, just outside the shadow. Output PREMULTIPLIED: hole_draw blends (one, inv_src_alpha) with the page's
// alpha untouched - the bent sky replaces, the disc lies over, the ring adds
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_col;      // the disc's colour
uniform float u_seed;
uniform float u_time;
uniform float u_rh;       // the shadow's radius in quad units (the quad half is 1)
uniform float u_fade;
uniform float u_dither;
uniform vec3  u_cam[3];   // the view's camera (view -> world), rows
uniform vec2  u_uv;       // the quad's share of the lens texture (the copy sits at its top-left corner)

float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
float vn2(vec2 p)
{
    vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash12(i), hash12(i + vec2(1.0, 0.0)), f.x), mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), f.x), f.y);
}

void main()
{
    vec2 p = v_vTexcoord / u_uv * 2.0 - 1.0;   // quad units, -1..1
    float pl = length(p);
    float R = u_rh;
    const float RS = 0.385;                    // the Schwarzschild radius in shadow radii
    vec3 nrm = normalize(u_cam[1]);            // (world up into view space = the camera's second ROW; q192)
    vec3 e1 = normalize(cross(nrm, (abs(nrm.z) < 0.9) ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0)));
    vec3 e2 = cross(nrm, e1);
    // ---- the ray, in shadow radii: from the eye's side, straight in ----
    vec3 x = vec3(p / R, 8.0);
    vec3 v = vec3(0.0, 0.0, -1.0);
    vec3 hh = cross(x, v);
    float h2 = dot(hh, hh);
    vec3 dcol = vec3(0.0);
    float dacc = 0.0;
    float side0 = dot(x, nrm);
    float captured = 0.0, done = 0.0;
    for (int i = 0; i < 96; i++) {
        float rr = length(x);
        if (rr < RS * 1.05) { captured = 1.0; done = 1.0; break; }
        if (x.z < -7.0 || rr > 14.0) { done = 1.0; break; }   // (away: past the hole, or flung off any way - counted captured before, a dark ring; bug hunt 2026-09-18)
        float dt = clamp(rr * 0.25, 0.06, 0.5);
        vec3 acc = -1.5 * RS * h2 * x / (rr * rr * rr * rr * rr);
        v = normalize(v + acc * dt);
        vec3 xn = x + v * dt;
        float side1 = dot(xn, nrm);
        if (side0 * side1 < 0.0 && dacc < 0.97) {
            // THE DISC's plane crossed: what the disc is at that point
            float t = side0 / (side0 - side1);
            vec3 hp = mix(x, xn, t);
            float rho = length(hp);
            if (rho > 2.2 && rho < 4.6) {
                float ang = atan(dot(hp, e2), dot(hp, e1));
                float om = 1.6 / pow(rho, 1.5);   // (Keplerian: the inner rim races)
                float aa = ang + u_time * om + u_seed * 2.0;
                float bands = 0.55 + 0.45 * vn2(vec2(rho * 3.0 + u_seed, 0.0));
                float grain = 0.6 + 0.6 * vn2(vec2(aa * 4.0, rho * 6.0));
                float edge = smoothstep(2.2, 2.6, rho) * (1.0 - smoothstep(3.6, 4.6, rho));
                float dens = bands * grain * edge;
                // DOPPLER: the flow's direction here against the light's way back to the eye (softer than before:
                // the receding side dimmed to nothing - his question 2026-09-17)
                vec3 tang = normalize(cross(nrm, hp));
                float toward = -dot(tang, v);
                float boost = clamp(1.0 + 1.1 * toward, 0.35, 2.2);
                vec3 shift = mix(vec3(1.0, 0.55, 0.35), vec3(0.75, 0.85, 1.0), clamp(0.5 + 0.5 * toward, 0.0, 1.0));
                float heat = 1.0 - smoothstep(2.2, 4.6, rho);   // (hot inside, cool at the rim)
                vec3 c = mix(u_col, vec3(1.0), 0.35 * heat) * shift * dens * boost * (0.6 + 1.2 * heat);
                float al = clamp(dens * 1.4, 0.0, 1.0);
                dcol += c * (1.0 - dacc);
                dacc += al * (1.0 - dacc);
            }
        }
        x = xn; side0 = side1;
    }
    if (done < 0.5) captured = 1.0;   // (still circling the photon sphere: dark)
    // ---- the sky the escaped ray meets: the page's copy, read where the ray crosses a plane behind the hole ----
    vec3 sky = vec3(0.0);
    float asky = 1.0 - smoothstep(0.86, 0.99, pl);   // (the quad's corners: the page stands)
    if (captured < 0.5) {
        float tz = (-6.0 - x.z) / min(v.z, -0.05);
        vec2 q = (x.xy + v.xy * tz) * R;
        float lens = 1.0 - smoothstep(0.78, 0.98, pl);   // (the bend eased to nothing by the edge: no seam)
        q = mix(p, q, lens);
        float qo = max(abs(q.x), abs(q.y));
        vec2 uv = clamp(q * 0.5 + 0.5, 0.0, 1.0) * u_uv;
        sky = texture2D(gm_BaseTexture, uv).rgb * (1.0 - 0.6 * smoothstep(0.9, 1.5, qo));   // (past the copy: the edge, dimmed)
        // where the sample compresses (near the shadow) the light piles up: the Einstein ring
        sky *= 1.0 + 1.2 * exp(-pow((pl / R - 1.15) / 0.22, 2.0));
    }
    // ---- the photon ring: a hairline just outside the shadow ----
    float prr = pl / R;
    float pr = exp(-pow((prr - 1.06) / 0.06, 2.0)) * 2.0 + exp(-pow((prr - 1.06) / 0.18, 2.0)) * 0.45;
    vec3 ring = mix(u_col, vec3(1.0), 0.55) * pr;
    // ---- premultiplied: the sky where it is replaced, the disc over, the ring added ----
    vec3 pm = asky * sky * (1.0 - dacc) + dcol + ring;
    float a = asky + (1.0 - asky) * clamp(dacc, 0.0, 1.0);
    pm *= u_fade; a *= u_fade;
    // the dither on an 8-bit page
    float fr = floor(u_time * 60.0);
    vec2 ip = floor(gl_FragCoord.xy) + vec2(fr * 13.0, fr * 7.0);
    float g = hash12(ip);
    float lum = dot(pm, vec3(0.299, 0.587, 0.114));
    pm += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither * a;
    gl_FragColor = vec4(max(pm, vec3(0.0)), a) * v_vColour;
}
