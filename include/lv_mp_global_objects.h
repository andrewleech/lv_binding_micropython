#ifndef __LV_MP_MEM_CUSTOM_INCLUDE_H
#define __LV_MP_MEM_CUSTOM_INCLUDE_H

#ifdef MICROPY_ENABLE_DYNRUNTIME
#include <py/dynruntime.h>
#else
#include <py/runtime.h>
#endif

#include <lvgl/src/misc/lv_gc.h>


typedef struct _lvgl_global_objects_t {
    mp_obj_base_t base;
    LV_ROOTS
    #if LV_USE_USER_DATA
    void *mp_lv_user_data;
    #endif
} lvgl_global_objects_t;

extern lvgl_global_objects_t *lvgl_global_objects;

#endif //__LV_MP_MEM_CUSTOM_INCLUDE_H
