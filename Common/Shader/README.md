# Polearm Stylization Shaders

Two shaders carry the game's visual identity. Everything else here supports them.

```
Common/Shader/
├── Reference/
│   ├── StylizePost.gdshader   screen-space color/tone stack (canvas_item)
│   └── StylizeToon.gdshader   3D lighting: cel bands, hard shadows, rim, fog (spatial)
├── Textures/                  ramps, palette strips, paper grain
├── Tools/
│   └── ConvertToToonMaterial.gd
└── README.md
```

If you move or rename these files, do it **inside Godot's FileSystem dock** so the
scene references follow along.

---

## 1. Low-res foundation

Do this before touching the shaders — it carries most of the retro feel on its own,
and dithering only reads correctly when computed at the low resolution.

Project Settings (enable Advanced):

| Setting | Value |
|---|---|
| Display > Window > Size > Viewport Width / Height | `640` / `360` |
| Display > Window > Stretch > Mode | `viewport` |
| Display > Window > Stretch > Scale Mode | `integer` |
| Rendering > Textures > Canvas Textures > Default Texture Filter | `Nearest` |
| Rendering > Lights and Shadows > Directional Shadow > Soft Shadow Filter Quality | `Hard` |
| Rendering > Lights and Shadows > Positional Shadow > Soft Shadow Filter Quality | `Hard` |

---

## 2. StylizePost — the post-process

1. In your main scene add a **CanvasLayer**, set `Layer` to `10`.
2. Add a **ColorRect** as its child.
   - Layout > Anchors Preset > **Full Rect**
   - Mouse > Filter > **Ignore**
3. ColorRect > Material > **New ShaderMaterial** > Shader > **Load** →
   `Reference/StylizePost.gdshader`
4. Expand the uniform groups in the inspector and start toggling.

Put your HUD on a CanvasLayer with a *higher* Layer number so the UI stays unstyled.

Uniforms are per-material, so duplicate the ShaderMaterial to keep several presets
side by side and swap between them.

### Pipeline order

Fixed, top to bottom:

```
sample (+chromatic) → Kuwahara → gradient map → palette → quantize (+dither)
→ halftone → cross-hatch → outline → paper grain → vignette
```

Gradient map, palette, halftone and cross-hatch all do the same *job* — they decide
how tone is rendered. Normally you enable one. They are independent so you can stack
them if you want to experiment.

Dither runs **before** palette matching. That is what lets two palette colors blend
into apparent in-between shades, and it is why a 4-color palette can look richer
than it is.

### Modules

| Group | What it does |
|---|---|
| **Sampling** | Chromatic R/B split. Small offsets read as hand-printed misregistration. |
| **Kuwahara** | Painterly brush-blob filter. Radius 2–4; cost grows with radius². |
| **GradientMap** | Luminance → ramp texture. Ink wash, porcelain, duotone. |
| **Palette** | Snaps to the nearest entry of a palette strip. |
| **ColorDepth** | Bit depth + dither. `color_levels = 2^bits per channel`. `dither_type`: 0 off, 1 Bayer, 2 noise. |
| **Halftone** | Print dot screen; dot size follows luminance. |
| **CrossHatch** | Engraving-style ink hatching. |
| **Outline** | Luminance Sobel edges as ink lines. Also catches strong internal texture edges. |
| **Paper** | Multiplies a tiling paper texture over the image. |
| **Vignette** | Darkens the screen edges. |

---

## 3. StylizeToon — the 3D material

A ShaderMaterial *replaces* whatever material a mesh had, which is why objects turn
flat white if you just drop this on as a Material Override. The shader therefore
exposes `albedo_color`, `albedo_tex`, `uv_scale`, `uv_offset` and `use_vertex_color` —
feed your existing color in and the toon shading is computed **on top of** it.

### Automatic conversion (recommended)

`Tools/ConvertToToonMaterial.gd` copies each mesh's existing StandardMaterial3D
into a toon ShaderMaterial for you:

1. Select the meshes — or a parent, it recurses — in the Scene dock.
2. Open `Tools/ConvertToToonMaterial.gd` in the script editor.
3. **File > Run** (`Ctrl+Shift+X` / `Cmd+Shift+X`).

It prints how many surfaces it converted. Set `REVERT = true` at the top and run
again to strip the override materials back off. **Save your scene first** — this is
not undoable with Ctrl+Z.

### Manual

Geometry > **Material Override** > New ShaderMaterial > load
`Reference/StylizeToon.gdshader`, then set `albedo_color` / `albedo_tex` to match
what the mesh had. Turn on `use_vertex_color` for vertex-colored (Trenchbroom) geometry.

Then on your **DirectionalLight3D**: Shadow > Enabled on, Shadow > **Blur = 0**.

### Uniforms

| Group | What it does |
|---|---|
| **Surface** | Your existing albedo color / texture / UV transform, carried through. |
| **ToonLighting** | `light_bands` (1 = lit/unlit), `hard_shadows` snaps the shadow edge, `shadow_threshold`. |
| **RimLight** | Fresnel silhouette glow. Reads like light on jade, lacquer, porcelain. |
| **AtmosphereShanshui** | Distance fade toward a paper/mist color for receding ridgelines. |

---

## 4. Textures

**All texture inputs are read as tone, not color.** Ramps, palettes and the paper
texture are converted to greyscale, so a colorful texture contributes only its
black-and-white values. `texture_color_amount` dials the original color back in —
`0.0` greyscale, `1.0` full color. This does not apply to the toon shader's
`albedo_tex`: that is the object's own color and stays intact.

Import settings matter. Select the texture in the FileSystem dock → **Import** tab:

- **Palette strips** (`palette_*.png`): Filter **off**, Mipmaps **off**, Repeat **off**. Reimport.
- **Ramps** (`ramp_*.png`): Filter **on**, Mipmaps **off**, Repeat **off**.
  Exception: `ramp_toon_warm.png` has hard steps — Filter **off** for that one.
- **Paper** (`paper_rice.png`): Repeat **on**, Filter **on**.

| File | Use |
|---|---|
| `ramp_inkwash.png` | `gradient_ramp` — shuǐmò huà ink → rice paper |
| `ramp_porcelain.png` | `gradient_ramp` — qīnghuā cobalt → porcelain white |
| `ramp_shanshui.png` | `gradient_ramp` — receding landscape mist |
| `ramp_toon_warm.png` | 3 hard steps, warm shadow / cool light |
| `palette_inkwash.png` | `palette_tex` — 5 ink tones |
| `palette_nianhua.png` | `palette_tex` — vermilion, gold, jade, ink, cream |
| `palette_porcelain.png` | `palette_tex` — 5 cobalt blues |
| `palette_gameboy.png` | `palette_tex` — 4-tone DMG green, for calibration |
| `paper_rice.png` | `paper_tex` — tiling fiber texture |

`palette_size` **must match** the pixel width of the strip: inkwash 5, nianhua 5,
porcelain 5, gameboy 4.

---

## 5. Presets

The colored ramps and palettes only read as color if you raise
`texture_color_amount` above `0`. At the default they give the same presets in
pure greyscale.

**Ink wash — shuǐmò huà.** `enable_kuwahara` (radius 3), `enable_gradient_map`
(`ramp_inkwash`, mix 1.0), `enable_quantize` (levels 4, Bayer, strength 1.0,
dot size 2), `enable_paper` (`paper_rice`, scale 2, strength 0.5). Everything else
off. Keep lots of bright empty space — the negative space *is* the style.

**Blue-and-white porcelain — qīnghuā.** `enable_gradient_map` (`ramp_porcelain`),
`enable_quantize` (levels 4, dither off), faint `enable_outline` for painted linework.

**Folk woodblock — niánhuà.** `enable_quantize` (levels 6, dither off),
`enable_palette` (`palette_nianhua`, size 5), `enable_outline` (width 1.5,
threshold 0.15), `enable_chromatic` with offset `(1.5, 0.5)`.

**Shānshuǐ landscape.** On the toon shader: `enable_atmosphere`, fog color
`#EFEAD9`, start 10, end 80. Layer several ridgelines at different depths.
Pair with `enable_rim` in imperial gold `#E6B422`.

---

## 6. Gotchas

- **ColorRect stays white / no uniforms in the inspector.** The shader failed to
  compile. Godot only exposes uniforms after a successful compile. Double-click the
  `.gdshader` — the error and line number print at the bottom of the shader editor.
- **Fragment built-ins are not visible inside custom functions.** `FRAGCOORD`,
  `SCREEN_UV` and friends only exist inside `fragment()` itself; a helper function
  must take them as parameters. Uniforms and `textureSize()` work everywhere.
- **`SCREEN_PIXEL_SIZE` is unavailable** to helper functions here — use
  `screen_px()`, which returns `1.0 / vec2(textureSize(screen_texture, 0))`.
- **Two texture hints from the same category on one sampler** (e.g.
  `source_color, hint_default_white`) is a compile error.
- **Array declarations** were removed on purpose; the Bayer matrix and the Kuwahara
  quadrant signs are computed arithmetically instead.
- **3D objects render flat white.** The Material Override replaced their material —
  run `Tools/ConvertToToonMaterial.gd`.
- **Performance.** Kuwahara at radius 6 samples 196 texels per pixel. Fine at
  640×360; do not raise the internal resolution and the radius together.
- **Dither crawls when the camera moves.** Expected — the pattern is screen-space.
  Raise `dither_pixel_size` or accept it as part of the look.
