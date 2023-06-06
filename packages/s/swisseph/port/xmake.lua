add_rules("mode.debug", "mode.release")

option("vers")
    set_default("")
    set_showmenu(true)
option_end()

if has_config("vers") then
    set_version(get_config("vers"))
end

target("swisseph")
    set_kind("$(kind)")

    add_files(
        "swedate.c",
        "swehouse.c",
        "swejpl.c",
        "swemmoon.c",
        "swemplan.c",
        "sweph.c",
        "swephlib.c",
        "swecl.c",
        "swehel.c"
    )

    add_headerfiles(
        "swemptab.h",
        "swevents.h",
        "swehouse.h",
        "swephexp.h",
        "sweph.h",
        "swedate.h",
        "swewin.h",
        "swewin64.h",
        "swejpl.h",
        "swephlib.h",
        "swedll.h",
        "sweephe4.h",
        "swenut2000a.h",
        "sweodef.h"
    )
target_end()
