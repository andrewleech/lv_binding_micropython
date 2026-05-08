
################################################################################
# LVGL unix optional libraries
# Update CFLAGS_USERMOD and LDFLAGS_USERMOD for LVGL extenral library,
# but do that only on the unix port, for unix specific dependencies
ifeq ($(notdir $(CURDIR)),unix)
ifneq ($(UNAME_S),Darwin)
CFLAGS_USERMOD += -DMICROPY_FB=1
endif

SDL_CFLAGS_USERMOD :=  $(shell pkg-config --silence-errors --cflags sdl2)
SDL_LDFLAGS_USERMOD := $(shell pkg-config --silence-errors --libs   sdl2)
ifneq ($(SDL_LDFLAGS_USERMOD),)
CFLAGS_USERMOD += $(SDL_CFLAGS_USERMOD) -DMICROPY_SDL=1
LDFLAGS_USERMOD += $(SDL_LDFLAGS_USERMOD)
endif

# Avoid including unwanted local headers other than sdl2 
ifeq ($(UNAME_S),Darwin)
CFLAGS_USERMOD:=$(filter-out -I/usr/local/include,$(CFLAGS_USERMOD))
endif

RLOTTIE_CFLAGS_USERMOD :=  $(shell pkg-config --silence-errors --cflags rlottie)
RLOTTIE_LDFLAGS_USERMOD := $(shell pkg-config --silence-errors --libs   rlottie)
ifneq ($(RLOTTIE_LDFLAGS_USERMOD),)
CFLAGS_USERMOD += $(RLOTTIE_CFLAGS_USERMOD) -DMICROPY_RLOTTIE=1
LDFLAGS_USERMOD += $(RLOTTIE_LDFLAGS_USERMOD)
endif

FREETYPE_CFLAGS_USERMOD :=  $(shell pkg-config --silence-errors --cflags freetype2)
FREETYPE_LDFLAGS_USERMOD := $(shell pkg-config --silence-errors --libs   freetype2)
ifneq ($(FREETYPE_LDFLAGS_USERMOD),)
CFLAGS_USERMOD += $(FREETYPE_CFLAGS_USERMOD) -DMICROPY_FREETYPE=1
LDFLAGS_USERMOD += $(FREETYPE_LDFLAGS_USERMOD)
endif

# Enable FFMPEG
# FFMPEG_LIBS := libavformat libavcodec libswscale libavutil
# FFMPEG_CFLAGS_USERMOD :=  $(shell pkg-config --silence-errors --cflags $(FFMPEG_LIBS))
# FFMPEG_LDFLAGS_USERMOD := $(shell pkg-config --silence-errors --libs   $(FFMPEG_LIBS))
# ifneq ($(FFMPEG_LDFLAGS_USERMOD),)
# CFLAGS_USERMOD += $(FFMPEG_CFLAGS_USERMOD) -DMICROPY_FFMPEG=1
# LDFLAGS_USERMOD += $(FFMPEG_LDFLAGS_USERMOD)
# endif

endif

################################################################################

# LVGL build rules


LVGL_BINDING_DIR := $(USERMOD_DIR)
ifeq ($(LV_CONF_PATH),)
LV_CONF_PATH = $(LVGL_BINDING_DIR)/lv_conf.h
endif

# LV_CONF_PATH DEBUG
$(info    LV_CONF_PATH is $(LV_CONF_PATH))


LVGL_DIR = $(LVGL_BINDING_DIR)/lvgl
LVGL_GENERIC_DRV_DIR = $(LVGL_BINDING_DIR)/driver/generic
INC += -I$(LVGL_BINDING_DIR)
ALL_LVGL_SRC = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LV_CONF_PATH)
LVGL_PP = $(BUILD)/lvgl/lvgl.pp.c
LVGL_MPY = $(BUILD)/lvgl/lv_mpy.c
LVGL_MPY_METADATA = $(BUILD)/lvgl/lv_mpy.json
# gen_json.py treats --output-path as a directory and writes <header_base>.json
# inside it. lvgl.h => lvgl.json. Keep its output in its own subdir.
LVGL_JSON_DIR = $(BUILD)/lvgl/api_json
LVGL_JSON = $(LVGL_JSON_DIR)/lvgl.json
CFLAGS_USERMOD += $(LV_CFLAGS)

# MAKE SURE LV_CONF_PATH is a STRING
CFLAGS_USERMOD += -DLV_CONF_PATH='"$(LV_CONF_PATH)"'
# CFLAGS_USERMOD += -DLV_CONF_PATH=$(LV_CONF_PATH)


# CFLAGS DEBUG
$(info CFLAGS_USERMOD is $(CFLAGS_USERMOD))

# Generate LVGL API JSON for enhanced binding generation.
#
# --no-docstrings is passed because the LVGL-side docstring path imports
# docs/doxygen_xml.py, a 1700-line Sphinx/Breathe helper that was deleted
# from the LVGL repo in 4750fe054 ("docs: modernize to .md/.mdx for new
# Fumadocs-based docs engine") and which also pulls in the doxygen binary
# at runtime. gen_stubs.py walks the C headers itself for documentation,
# so the JSON file only needs structural type info here.
$(LVGL_JSON): $(ALL_LVGL_SRC)
	$(ECHO) "LVGL-JSON $@"
	$(Q)mkdir -p $(LVGL_JSON_DIR)
	$(Q)if [ -f "$(LVGL_DIR)/scripts/gen_json/gen_json.py" ]; then \
		$(PYTHON) $(LVGL_DIR)/scripts/gen_json/gen_json.py \
			--output-path $(LVGL_JSON_DIR) \
			--lvgl-config $(LV_CONF_PATH) \
			--no-docstrings; \
	else \
		echo '{}' > $@; \
		echo "Warning: LVGL JSON generator not found, using empty JSON"; \
	fi

$(LVGL_MPY): $(ALL_LVGL_SRC) $(LVGL_BINDING_DIR)/gen/gen_mpy.py $(LVGL_JSON)
	$(ECHO) "LVGL-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CPP) $(CFLAGS_USERMOD) -DPYCPARSER -x c -I $(LVGL_BINDING_DIR)/pycparser/utils/fake_libc_include $(INC) $(LVGL_DIR)/lvgl.h > $(LVGL_PP)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_mpy.py -M lvgl -MP lv -MD $(LVGL_MPY_METADATA) -J $(LVGL_JSON) -E $(LVGL_PP) $(LVGL_DIR)/lvgl.h > $@

# Python stub file generation. lvgl.pyi lands at the top of the build
# folder where firmware artefacts already sit, so users discover it
# alongside the binary. The stub matches the lv_conf.h this build was
# generated against. Point an IDE's extraPaths at $(BUILD) to pick it up.
LVGL_STUBS_FILE = $(BUILD)/lvgl.pyi

# LVGL_MPY_METADATA (lv_mpy.json) is produced as a side-effect of building
# LVGL_MPY (lv_mpy.c) via gen_mpy.py's -MD flag, not as a make target in its
# own right. Declare the dependency explicitly so make knows which recipe to
# run if the stub file is asked for before the .c is built.
$(LVGL_MPY_METADATA): $(LVGL_MPY)

$(LVGL_STUBS_FILE): $(LVGL_MPY_METADATA) $(LVGL_BINDING_DIR)/gen/gen_stubs.py
	$(ECHO) "LVGL-STUBS $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_stubs.py \
		--metadata $(LVGL_MPY_METADATA) \
		--stubs-dir $(dir $@) \
		--lvgl-dir $(LVGL_DIR) \
		--module-name lvgl \
		--validate

.PHONY: LVGL_MPY LVGL_STUBS
LVGL_MPY: $(LVGL_MPY)

LVGL_STUBS: $(LVGL_STUBS_FILE)
	@echo "Generated LVGL Python stub file: $(LVGL_STUBS_FILE)"

CFLAGS_USERMOD += -Wno-unused-function
CFLAGS_EXTRA += -Wno-unused-function

# LVGL SRC
SRC_USERMOD_LIB_C += $(shell find $(LVGL_DIR)/src -type f -name "*.c")

# LVGL GENERIC DRIVER
SRC_USERMOD_LIB_C += $(shell find $(LVGL_GENERIC_DRV_DIR) -type f -name "*.c")

# LVGL EXAMPLES
ifeq ($(LV_BUILD_EXAMPLES), 1)
SRC_USERMOD_LIB_C += $(shell find $(LVGL_DIR)/examples -type f -name "*.c")
endif

SRC_USERMOD_C += $(LVGL_MPY)
