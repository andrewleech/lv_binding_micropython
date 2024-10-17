freeze("lib", ("fs_driver", "lv_colors", "lv_utils", "tpcal", "utils"), opt=0)

if not options.platform_baremetal:
    freeze("lib", ("display_driver", "display_driver_utils"), opt=0)
