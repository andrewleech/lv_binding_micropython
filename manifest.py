include("$(PORT_DIR)/variants/manifest.py")
include("$(MPY_DIR)/extmod/asyncio")

freeze("lib", (
    "display_driver", 
    "display_driver_utils",
    "fs_driver", 
    "lv_colors", 
    "lv_utils", 
    "tpcal", 
    "utils"
), opt=0)

require("aiorepl")
