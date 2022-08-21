package("newtondynamics")
    set_base("newtondynamics3")

    on_load(function (package)
        wprint("newtondynamics package has been renamed to newtondynamics3 due to release of v4, please update your dependency to newtondynamics3 or newtondynamics4")
        package:base():script("load")(package)
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        -- fixes package:scriptdir() from parent
        local base = package:base()
        base:script("load")(base)
    end)
