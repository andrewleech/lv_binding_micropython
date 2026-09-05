/* Parse-only stub -- see ../README.md.
 *
 * Only the types LVGL's private headers name in declarations.  Opaque
 * pointers are enough: gen_mpy never generates bindings for freetype's own
 * API, it just has to get past these declarations to reach LVGL's.
 */
#ifndef LV_MPY_FAKE_FREETYPE_H
#define LV_MPY_FAKE_FREETYPE_H

typedef struct FT_LibraryRec_ * FT_Library;
typedef struct FT_FaceRec_ * FT_Face;
typedef struct FT_SizeRec_ * FT_Size;
typedef void * FTC_FaceID;
typedef int FT_Error;

const char * FT_Error_String(FT_Error error_code);

#endif /* LV_MPY_FAKE_FREETYPE_H */
