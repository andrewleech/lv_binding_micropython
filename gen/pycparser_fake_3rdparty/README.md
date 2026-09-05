# Parse-only stubs for third-party headers

`gen_mpy.py` reads LVGL through pycparser, which understands C declarations
but not the preprocessor gymnastics real vendor headers use. LVGL's
`lvgl_private.h` tree — which gen_mpy needs, because struct definitions such
as `lv_event_t` live there and callback wrappers cannot be generated from an
opaque type — reaches two of those:

- `src/font/freetype/lv_freetype_private.h` includes `<ft2build.h>` and the
  `FT_*_H` indirections. Real freetype computes `FT_SIZEOF_INT` as
  `( 32 / FT_CHAR_BIT )`, and pycparser's `fake_libc_include/limits.h` has no
  `CHAR_BIT`, so the expression divides by zero.
- `src/osal/lv_sdl2.h` and `src/drivers/sdl/lv_sdl_private.h` include
  `<SDL2/SDL.h>`, whose platform-detection block pycparser cannot parse at
  all.

These stubs shadow both. The build puts this directory ahead of the real
`-I/usr/include/freetype2` and `-I/usr/include/SDL2` on the preprocessing
pass **only** — the compiled binding still sees the genuine headers, so the
stubs never affect generated code, only what gen_mpy is able to read.

Scope is deliberately minimal: the types LVGL's private headers name in
declarations, nothing more. `grep -oE '\bFTC?_[A-Za-z_]+'` over
`lv_freetype_private.h` and the equivalent for `SDL_` over the SDL headers
lists what has to be here. If LVGL starts naming another vendor type in a
private header, the parse pass fails loudly with a pycparser error naming it,
and it gets added here.
