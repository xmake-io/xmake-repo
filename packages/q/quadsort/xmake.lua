package("quadsort")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scandum/quadsort")
    set_description("Quadsort is a branchless stable adaptive mergesort faster than quicksort.")
    set_license("Unlicense")

    add_urls("https://github.com/scandum/quadsort.git", {
        version = function (version) return version:gsub("+", "%.") end
    })

    add_versions("1.2.1+3", "4c357224cd9b53382248affc64e295726697bd35")
    add_versions("1.1.5+4", "7b4e7b1489ab1c80eb97a90ae01deada7c740a46")

    if on_check then
        on_check(function (package)
            if package:version():ge("1.2.1+3") then
                assert(not package:has_tool("cxx", "cl"), "package(quadsort 1.2.1+3) unsupported msvc")
            end
        end)
    end

    on_install(function (package)
        os.cp("src/quadsort.c", package:installdir("include"))
        os.cp("src/quadsort.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("quadsort", {includes = {"string.h", "quadsort.h"}}))
    end)
