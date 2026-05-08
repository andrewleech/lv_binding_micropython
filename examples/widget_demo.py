"""LVGL Widget Demo — three-tab tabview showcase.

Demonstrates the common LVGL v9 widgets laid out in a tabview:

- Controls tab: slider, switch, dropdown, checkboxes, button row.
- Keyboard tab: textarea + on-screen keyboard, suitable for touch.
- Visuals tab: bar, arc, spinbox, LEDs.

The widget set is intended as a quick "what does each widget look like
under the current LVGL build" reference — useful when bringing up a new
display panel and wanting visual confirmation that styles, fonts, and
input devices are wired up correctly.

Supported platforms:
- Unix port with SDL (default — opens an SDL2 window)
- ESP32 with ILI9341 display
- STM32 with built-in display
"""

import usys as sys

sys.path.append("")  # See: https://github.com/micropython/micropython/issues/6419

import lvgl as lv
import lv_utils

lv.init()


class driver:
    WIDTH = 800
    HEIGHT = 480

    def init_gui_SDL(self):
        self.event_loop = lv_utils.event_loop()
        self.disp_drv = lv.sdl_window_create(self.WIDTH, self.HEIGHT)
        self.mouse = lv.sdl_mouse_create()
        self.keyboard = lv.sdl_keyboard_create()

    def init_gui_esp32(self):
        from ili9XXX import ili9341

        self.event_loop = lv_utils.event_loop()
        self.disp = ili9341(
            mhz=20, dc=32, cs=33, power=-1, backlight=-1, hybrid=False, factor=8
        )
        self.disp.init()

    def init_gui_stm32(self):
        import lcd160cr

        self.event_loop = lv_utils.event_loop()
        self.lcd = lcd160cr.LCD160CR("X")
        self.lcd.set_orient(lcd160cr.LANDSCAPE)
        self.disp_drv = lv.sdl_window_create(self.lcd.w, self.lcd.h)

    def init_gui(self):
        if sys.platform == "linux" or sys.platform == "darwin":
            self.init_gui_SDL()
        elif sys.platform == "esp32":
            self.init_gui_esp32()
        elif sys.platform == "pyboard":
            self.init_gui_stm32()
        else:
            raise RuntimeError("Unsupported platform: " + sys.platform)


drv = driver()
drv.init_gui()


# --- Build UI ---
disp = lv.display_get_default()
W = disp.get_horizontal_resolution()
H = disp.get_vertical_resolution()

scr = lv.screen_active()
scr.set_style_bg_color(lv.color_hex(0x1A1A2E), 0)

tv = lv.tabview(scr)
tv.set_size(W, H)
tv.set_pos(0, 0)
tv.set_tab_bar_size(50)


# --- Tab 1: Controls ---
tab1 = tv.add_tab("Controls")
tab1.set_flex_flow(lv.FLEX_FLOW.COLUMN)
tab1.set_flex_align(lv.FLEX_ALIGN.START, lv.FLEX_ALIGN.CENTER, lv.FLEX_ALIGN.CENTER)
tab1.set_style_pad_row(15, 0)

lbl = lv.label(tab1)
lbl.set_text("Widgets demo (%dx%d)" % (W, H))
lbl.set_style_text_font(lv.font_montserrat_24, 0)

slider = lv.slider(tab1)
slider.set_size(W - 80, 20)
slider.set_value(70, False)

sw = lv.switch(tab1)
sw.add_state(lv.STATE.CHECKED)

dd = lv.dropdown(tab1)
dd.set_options("Option 1\nOption 2\nOption 3\nOption 4")
dd.set_size(W - 80, 50)

cb1 = lv.checkbox(tab1)
cb1.set_text("Enable feature A")
cb2 = lv.checkbox(tab1)
cb2.set_text("Enable feature B")
cb2.add_state(lv.STATE.CHECKED)

btn_row = lv.obj(tab1)
btn_row.set_size(W - 40, 60)
btn_row.set_style_bg_opa(lv.OPA.TRANSP, 0)
btn_row.set_style_border_width(0, 0)
btn_row.set_style_pad_all(0, 0)
btn_row.set_flex_flow(lv.FLEX_FLOW.ROW)
btn_row.set_flex_align(lv.FLEX_ALIGN.SPACE_EVENLY, lv.FLEX_ALIGN.CENTER, lv.FLEX_ALIGN.CENTER)
for txt in ["OK", "Cancel", "Apply"]:
    btn = lv.button(btn_row)
    btn.set_size(100, 45)
    btn_label = lv.label(btn)
    btn_label.set_text(txt)
    btn_label.center()


# --- Tab 2: Keyboard ---
tab2 = tv.add_tab("Keyboard")
tab2.set_flex_flow(lv.FLEX_FLOW.COLUMN)
tab2.set_style_pad_all(5, 0)
tab2.set_style_pad_row(5, 0)

ta = lv.textarea(tab2)
ta.set_size(lv.pct(100), 0)
ta.set_flex_grow(1)
ta.set_placeholder_text("Type here...")
ta.set_style_text_color(lv.color_hex(0xFFFFFF), 0)
ta.set_style_text_font(lv.font_montserrat_24, 0)
ta.set_style_bg_color(lv.color_hex(0x16213E), 0)

kb = lv.keyboard(tab2)
kb.set_size(lv.pct(100), int(H * 0.35))
kb.set_textarea(ta)


# --- Tab 3: Visuals ---
tab3 = tv.add_tab("Visuals")
tab3.set_flex_flow(lv.FLEX_FLOW.COLUMN)
tab3.set_flex_align(lv.FLEX_ALIGN.START, lv.FLEX_ALIGN.CENTER, lv.FLEX_ALIGN.CENTER)
tab3.set_style_pad_row(15, 0)

lbl_bar = lv.label(tab3)
lbl_bar.set_text("Progress")
bar = lv.bar(tab3)
bar.set_size(W - 80, 25)
bar.set_value(45, False)

arc = lv.arc(tab3)
arc.set_size(150, 150)
arc.set_value(65)

lbl_spin = lv.label(tab3)
lbl_spin.set_text("Spinbox")
spinbox = lv.spinbox(tab3)
spinbox.set_range(0, 1000)
spinbox.set_value(250)
spinbox.set_digit_format(4, 0)

led_row = lv.obj(tab3)
led_row.set_size(W - 40, 60)
led_row.set_style_bg_opa(lv.OPA.TRANSP, 0)
led_row.set_style_border_width(0, 0)
led_row.set_flex_flow(lv.FLEX_FLOW.ROW)
led_row.set_flex_align(lv.FLEX_ALIGN.SPACE_EVENLY, lv.FLEX_ALIGN.CENTER, lv.FLEX_ALIGN.CENTER)
for color, bright in [(0xFF0000, 255), (0x00FF00, 200), (0x0000FF, 150), (0xFFFF00, 100)]:
    led = lv.led(led_row)
    led.set_size(40, 40)
    led.set_color(lv.color_hex(color))
    led.set_brightness(bright)
