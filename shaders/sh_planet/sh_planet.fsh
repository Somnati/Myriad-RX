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
uniform vec3  u_crot2[3];  // THE WIND (2026-09-17): the base deck's own frame - it sails at its own pace, so the shells slide
uniform vec2  u_wt;        // THE WEATHER (2026-09-17): the swell's two phases (radians), off the universal clock
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
uniform float u_crelief;  // THE CLOUD RELIEF (2026-09-17): the top deck's thickest puff in radii (0 = flat shells)
uniform sampler2D u_ptex;     // THE ZOOM PATCH (2026-09-17): the window under the view, K times finer - its colours
uniform sampler2D u_pheight;  // ...and its height / water / woods
uniform vec4  u_pwin;         // the window in map uv: x0, y0, x1, y1 (x1 may pass 1 - the seam)
uniform float u_pk;           // the patch's resolution over the map's (0 = no patch)
uniform vec3  u_sea0;     // THE SEA'S DEPTH (2026-09-17): the deep, and the open ocean - the water grades between the shore's own colour and these
uniform vec3  u_sea1;
uniform float u_canopy;   // THE CANOPY (2026-09-17): the woods' deck height over the ground, in radii
uniform vec3  u_grass;    // the world's grass - the floor under the trees, darkened
uniform float u_cvol;     // THE CLOUD VOLUME (2026-09-17): 1 = the decks marched as a volume, 0 = as a surface (settings > visuals)

float cw_h(vec3 p)
{
    p = fract(p * 0.1031);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

const float CB = 1.075;   // the base deck's shell (higher, his ask 2026-09-17: was 1.045)
const float CR = 1.15;    // the top deck's (was 1.09); the relief rides on top of each

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

// THE ZOOM PATCH (2026-09-17, his ask: "increase the LOD of the terrain when i get really close"): the map's reads
// go through here. A map uv inside the patch's window reads the patch (the same terrain, sampled K times finer, at
// its own texel's centre); outside, the map at its texel's centre, as ever. The window may cross the seam (x1 > 1)
vec2 map_uv(vec3 t)
{
    return vec2(atan(t.z, t.x) / 6.2831853 + 0.5, acos(clamp(t.y, -1.0, 1.0)) / 3.14159265);
}
bool in_patch(vec2 uv)
{
    if (u_pk < 0.5) return false;
    float ux = uv.x; if (ux < u_pwin.x) ux += 1.0;
    return ux < u_pwin.z && uv.y >= u_pwin.y && uv.y < u_pwin.w;
}
vec2 patch_st(vec2 uv)
{
    float ux = uv.x; if (ux < u_pwin.x) ux += 1.0;
    vec2 st = vec2((ux - u_pwin.x) / (u_pwin.z - u_pwin.x), (uv.y - u_pwin.y) / (u_pwin.w - u_pwin.y));
    vec2 pts = (u_pwin.zw - u_pwin.xy) * u_tsize * u_pk;
    return (floor(st * pts) + 0.5) / pts;
}
vec4 tex_uv(vec2 uv)
{
    return in_patch(uv) ? texture2D(u_ptex, patch_st(uv)) : texture2D(gm_BaseTexture, (floor(uv * u_tsize) + 0.5) / u_tsize);
}
vec4 hmap_uv(vec2 uv)
{
    return in_patch(uv) ? texture2D(u_pheight, patch_st(uv)) : texture2D(u_height, (floor(uv * u_tsize) + 0.5) / u_tsize);
}
// the grid a map uv lives on: the patch's inside the window, the map's outside
float grid_k(vec2 uv)
{
    return in_patch(uv) ? u_pk : 1.0;
}

float height_at(vec3 n)
{
    return hmap_uv(map_uv(to_tex(n))).r;
}

// the height at a map coordinate, the texel's own (wrapping in u, clamped at the poles)
float h_uv(vec2 uv)
{
    uv.x = fract(uv.x);
    uv.y = clamp(uv.y, 0.0, 1.0);
    return hmap_uv(uv).r;
}

// the decks' frames (2026-09-17): the top deck's (u_crot) and the base deck's (u_crot2) - view space to the map's, and back
vec3 to_cloud(vec3 n, bool base)
{
    return base ? vec3(dot(u_crot2[0], n), dot(u_crot2[1], n), dot(u_crot2[2], n)) : vec3(dot(u_crot[0], n), dot(u_crot[1], n), dot(u_crot[2], n));
}
vec3 from_cloud(vec3 t, bool base)
{
    return base ? (u_crot2[0] * t.x + u_crot2[1] * t.y + u_crot2[2] * t.z) : (u_crot[0] * t.x + u_crot[1] * t.y + u_crot[2] * t.z);
}
float cloud_atb(vec3 n, bool base)
{
    return texture2D(u_cloud, sphere_uv(to_cloud(n, base), u_tsize)).a * u_cfade;
}
float cloud_at(vec3 n, vec2 ts)
{
    return cloud_atb(n, false);
}
// THE WEATHER (2026-09-17, with the wind): a slow swell riding the deck's own frame - two waves crossing, their
// phases off the clock - that thickens the puffs where it crests and thins them in its troughs, so a cloud
// grows and shrinks as it sails, not only slides. 0.7 .. 1.3 on the thickness
float weather(vec3 n, bool base)
{
    vec3 t = to_cloud(n, base);
    return 1.0 + 0.3 * sin(dot(t, vec3(3.7, 2.1, 2.9)) + u_wt.x) * sin(dot(t, vec3(-2.3, 4.1, 1.7)) - u_wt.y);
}
// THE CLOUD RELIEF (2026-09-17, his ask: "a depth pass like how our mountains
// are so clouds don't look flat"): the cover map's RED is a smooth thickness
// (planet_gen_step bakes it), the alpha the hard coverage. A deck is a shell
// displaced by it - marched like the ground, lit by its own normal (the
// mountains' per-texel recipe, in the cloud map's grid), so a puff has a
// lit top, a shaded flank, and bulges over the limb
float thk_uv(vec2 uv)
{
    vec4 c = texture2D(u_cloud, (floor(uv * u_tsize) + 0.5) / u_tsize);
    return (c.a > 0.02) ? c.r * u_cfade : 0.0;
}
float thick_atb(vec3 n, bool base)
{
    return thk_uv(sphere_uv(to_cloud(n, base), u_tsize));
}
float thick_at(vec3 n)
{
    return thick_atb(n, false);
}
// THE LIMB'S HEIGHT (his screenshots, 2026-09-17: a cloud band past the limb went to a sliver - under this projection
// a puff past the tangent shows only its vertical extent, and at H = .05 that is five pixels): a puff stands taller
// the nearer the limb it is (x2.5 at the tangent, x1 facing the viewer), so the wrap reads as a band, not a hairline
float deck_h(float H, vec3 d)
{
    return H * (1.0 + 1.5 * (1.0 - d.z * d.z));
}
float cloudband(float d);   // (defined below the marches - a prototype, so the volume may light by it)
// THE VOLUME (2026-09-17, his call: "do the volume pass"): the deck as a SLAB of density from its shell up to its
// height, marched through in even steps. Every step adds its lit colour by its density and thins what is behind
// it (the transmittance); when the ray leaves the slab the pixel is what it gathered. A ray grazing the limb
// travels a long way inside the slab, so a cloud past the tangent still has weight there - the wrap for free,
// and the bright hazy limb real worlds have. The light: the deck's terminator by position, the crown brighter
// than the base, and the puff sunward of the sample shading it (the cheap stand-in for a march to the sun)
float dens_at(vec3 d, float rr, float R, float H, float w)
{
    float th = thick_at(d);
    if (th <= 0.0) return 0.0;
    th = min(1.0, th * w);   // (the weather's swell)
    float h = (rr - R) / H;                         // 0 at the shell, 1 at the deck's top
    float inside = 1.0 - smoothstep(th - 0.25, th, h);
    return inside * (0.25 + 0.75 * cloud_at(d, u_tsize));
}
// THE FLANK (2026-09-17, his ask: "just the bottoms" - a height term and a depth term went into the ray's AVERAGE
// and greyed the whole puff, thin ones most): the puff's slope toward the sun, read where the ray first meets
// cloud. Where the puff RISES sunward of that point the point is on the flank the sun does not reach - the
// puff's own shadow side - and it darkens; a plateau, or the sunlit flank, stays full. Two thickness taps
// (~two texels apart), once a pixel, so the rim is a texel-crisp band along the shaded edge, nothing else
float flank_shade(vec3 d, bool base)
{
    float up = thick_atb(normalize(d + u_light * 0.04), base);
    float dn = thick_atb(normalize(d - u_light * 0.04), base);
    return 1.0 - 0.5 * smoothstep(0.03, 0.35, up - dn);
}
// lit = the deck's day / night (the terminator band alone, the ray's average); shd = the SHAPE's shading - the
// shaded flank and the underside dark, everything else full (his ask, 2026-09-17: "make the underside of clouds
// darker ... just the bottoms") - read ONCE where the ray first meets cloud, so it is a rim, not a tint. Kept
// apart, so the night's blue and the dusk's pink read the terminator only, never a shadowed base as a sunset
float deck_volume(float R, float H, vec2 p, float r2, bool ground, out float lit, out float shd)
{
    lit = 1.0; shd = 1.0;
    bool hit = false;
    float RO = R + H;
    if (r2 > RO * RO) return 0.0;
    float z0 = sqrt(RO * RO - r2);
    float z1 = (r2 <= R * R) ? sqrt(R * R - r2) : 0.0;
    float w = weather(normalize(vec3(p, z0)), false);   // (the swell here - once a pixel; it is a slow, wide wave)
    float T = 1.0;
    float lsum = 0.0;
    float wsum = 0.0;
    // the front of the slab: z0 down to the shell (or the mid plane, out past the shell's limb)
    float ds = (z0 - z1) / 10.0;
    for (int i = 0; i < 10; i++) {
        float zz = z0 - ds * (float(i) + 0.5);
        vec3 pp = vec3(p, zz);
        float rr = length(pp);
        vec3 d = pp / rr;
        float dn = dens_at(d, rr, R, H, w);
        if (dn <= 0.0) continue;
        if (!hit) { hit = true; shd = flank_shade(d, false); }   // (the visible face: its flank's shade)
        float a = clamp(dn * 42.0 * ds, 0.0, 1.0);
        float l = cloudband(dot(d, u_light));
        lsum += l * a * T;
        wsum += a * T;
        T *= 1.0 - a;
        if (T < 0.03) break;
    }
    // ...and the back of it, when the world does not block the ray: the shell's back point down to the far bound
    if (!ground && T > 0.03) {
        float zb = (r2 <= R * R) ? -z1 : 0.0;
        float ds2 = (zb + z0) / 10.0;
        for (int i = 0; i < 10; i++) {
            float zz = zb - ds2 * (float(i) + 0.5);
            vec3 pp = vec3(p, zz);
            float rr = length(pp);
            vec3 d = pp / rr;
            float dn = dens_at(d, rr, R, H, w);
            if (dn <= 0.0) continue;
            if (!hit) { hit = true; shd = 0.5; }   // (THE UNDERSIDE, seen past the limb: half-lit)
            float a = clamp(dn * 42.0 * ds2, 0.0, 1.0);
            float l = cloudband(dot(d, u_light));
            lsum += l * a * T;
            wsum += a * T;
            T *= 1.0 - a;
            if (T < 0.03) break;
        }
    }
    if (wsum > 0.0) lit = lsum / wsum;
    return 1.0 - T;
}
// a deck's march: R the shell, H its relief. Returns the hit's z (-1 = none); the hit's direction, its normal (view space) and its coverage through the outs
float deck_march(float R, float H, vec2 p, float r2, bool base, out vec3 dirn, out vec3 nrm, out float cov, out float back)
{
    dirn = vec3(0.0, 0.0, 1.0); nrm = vec3(0.0, 0.0, 1.0); cov = 0.0; back = 0.0;
    float RO = R + H * 2.5;
    if (r2 > RO * RO) return -1.0;
    float z0 = sqrt(RO * RO - r2);
    float z1 = (r2 <= R * R) ? sqrt(R * R - r2) : 0.0;
    float w = weather(normalize(vec3(p, z0)), base);   // (the swell, on the puff's height)
    float zs = z0;
    float zh = z0;
    bool under = false;
    for (int i = 0; i < 8; i++) {
        float zz = mix(z0, z1, (float(i) + 1.0) / 8.0);
        vec3 pp = vec3(p, zz);
        float rr = length(pp);
        vec3 d = pp / rr;
        float th = thick_atb(d, base) * w;
        if (th > 0.0 && rr <= R + deck_h(H, d) * th) { under = true; zh = zz; break; }
        zs = zz;
    }
    if (under) {
        for (int j = 0; j < 3; j++) {
            float zm = (zs + zh) * 0.5;
            vec3 pp = vec3(p, zm);
            float rr = length(pp);
            vec3 d = pp / rr;
            float th = thick_atb(d, base) * w;
            if (th > 0.0 && rr <= R + deck_h(H, d) * th) zh = zm; else zs = zm;
        }
    } else if (r2 > 1.0) {
        // THE BACK OF THE DECK (his report, 2026-09-17: "they disappear as they wrap around ... the underside not
        // rendering"): past the ground's limb the ray misses the world, passes through the deck and out its far
        // side - a puff that has gone round the horizon shows its UNDERSIDE there, and one just past it its top.
        // From the shell's back (or the mid plane, in the relief band) outward: the first point inside a puff
        float zb0 = (r2 <= R * R) ? -z1 : 0.0;
        for (int i = 0; i < 8; i++) {
            float zz = mix(zb0, -z0, float(i) / 7.0);   // (from the shell's own back point - a thin texel there counts too)
            vec3 pp = vec3(p, zz);
            float rr = length(pp);
            vec3 d = pp / rr;
            float th = thick_atb(d, base) * w;
            if (th > 0.0 && rr <= R + deck_h(H, d) * th) { under = true; zh = zz; back = 1.0; break; }
        }
        if (!under) return -1.0;
    } else return -1.0;
    vec3 ph = vec3(p, zh);
    dirn = ph / length(ph);
    cov = cloud_atb(dirn, base);
    // the normal in the map's own grid: one texel each way (the mountains' recipe)
    vec3 t0 = to_cloud(dirn, base);
    vec2 uv0 = vec2(atan(t0.z, t0.x) / 6.2831853 + 0.5, acos(clamp(t0.y, -1.0, 1.0)) / 3.14159265);
    vec2 uvc = (floor(uv0 * u_tsize) + 0.5) / u_tsize;
    vec2 du = vec2(1.0 / u_tsize.x, 0.0);
    vec2 dv = vec2(0.0, 1.0 / u_tsize.y);
    float hx = thk_uv(uvc + du) - thk_uv(uvc - du);
    float hy = thk_uv(uvc + dv) - thk_uv(uvc - dv);
    vec3 tur = vec3(-t0.z, 0.0, t0.x);
    vec3 tu = (length(tur) < 0.001) ? vec3(0.0, 0.0, 1.0) : normalize(tur);
    vec3 tv = normalize(cross(t0, tu));
    float k = max(H, 0.01) * 9.0;
    vec3 nt = normalize(t0 - tu * hx * k - tv * hy * k);
    nrm = normalize(from_cloud(nt, base));
    return zh;
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
    return mix(0.13, 1.0, smoothstep(-0.22, 0.30, d));   // (the night floor: .10 -> .13, the land reads - his ask 2026-09-17)
}
// THE DECKS' LIGHT (2026-09-17, his report: the clouds fade long before the limb): the ground's band starts
// dimming 72 degrees from the sun - with the sun behind the camera that is two fifths of the way out, and a white
// deck shows it where the land does not. The deck's own band holds bright until near the terminator, then drops;
// a puff's slopes (the relief's normal) shade only mildly - a cloud is a scatterer, its flanks are never black
float cloudband(float d)
{
    return mix(0.12, 1.0, smoothstep(-0.18, 0.12, d));
}
float flankband(float d)
{
    return mix(0.55, 1.0, smoothstep(-0.30, 0.30, d));
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

    // ---- cloud decks: the VOLUME (u_cvol - settings > visuals) or the SURFACE march (the cloud relief, 2026-09-17); the base deck .6 of the top's height ----
    float cab = 0.0; float clib = 1.0; float cshb = 1.0;   // (each deck: its coverage, its day / night, its shape's shading)
    float cat = 0.0; float clit = 1.0; float cshd = 1.0; float emb = 1.0;
    float czt = -1.0;
    if (u_cvol > 0.5) {
        bool grd = (r2 <= 1.0);
        float lt = 1.0;
        float sd = 1.0;
        float hv = u_crelief * 1.6;   // (a slab wants more height than a surface's bump: the volume's deck stands taller)
        // ONE DECK in the volume (his call, 2026-09-17: the base deck was half the cost and most of the darkening; the
        // slab has its own depth) - the surface path below keeps both, for its two-shell drift
        cat = deck_volume(CR, hv, p, r2, grd, lt, sd);
        // the gathered alpha in steps: the chunky read, not a smooth fog
        cat = floor(cat * 6.0 + 0.5) / 6.0;
        clit = lt; cshd = sd;
    } else {
        vec3 nbd; vec3 nbn;
        float bkb = 0.0;
        float czb = deck_march(CB, u_crelief * 0.6, p, r2, true, nbd, nbn, cab, bkb);   // (the base deck, on its own frame - the wind, 2026-09-17)
        if (czb < 0.0) cab = 0.0;
        else { clib = cloudband(dot(nbd, u_light)); cshb = flankband(dot(nbn, u_light)) * (1.0 - 0.5 * bkb); }   // (the deck's terminator; its slopes, and an underside half-lit - apart, 2026-09-17)
        vec3 ntd; vec3 ntn;
        float bkt = 0.0;
        czt = deck_march(CR, u_crelief, p, r2, false, ntd, ntn, cat, bkt);
        if (czt < 0.0) cat = 0.0;
        else {
            clit = cloudband(dot(ntd, u_light)); cshd = flankband(dot(ntn, u_light)) * (1.0 - 0.5 * bkt);
            if (cat > 0.0 && cloud_at(normalize(ntd + u_light * 0.07), u_tsize) < 0.5) emb = 1.14;
        }
    }
    vec3 cbcol = vec3(0.60, 0.64, 0.76) * clib;
    if (clib < 0.9) cbcol = mix(cbcol, vec3(0.04, 0.05, 0.10), 0.55 * (1.0 - clib));
    float duskb = smoothstep(0.25, 0.55, clib) * (1.0 - smoothstep(0.55, 0.95, clib));   // the undersides catch the sunset too (2026-09-16)
    cbcol += mix(vec3(0.85, 0.35, 0.45), u_atmo, 0.30) * (duskb * 0.30);
    cbcol *= cshb;   // (the shape's shading last: the underside dark by day and by night alike - 2026-09-17)
    vec3 ctcol = vec3(0.97, 0.98, 1.0) * clit * emb;
    if (clit < 0.9) ctcol = mix(ctcol, vec3(0.05, 0.06, 0.13), 0.55 * (1.0 - clit));
    float duskc = smoothstep(0.25, 0.55, clit) * (1.0 - smoothstep(0.55, 0.95, clit));
    ctcol += mix(vec3(0.80, 0.30, 0.55), u_atmo, 0.22) * (duskc * 0.30);
    ctcol *= cshd;

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
    float czf = (czt >= 0.0) ? czt : ((r2 <= CR * CR) ? sqrt(CR * CR - r2) : -1000.0);   // (the top deck's front: where it was hit, else the shell)

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
        vec2 muv = map_uv(t);
        vec4 tex = tex_uv(muv);
        vec3 col = tex.rgb;
        vec4 hsmp = hmap_uv(muv);   // (red the height, green water, blue the woods)

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
            // PER TEXEL (2026-09-16, his report: "very jittery when panning"):
            // the slope's taps sat a sixth of a texel apart and the shadow's
            // march inside one, so what a pixel read depended on where in its
            // texel the sample fell - and that drifts with every camera move.
            // Now the neighbours are a whole texel away in the map's own grid
            // and the march starts at the texel's centre: a texel's shading is
            // its own and changes only at a texel boundary, as the colour does.
            // It all happens in TEXTURE space (the world's rotation off through
            // to_tex, back on through u_rot's transpose - a rotation's inverse)
            vec3 t0 = to_tex(n);
            vec2 uv0 = map_uv(t0);
            float gk = grid_k(uv0);              // (in the zoom patch the grid is K times finer, and so are the taps)
            vec2 ts = u_tsize * gk;
            vec2 uvc = (floor(uv0 * ts) + 0.5) / ts;
            vec2 du = vec2(1.0 / ts.x, 0.0), dv = vec2(0.0, 1.0 / ts.y);
            h0 = h_uv(uvc);
            float hx = h_uv(uvc + du) - h_uv(uvc - du);
            float hy = h_uv(uvc + dv) - h_uv(uvc - dv);
            // the texel's frame: +u east along the parallel, +v south along the meridian
            vec3 tur = vec3(-t0.z, 0.0, t0.x);
            vec3 tu = (length(tur) < 0.001) ? vec3(0.0, 0.0, 1.0) : normalize(tur);
            vec3 tv = normalize(cross(t0, tu));
            float k = u_relief * 13.0 * u_bump * gk;   // (a finer tap sees a smaller rise: the slope per unit of ground is the same)
            vec3 nt = normalize(t0 - tu * hx * k - tv * hy * k);
            nn = normalize(u_rot[0] * nt.x + u_rot[1] * nt.y + u_rot[2] * nt.z);
            bumpl = dot(nn, u_light) - dot(n, u_light);
            // the self-shadow: from the texel's centre, a texel a step along the
            // sun; the sun's rise per unit of ground, against the ground ahead
            float el = dot(n, u_light);
            if (el > 0.02) {
                float th = uvc.y * 3.14159265, ph = (uvc.x - 0.5) * 6.2831853;
                vec3 tc = vec3(sin(th) * cos(ph), cos(th), sin(th) * sin(ph));
                vec3 lt = to_tex(u_light);
                float cs = sqrt(max(0.0, 1.0 - el * el));
                float rise = el / max(cs, 0.08);
                float tx1 = 6.2831853 / u_tsize.x;
                for (int i = 1; i <= 5; i++) {
                    float sd = tx1 * float(i);
                    vec3 sp = normalize(tc + lt * sd);
                    float hr = h0 + (sd / u_relief) * rise;
                    float ht = hmap_uv(map_uv(sp)).r;
                    shadow = max(shadow, clamp((ht - hr) * 6.0, 0.0, 1.0));
                }
            }
        }

        // THE CANOPY (2026-09-17, his ask: "give forest biomes a grainy texture ... a parallax forest noise above it
        // with a darker shade of grass below it"): the height map's blue marks the woods. The texel's colour is the
        // CANOPY, a deck a hair above the ground (u_canopy radii): the ray meets it a little off where it meets the
        // ground, more toward the limb, so the canopy slides over its floor as the world turns. Per canopy texel a
        // hash says tree or gap - the gap shows the floor, the world's grass darkened - and a grain of brightness on
        // the trees; a slow noise clumps them, thick here and thin there. A swamp's canopy is thinner (its blue lower)
        float fo = (hsmp.g > 0.5) ? 0.0 : hsmp.b;   // (under water the blue is the depth, not the woods)
        if (fo > 0.05) {
            float rc = 1.0 + u_relief * h0 + u_canopy;
            vec3 nc = normalize(vec3(p, sqrt(max(0.0, rc * rc - r2))));
            vec2 cuvm = map_uv(to_tex(nc));
            vec2 cuv = cuvm * u_tsize * grid_k(cuvm);   // (the trees' grain on the grid under it: finer in a zoom tier)
            vec2 ct = floor(cuv);
            float g = hash12(ct + 0.5);
            vec2 cl = cuvm * u_tsize / 4.0;              // (the CLEARINGS on the base map's grid - the same clearings at every tier; his report 2026-09-17)
            vec2 ci = floor(cl); vec2 cf = fract(cl); cf = cf * cf * (3.0 - 2.0 * cf);
            float vn = mix(mix(hash12(ci + 7.1), hash12(ci + vec2(1.0, 0.0) + 7.1), cf.x), mix(hash12(ci + vec2(0.0, 1.0) + 7.1), hash12(ci + vec2(1.0, 1.0) + 7.1), cf.x), cf.y);
            // CLEARINGS, not static (his screenshot, 2026-09-17: the per-texel gaps read as noise): a gap is where the
            // slow clump noise runs low - a blob a few texels wide - with the texel hash only roughening its edge;
            // the trees keep a finer grain of brightness. A swamp's canopy (fo lower) opens wider
            float open = vn + (g - 0.5) * 0.3 + (1.0 - fo) * 0.4;
            vec3 floorc = mix(col * 0.5, u_grass * 0.5, 0.7);
            vec3 canopy = col * (0.90 + 0.20 * hash12(ct + 17.3));
            col = (open > 0.36) ? canopy : floorc;
        }
        // THE SEA'S DEPTH (his ask, 2026-09-17: "smooth blending between its depth layers"): under water the height
        // map's blue is the depth. The texel's own colour at the shore (the shallows where the map put them), the
        // open ocean by a third of the way down, the deep past that - one gradient, no bands
        if (hsmp.g > 0.5) {
            float dp = hsmp.b;
            col = mix(mix(col, u_sea1, smoothstep(0.0, 0.35, dp)), u_sea0, smoothstep(0.3, 1.0, dp));
        }
        col *= 1.0 - cloud_at(normalize(n - u_light * 0.15), u_tsize) * 0.28;   // (the shadow further off its cloud: the deck sits higher - 2026-09-17)
        float li = lightband(dot(nn, u_light));
        col *= li;
        col *= 1.0 + clamp(bumpl * 2.4 * u_bump, -0.55, 0.45);                       // the slope's own light, over the band
        col = mix(col, mix(col, vec3(0.90, 0.92, 0.96), 0.6), smoothstep(0.62, 0.95, h0) * min(1.0, u_bump));   // the snow line
        col *= 1.0 - 0.5 * shadow * min(1.0, u_bump) * li;                            // the peak's shadow (only where there is light to take)
        // THE NIGHT (2026-09-17, his ask: "dark yes but also grey ... the landscape hard to see"): a moonlit
        // blue that MULTIPLIES the land (its contrast survives) with the faintest floor, instead of a flat dark blue mixed over it
        if (li < 0.9) col = mix(col, col * vec3(0.55, 0.66, 1.0) + vec3(0.012, 0.016, 0.045), 0.6 * (1.0 - li));
        float dusk = smoothstep(0.25, 0.55, li) * (1.0 - smoothstep(0.55, 0.95, li));
        col += mix(vec3(0.72, 0.20, 0.46), u_atmo, 0.22) * (dusk * 0.16);

        // THE SEA'S GLINT (2026-09-15, his ask): water catches the sun - a
        // highlight where the half-vector of the sun and the eye meets the
        // sphere, on the day side only, with a little shimmer on it (the
        // frame's dither). The height texture's green marks water
        float wat = hsmp.g;
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
            // (phase-modulated by two slow sines at irrational ratios: the curtain never repeats a beat - "too rhythmic", his report 2026-09-16)
            float wave = 0.5 + 0.5 * sin(lon * 5.0 + u_time * 0.6 + 2.0 * sin(u_time * 0.173 + lon * 2.3)) * sin(lon * 11.0 - u_time * 0.35 + alat * 20.0 + 3.0 * sin(u_time * 0.091 + lon * 0.7));
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
            // each cell keeps its own clock - a slot 0.18..0.68 s long at its own phase - so the flashes never fall on one grid
            // (three a second on the beat read as a metronome - his report 2026-09-16); a flash peaks at its own height and decays sharply
            float per = 0.18 + 0.5 * cw_h(cell * 0.37 + 4.1);
            float tph = per * cw_h(cell * 0.53 + 8.7);
            float slot = floor((u_time + tph) / per);
            float sfrac = fract((u_time + tph) / per);
            float storm = 0.0;
            for (int si = 0; si < 3; si++) {
                if (float(si) >= u_stormn) break;
                storm = max(storm, smoothstep(0.90, 0.985, dot(t, u_storm[si].xyz)) * u_storm[si].w);
            }
            float prone = max(step(0.90, cw_h(cell * 1.7 + 0.31)), storm);
            float roll = cw_h(cell + vec3(slot * 0.173, slot * 0.071, 0.0));
            float thr = 1.0 - 0.04 * (per / 0.33) * (1.0 + 4.0 * storm);   // (the odds scale with the slot so the rate holds)
            if (prone > 0.5 && roll > thr) {
                float peak = 0.5 + 0.5 * cw_h(cell + vec3(slot * 0.091, 0.0, slot * 0.037));
                fl = peak * pow(1.0 - sfrac, 2.2);
                if (cw_h(cell * 2.1 + vec3(slot * 0.05)) > 0.6) fl += peak * 0.6 * smoothstep(0.42, 0.46, sfrac) * pow(max(0.0, 1.0 - (sfrac - 0.46) * 4.0), 2.0);   // (a second stroke, some of them)
            }
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
        // THE RIM goes on the GROUND, under the decks (his report 2026-09-17: added over them it washed the clouds into the halo
        // a way before the limb - they seemed to fade early); the lit side's rim, sharp into the night (rl .5 is the terminator)
        float fr = pow(1.0 - clamp(z, 0.0, 1.0), 2.6);
        col += atmo * fr * (1.15 * smoothstep(0.42, 0.72, rl));
        col = mix(col, cbcol, cab * 0.80);
        col = mix(col, ctcol, cat * 0.95);
        col += vec3(0.92, 0.95, 1.0) * fl * 1.1;   // the cloud itself, lit from within
        if (ringA > 0.0 && ringZ > czf) col = mix(col, ringC, ringA);

        col += dn * (min(dot(col, vec3(0.299, 0.587, 0.114)) * 255.0 * 0.5, 2.0) / 255.0);
        gl_FragColor = vec4(col, 1.0);
    } else {
        // THE HALO (2026-09-17, his ask: "a larger atmospheric glow on the light side ... the night side without the grey"):
        // twice the reach (.42 radii - the quad's pad 1.6 has the room), the lit side bright, the night side nothing
        float t2 = clamp((sqrt(r2) - 1.0) / 0.42, 0.0, 1.0);
        float g = pow(1.0 - t2, 2.4) * 0.85 * smoothstep(0.45, 0.75, rl);   // (sharp into the night: a sliver past the terminator, then nothing)
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
