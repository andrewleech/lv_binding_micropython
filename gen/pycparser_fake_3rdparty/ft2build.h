/* Parse-only stub -- see README.md in this directory.
 *
 * Real ft2build.h maps each FT_*_H macro to a header under freetype/config.
 * Everything LVGL's private headers need is declared in one place here, so
 * every macro resolves to the same include-guarded stub.
 */
#ifndef LV_MPY_FAKE_FT2BUILD_H
#define LV_MPY_FAKE_FT2BUILD_H

#define FT_FREETYPE_H          <freetype/freetype.h>
#define FT_GLYPH_H             <freetype/freetype.h>
#define FT_CACHE_H             <freetype/freetype.h>
#define FT_SIZES_H             <freetype/freetype.h>
#define FT_IMAGE_H             <freetype/freetype.h>
#define FT_OUTLINE_H           <freetype/freetype.h>
#define FT_STROKER_H           <freetype/freetype.h>
#define FT_MULTIPLE_MASTERS_H  <freetype/freetype.h>

#endif /* LV_MPY_FAKE_FT2BUILD_H */
