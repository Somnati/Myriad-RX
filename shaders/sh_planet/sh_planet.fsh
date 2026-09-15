//
// THE PLANET (the tech demo's sh_planet, ported for the expedition page
// 2026-09-13): per-pixel ray-sphere on a quad. gm_BaseTexture is the
// equirect terrain, u_cloud the cloud alpha map, u_height the HEIGHT
// map. u_rot / u_crot map VIEW space onto TEXTURE space.
//
// MOUNTAINS (his wish from the tech demo: "as it rotates you can see
// the bumpiness of mountain ranges"): the surface is not the unit
// sphere but 1 + u_relief x height(dir). Every ray MARCHES from the
// outer shell inward until it dips under that surface, so the peaks
// stand out of the silhouette and cast their own shading (the normal
// is bent by the height gradient). Twelve steps and a refine; the
// planet is a hundred pixels across, so it is cheap.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_cloud;
uniform sampler2D u_height;
uniform vec3  u_rot[3];
uniform vec3  u_crot[3];
uniform vec3  u_light;
uniform vec3  u_atmo;
uniform vec2  u_tsize;
uniform float u_pad;
uniform float u_time;
uniform float u_dither;   // 1 = dither the gradients here (an 8-bit target), 0 = the page is float and dithers once at its blit
uniform float u_cells;
uniform float u_ring;
uniform vec3  u_raxis;
uniform vec3  u_ringcol;
uniform vec4  u_city[6];
uniform float u_cityn;
uniform float u_relief;
uniform float u_cfade;    // cloud visibility 0..1: zooming in on a region thins the deck (and its shadows) so the land shows through

float cw_h(vec3 p)
{
    p = fract(p * 0.1031);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

const float CB = 1.045;
const float CR = 1.09;

vec2 sphere_uv(vec3 t, vec2 ts)
{
    float v = acos(clamp(t.y, -1.0, 1.0)) / 3.14159265;
    float u = atan(t.z, t.x) / 6.2831853 + 0.5;
    return (floor(vec2(u, v) * ts) + 0.5) / ts;
}

vec3 to_tex(vec3 n)
{
    return vec3(dot(u_rot[0], n), dot(u_rot[1], n), dot(u_rot[2], n));
}

float height_at(vec3 n)
{
    return texture2D(u_height, sphere_uv(to_tex(n), u_tsize)).r;
}

float cloud_at(vec3 n, vec2 ts)
{
    vec3 t = vec3(dot(u_crot[0], n), dot(u_crot[1], n), dot(u_crot[2], n));
    return texture2D(u_cloud, sphere_uv(t, ts)).a * u_cfade;
}

// white noise, no lattice (Hoskins' hash12): the grain that reads as film
// grain, not the diagonal checkerboard interleaved-gradient noise makes
// on pixel cells (his report, 2026-09-15)
float hash12(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float lightband(float d)
{
    return mix(0.10, 1.0, smoothstep(-0.22, 0.30, d));
}

void main()
{
    vec2 q = v_vTexcoord;
    if (u_cells > 0.5) q = (floor(q * u_cells) + 0.5) / u_cells;
    vec2 p = (q * 2.0 - 1.0) * u_pad;
    float r2 = dot(p, p);

    // (white grain, a fresh one every frame - the lattice noise read as a checkerboard)
    vec2 dpx = (u_cells > 0.5) ? floor(q * u_cells) : floor(gl_FragCoord.xy);
    float dfr = floor(u_time * 60.0);
    dpx += vec2(dfr * 13.0, dfr * 7.0);
    float dn = (hash12(dpx) - 0.5) * u_dither;
    float dsp = hash12(dpx + vec2(31.0, 71.0));   // the sea's sparkle

    float rl = 0.0;
    if (r2 > 0.0001) {
        vec2 np = p / sqrt(r2);
        rl = clamp(dot(vec3(np, 0.0), u_light) * 0.5 + 0.5, 0.0, 1.0);
    }
    vec3 atmo = mix(u_atmo * 0.22 + vec3(0.01, 0.01, 0.04), u_atmo, rl);

    // ---- cloud shells ----
    float cab = 0.0; float clib = 1.0;
    if (r2 <= CB * CB) {
        vec3 nb = vec3(p.x, p.y, sqrt(CB * CB - r2)) / CB;
        cab  = cloud_at(nb, u_tsize);
        clib = lightband(dot(nb, u_light));
    }
    float cat = 0.0; float clit = 1.0; float emb = 1.0;
    if (r2 <= CR * CR) {
        vec3 nt = vec3(p.x, p.y, sqrt(CR * CR - r2)) / CR;
        cat  = cloud_at(nt, u_tsize);
        clit = lightband(dot(nt, u_light));
        if (cat > 0.0 && cloud_at(normalize(nt + u_light * 0.07), u_tsize) < 0.5) emb = 1.14;
    }
    vec3 cbcol = vec3(0.60, 0.64, 0.76) * clib;
    if (clib < 0.9) cbcol = mix(cbcol, vec3(0.04, 0.05, 0.10), 0.55 * (1.0 - clib));
    vec3 ctcol = vec3(0.97, 0.98, 1.0) * clit * emb;
    if (clit < 0.9) ctcol = mix(ctcol, vec3(0.05, 0.06, 0.13), 0.55 * (1.0 - clit));
    float duskc = smoothstep(0.25, 0.55, clit) * (1.0 - smoothstep(0.55, 0.95, clit));
    ctcol += mix(vec3(0.80, 0.30, 0.55), u_atmo, 0.22) * (duskc * 0.24);

    // ---- ring ----
    float ringA = 0.0;
    vec3  ringC = vec3(0.0);
    float ringZ = -1000.0;
    if (u_ring > 0.01) {
        vec3 ro = vec3(0.0, 0.0, 6.0);
        vec3 rd = vec3(p.x, p.y, -6.0);
        float dnm = dot(rd, u_raxis);
        if (abs(dnm) > 0.001) {
            float tt = -dot(ro, u_raxis) / dnm;
            if (tt > 0.0) {
                vec3 rp = ro + rd * tt;
                float rr = length(rp);
                if (rr > 1.55 && rr < 2.25) {
                    float bf = (rr - 1.55) / 0.7;
                    float tone = 0.55;
                    if (bf > 0.22) tone = 0.95;
                    if (bf > 0.48 && bf < 0.58) tone = 0.0;
                    if (bf > 0.58) tone = 0.75;
                    if (bf > 0.85) tone = 0.4;
                    if (tone > 0.01) {
                        ringC = u_ringcol * tone;
                        float pl = dot(rp, u_light);
                        if (pl < 0.0 && length(rp - u_light * pl) < 1.0) ringC *= 0.15;
                        ringA = u_ring;
                        ringZ = rp.z;
                    }
                }
            }
        }
    }
    float czf = (r2 <= CR * CR) ? sqrt(CR * CR - r2) : -1000.0;

    // ---- THE MOUNTAINS: march the ray from the outer shell down to
    // the surface 1 + relief x h. Inside the unit disc the base sphere
    // always catches it; on the limb (1 < r < 1 + relief) only a peak
    // does, which is the silhouette bump ----
    float RO = 1.0 + u_relief;
    bool  hit = false;
    vec3  n = vec3(0.0);   // the hit's direction (unit)
    float z = 0.0;         // the hit's depth
    if (r2 <= RO * RO) {
        if (u_relief < 0.0005) {
            if (r2 <= 1.0) { z = sqrt(1.0 - r2); n = vec3(p.x, p.y, z); hit = true; }
        } else {
            float z0 = sqrt(RO * RO - r2);
            float z1 = (r2 <= 1.0) ? sqrt(1.0 - r2) : 0.0;
            float zs = z0;
            float zh = z0;
            bool under = false;
            for (int i = 0; i < 14; i++) {
                float zz = mix(z0, z1, (float(i) + 1.0) / 14.0);
                vec3 pp = vec3(p.x, p.y, zz);
                float rr = length(pp);
                vec3 dir = pp / rr;
                float hs = 1.0 + u_relief * height_at(dir);
                if (rr <= hs) { under = true; zh = zz; break; }
                zs = zz;
            }
            if (under) {
                // refine between the last miss (zs) and the hit (zh)
                for (int j = 0; j < 4; j++) {
                    float zm = (zs + zh) * 0.5;
                    vec3 pp = vec3(p.x, p.y, zm);
                    float rr = length(pp);
                    float hs = 1.0 + u_relief * height_at(pp / rr);
                    if (rr <= hs) zh = zm; else zs = zm;
                }
                z = zh;
                vec3 pp = vec3(p.x, p.y, z);
                n = pp / length(pp);
                hit = true;
            } else if (r2 <= 1.0) {
                z = z1; n = vec3(p.x, p.y, z); hit = true;
            }
        }
    }

    if (hit) {
        // ---- terrain hit ----
        vec3 t = to_tex(n);
        vec4 tex = texture2D(gm_BaseTexture, sphere_uv(t, u_tsize));
        vec3 col = tex.rgb;

        // the slope: the height gradient bends the normal, so ridges
        // catch the sun on one face and shade on the other
        vec3 nn = n;
        if (u_relief > 0.0005) {
            float e = 2.0 / max(u_tsize.x, 8.0);
            vec3 txr = cross(vec3(0.0, 1.0, 0.0), n);
            vec3 tx = (length(txr) < 0.001) ? vec3(1.0, 0.0, 0.0) : normalize(txr);
            vec3 ty = normalize(cross(n, tx));
            float hx = height_at(normalize(n + tx * e)) - height_at(normalize(n - tx * e));
            float hy = height_at(normalize(n + ty * e)) - height_at(normalize(n - ty * e));
            float k = u_relief * 9.0;
            nn = normalize(n - tx * hx * k - ty * hy * k);
        }

        col *= 1.0 - cloud_at(normalize(n - u_light * 0.10), u_tsize) * 0.28;
        float li = lightband(dot(nn, u_light));
        col *= li;
        if (li < 0.9) col = mix(col, vec3(0.03, 0.04, 0.10), 0.5 * (1.0 - li));
        float dusk = smoothstep(0.25, 0.55, li) * (1.0 - smoothstep(0.55, 0.95, li));
        col += mix(vec3(0.72, 0.20, 0.46), u_atmo, 0.22) * (dusk * 0.16);

        // THE SEA'S GLINT (2026-09-15, his ask): water catches the sun - a
        // highlight where the half-vector of the sun and the eye meets the
        // sphere, on the day side only, with a little shimmer on it (the
        // frame's dither). The height texture's green marks water
        float wat = texture2D(u_height, sphere_uv(t, u_tsize)).g;
        if (wat > 0.5) {
            vec3 hv = normalize(u_light + vec3(0.0, 0.0, 1.0));
            float sp = pow(max(dot(n, hv), 0.0), 36.0);
            float day = smoothstep(-0.05, 0.30, dot(n, u_light));
            col += vec3(1.0, 0.96, 0.86) * sp * 0.85 * day * (0.8 + 0.4 * dsp);
        }

        float em = 1.0 - tex.a;
        if (em > 0.001) col = mix(col, tex.rgb * (1.0 + 0.3 * (1.0 - li)), em);

        for (int ci = 0; ci < 6; ci++) {
            if (float(ci) >= u_cityn) break;
            float cd = distance(t, u_city[ci].xyz);
            float cr = u_city[ci].w;
            if (cd < cr) {
                float fall = 1.0 - cd / cr;
                float spk = cw_h(floor(t * 42.0) + float(ci) * 3.7);
                float lit = smoothstep(0.60, 0.85, spk) * fall * fall;
                col += vec3(1.0, 0.72, 0.42) * lit * (1.0 - li) * 1.5;
            }
        }

        if (u_ring > 0.01) {
            float sdn = dot(u_light, u_raxis);
            if (abs(sdn) > 0.02) {
                float st = -dot(n, u_raxis) / sdn;
                if (st > 0.0) {
                    float sr = length(n + u_light * st);
                    float rsh = smoothstep(1.48, 1.62, sr) * (1.0 - smoothstep(2.16, 2.30, sr));
                    col *= 1.0 - rsh * 0.13 * u_ring;
                }
            }
        }
        if (ringA > 0.0 && ringZ > z && ringZ <= czf) col = mix(col, ringC, ringA);
        col = mix(col, cbcol, cab * 0.80);
        col = mix(col, ctcol, cat * 0.95);
        if (ringA > 0.0 && ringZ > czf) col = mix(col, ringC, ringA);

        float fr = pow(1.0 - clamp(z, 0.0, 1.0), 2.6);
        col += atmo * fr * (0.12 + 0.88 * rl);
        col += dn * (min(dot(col, vec3(0.299, 0.587, 0.114)) * 255.0 * 0.5, 2.0) / 255.0);
        gl_FragColor = vec4(col, 1.0);
    } else {
        float t2 = clamp((sqrt(r2) - 1.0) / 0.22, 0.0, 1.0);
        float g = pow(1.0 - t2, 2.2) * (0.025 + 0.62 * rl);
        g += dn * (min(g * 255.0 * 0.5, 1.4) / 255.0);
        vec3 col = atmo;
        float a = max(g, 0.0);
        if (ringA > 0.0 && ringZ <= czf) { col = ringC; a = max(a, ringA); }
        if (cab > 0.04) { col = cbcol; a = max(a, cab * 0.80); }
        if (cat > 0.04) { col = ctcol; a = max(a, cat * 0.95); }
        if (ringA > 0.0 && ringZ > czf)  { col = ringC; a = max(a, ringA); }
        gl_FragColor = vec4(col, a);
    }
}
