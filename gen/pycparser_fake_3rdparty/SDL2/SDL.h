/* Parse-only stub -- see ../README.md.
 *
 * Only the types LVGL's SDL driver and OSAL headers name in declarations.
 * SDL_Event is a union in the real header; LVGL only ever holds one by
 * value or pointer, so an opaque struct parses identically here.
 */
#ifndef LV_MPY_FAKE_SDL_H
#define LV_MPY_FAKE_SDL_H

typedef struct SDL_Window SDL_Window;
typedef struct SDL_Renderer SDL_Renderer;
typedef struct SDL_Texture SDL_Texture;
typedef struct SDL_Thread SDL_Thread;
typedef struct SDL_mutex SDL_mutex;
typedef struct SDL_cond SDL_cond;
typedef struct SDL_Event SDL_Event;

#endif /* LV_MPY_FAKE_SDL_H */
