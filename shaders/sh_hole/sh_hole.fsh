// sh_hole - A BLACK HOLE (2026-09-17, his ask: "some stars I want to be replaced with black holes"). The quad's
// texture is a COPY of the page under the hole (hole_draw takes it): the sky already painted there, so the
// starlight can be BENT round the horizon in screen space - every pixel outside the horizon reads the copy at a
// point pulled inward by 1/r^2, and at the Einstein radius everything piles into a ring. Inside the horizon,
// black. A photon ring, a hairline of light, just outside it. The ACCRETION DISC: a flat annulus in the galactic
// plane (u_cam turns it to the view, like the orbits), banded and grained, turning fast - Keplerian, faster
// inside - and Doppler-boosted: the side coming toward the eye bright and blue-shifted, the receding side dim
// and red-shifted; the half behind the hole hidden by it. Drawn with a plain blend: inside the lens' reach the
// pixel REPLACES the page (the bent sky), beyond it only the disc and the rings add
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3  u_col;      // the disc's colour
uniform float u_seed;
uniform float u_time;
uniform float u_rh;       // the horizon's radius in quad units (the quad half is 1)
uniform float u_fade;
uniform float u_dither;
uniform vec3  u_cam[3];   // the view's camera (view -> world), rows

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
    vec2 p = v_vTexcoord * 2.0 - 1.0;
    float r = length(p);
    float R = u_rh;
    float Rl = R * 1.32;      // the Einstein radius: the sample collapses to the centre here
    float Rlens = R * 2.9;    // the lens' reach: past it the page stands as it was
    // ---- the bent sky ----
    vec3 sky = vec3(0.0);
    float lens = 0.0;
    if (r >= R) {
        float s = 1.0 - (Rl * Rl) / (r * r);
        vec2 q = (s > 0.0) ? p * s : -p * 0.03;
        sky = texture2D(gm_BaseTexture, q * 0.5 + 0.5).rgb;
        // where the sample compresses (near the Einstein radius) the light piles up: brighter
        float pile = exp(-pow((r - Rl) / (0.20 * R), 2.0));
        sky *= 1.0 + 1.4 * pile;
        lens = 1.0 - smoothstep(Rlens * 0.92, Rlens, r);
    }
    // ---- the photon ring ----
    float pr = exp(-pow((r - R * 1.42) / (0.055 * R), 2.0)) * 2.2 + exp(-pow((r - R * 1.42) / (0.16 * R), 2.0)) * 0.5;
    vec3 col = sky * step(R, r) + mix(u_col, vec3(1.0), 0.55) * pr;
    float a = max(lens, step(r, R));
    // ---- the accretion disc: the galactic plane's normal in view space, the ray through the pixel, the plane hit ----
    vec3 nrm = normalize(vec3(u_cam[0].y, u_cam[1].y, u_cam[2].y));
    vec3 ro = vec3(0.0, 0.0, 6.0);
    vec3 rd = normalize(vec3(p.x, p.y, -6.0));
    float dn = dot(rd, nrm);
    float disc = 0.0;
    vec3 dcol = vec3(0.0);
    if (abs(dn) > 0.002) {
        float t = -dot(ro, nrm) / dn;
        if (t > 0.0) {
            vec3 rp = ro + rd * t;
            float rho = length(rp) / R;
            if (rho > 2.2 && rho < 4.6) {
                // its frame: two tangents in the plane, the angle round the hole, the orbit's direction
                vec3 e1 = normalize(cross(nrm, (abs(nrm.z) < 0.9) ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0)));
                vec3 e2 = cross(nrm, e1);
                float ang = atan(dot(rp, e2), dot(rp, e1));
                float om = 1.6 / pow(rho, 1.5);   // (Keplerian: the inner rim races)
                float aa = ang + u_time * om + u_seed * 2.0;
                // the bands and the grain, turning with the flow
                float bands = 0.55 + 0.45 * vn2(vec2(rho * 3.0 + u_seed, 0.0));
                float grain = 0.6 + 0.6 * vn2(vec2(aa * 4.0, rho * 6.0));
                float edge = smoothstep(2.2, 2.6, rho) * (1.0 - smoothstep(3.6, 4.6, rho));
                float dens = bands * grain * edge;
                // DOPPLER: the flow's direction here, and its share toward the eye
                vec3 tang = normalize(cross(nrm, rp));
                float toward = tang.z;
                float boost = clamp(1.0 + 1.5 * toward, 0.15, 2.6);
                vec3 shift = mix(vec3(1.0, 0.55, 0.35), vec3(0.75, 0.85, 1.0), clamp(0.5 + 0.5 * toward, 0.0, 1.0));
                // the hole hides the half behind it (the ray met the horizon first)
                float hidden = (r < R && rp.z < 0.0) ? 0.0 : 1.0;
                dens *= hidden;
                float heat = 1.0 - smoothstep(2.2, 4.6, rho);   // (hot inside, cool at the rim)
                dcol = mix(u_col, vec3(1.0), 0.35 * heat) * shift * dens * boost * (0.6 + 1.2 * heat);
                disc = clamp(dens * boost, 0.0, 1.0);
            }
        }
    }
    col = col * (1.0 - clamp(disc * 0.85, 0.0, 1.0)) + dcol;
    a = max(a, clamp(disc, 0.0, 1.0));
    col *= u_fade;
    // the dither on an 8-bit page
    float fr = floor(u_time * 60.0);
    vec2 ip = floor(gl_FragCoord.xy) + vec2(fr * 13.0, fr * 7.0);
    float g = hash12(ip);
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    col += (g - 0.5) * (min(lum * 255.0 * 0.5, 1.4) / 255.0) * u_dither * a;
    gl_FragColor = vec4(max(col, vec3(0.0)), a * u_fade) * v_vColour;
}
