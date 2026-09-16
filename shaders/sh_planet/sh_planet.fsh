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
uniform vec4  u_moonsh[4];   // MOON SHADOWS (2026-09-16): each moon's view-space position (planet radii) and its radius
uniform float u_moonn;
uniform vec4  u_storm[3];    // LIGHTNING: the spots (texture space) of the regions whose weather is a storm, w = on
uniform float u_stormn;
uniform float u_aurora;      // AURORA: 1 on the worlds that have one
uniform float u_relief;
uniform float u_bump;      // the mountains' exaggeration (settings > visuals: 1 = the base look; 0 flattens the shading, not the silhouette)
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
    float duskb = smoothstep(0.25, 0.55, clib) * (1.0 - smoothstep(0.55, 0.95, clib));   // the undersides catch the sunset too (2026-09-16)
    cbcol += mix(vec3(0.85, 0.35, 0.45), u_atmo, 0.30) * (duskb * 0.30);
    vec3 ctcol = vec3(0.97, 0.98, 1.0) * clit * emb;
    if (clit < 0.9) ctcol = mix(ctcol, vec3(0.05, 0.06, 0.13), 0.55 * (1.0 - clit));
    float duskc = smoothstep(0.25, 0.55, clit) * (1.0 - smoothstep(0.55, 0.95, clit));
    ctcol += mix(vec3(0.80, 0.30, 0.55), u_atmo, 0.22) * (duskc * 0.30);

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

        // THE MOUNTAINS' SHADING (2026-09-16, his ask: "more noticeably
        // mountains... exaggerated"): the height gradient bends the normal
        // (a bump map, sharper now: one texel, k = relief x 22); the bump's
        // OWN light delta lifts lit faces and darkens shaded ones over the
        // band, so ridges read on the day side where the band saturates; a
        // snow line lightens the highest ground; and a peak throws a
        // SELF-SHADOW toward the dark side - five steps along the sun over
        // the height field. u_bump scales all of it (settings > visuals)
        vec3 nn = n;
        float h0 = 0.0;
        float bumpl = 0.0;
        float shadow = 0.0;
        if (u_relief > 0.0005 && u_bump > 0.001) {
            h0 = height_at(n);
            float e = 1.0 / max(u_tsize.x, 8.0);
            vec3 txr = cross(vec3(0.0, 1.0, 0.0), n);
            vec3 tx = (length(txr) < 0.001) ? vec3(1.0, 0.0, 0.0) : normalize(txr);
            vec3 ty = normalize(cross(n, tx));
            float hx = height_at(normalize(n + tx * e)) - height_at(normalize(n - tx * e));
            float hy = height_at(normalize(n + ty * e)) - height_at(normalize(n - ty * e));
            float k = u_relief * 22.0 * u_bump;
            nn = normalize(n - tx * hx * k - ty * hy * k);
            bumpl = dot(nn, u_light) - dot(n, u_light);
            // the self-shadow: the sun's rise per unit of ground, against the ground ahead
            float el = dot(n, u_light);
            if (el > 0.02) {
                float cs = sqrt(max(0.0, 1.0 - el * el));
                float rise = el / max(cs, 0.08);
                for (int i = 1; i <= 5; i++) {
                    float sd = e * float(i) * 1.7;
                    vec3 sp = normalize(n + u_light * sd);
                    float hr = h0 + (sd / u_relief) * rise;
                    float ht = height_at(sp);
                    shadow = max(shadow, clamp((ht - hr) * 6.0, 0.0, 1.0));
                }
            }
        }

        col *= 1.0 - cloud_at(normalize(n - u_light * 0.10), u_tsize) * 0.28;
        float li = lightband(dot(nn, u_light));
        col *= li;
        col *= 1.0 + clamp(bumpl * 2.4 * u_bump, -0.55, 0.45);                       // the slope's own light, over the band
        col = mix(col, mix(col, vec3(0.90, 0.92, 0.96), 0.6), smoothstep(0.62, 0.95, h0) * min(1.0, u_bump));   // the snow line
        col *= 1.0 - 0.5 * shadow * min(1.0, u_bump) * li;                            // the peak's shadow (only where there is light to take)
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
            float sp = pow(max(dot(n, hv), 0.0), 26.0);
            float day = smoothstep(-0.05, 0.30, dot(n, u_light));
            col += vec3(1.0, 0.96, 0.86) * sp * 0.6 * day * (0.92 + 0.08 * dsp);   // (the sparkle nearly out - "noisy", his report 2026-09-15)
        }

        float em = 1.0 - tex.a;
        if (em > 0.001) col = mix(col, tex.rgb * (1.0 + 0.3 * (1.0 - li)), em);

        // MOON SHADOWS (2026-09-16, the tech demo's casters): a surface point whose
        // line to the sun passes through a moon is in eclipse - the moon's disc,
        // soft at the edge (the sun has width)
        float ecl = 0.0;
        for (int mi = 0; mi < 4; mi++) {
            if (float(mi) >= u_moonn) break;
            vec3 dm = u_moonsh[mi].xyz - n;
            float along = dot(dm, u_light);
            if (along > 0.0) {
                float dist = length(dm - u_light * along);
                ecl = max(ecl, 1.0 - smoothstep(u_moonsh[mi].w * 0.8, u_moonsh[mi].w * 1.4, dist));
            }
        }
        col *= 1.0 - 0.9 * ecl * li;

        // AURORA (2026-09-16): a shimmering curtain at high latitudes on the
        // night side - green at its foot, violet at its crown, waving slowly
        if (u_aurora > 0.5) {
            float alat = abs(t.y);
            float band = smoothstep(0.78, 0.88, alat) * (1.0 - smoothstep(0.965, 1.0, alat));
            float lon = atan(t.z, t.x);
            float wave = 0.5 + 0.5 * sin(lon * 5.0 + u_time * 0.6) * sin(lon * 11.0 - u_time * 0.35 + alat * 20.0);
            float curtain = smoothstep(0.30, 0.85, wave);
            float night = 1.0 - smoothstep(-0.05, 0.22, dot(n, u_light));
            col += mix(vec3(0.15, 0.95, 0.55), vec3(0.55, 0.30, 0.90), smoothstep(0.86, 0.95, alat)) * band * curtain * night * 0.6;
        }

        // LIGHTNING (2026-09-16): in dense cloud on the night side a cell
        // flashes now and then (a hash per cell per third-of-a-second slot,
        // decaying through the slot); near a region in a STORM every cell is
        // storm-prone and flashes five times as often
        float fl = 0.0;
        if (cat > 0.5 && li < 0.6) {
            vec3 cell = floor(t * 40.0);
            float slot = floor(u_time * 3.0);
            float storm = 0.0;
            for (int si = 0; si < 3; si++) {
                if (float(si) >= u_stormn) break;
                storm = max(storm, smoothstep(0.90, 0.985, dot(t, u_storm[si].xyz)) * u_storm[si].w);
            }
            float prone = max(step(0.90, cw_h(cell * 1.7 + 0.31)), storm);
            float roll = cw_h(cell + vec3(slot * 0.173, slot * 0.071, 0.0));
            float thr = 1.0 - 0.04 * (1.0 + 4.0 * storm);
            if (prone > 0.5 && roll > thr) fl = 1.0 - fract(u_time * 3.0);
            fl *= (1.0 - li) * cat;
        }
        col += vec3(0.80, 0.86, 1.0) * fl * 0.7;   // the ground under the cloud, lit from above

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
        col += vec3(0.92, 0.95, 1.0) * fl * 1.1;   // the cloud itself, lit from within
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
