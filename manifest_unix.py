include("manifest.py")

freeze("driver/linux", (
    "evdev.py",
    "lv_timer.py",
), opt=1)

