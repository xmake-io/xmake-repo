package("tidy-html5")
    set_homepage("http://www.html-tidy.org")
    set_description("The granddaddy of HTML tools, with support for modern standards")

    add_urls("https://github.com/htacg/tidy-html5.git")

    add_versions("5.9.20", "d08ddc2860aa95ba8e301343a30837f157977cba")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::tidy")
    elseif is_plat("linux") then
        add_extsources("pacman::tidy")
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(name tidy-static)",
            "set(name tidy-static)\nif(NOT BUILD_SHARED_LIB)", {plain = true})
        io.replace("CMakeLists.txt", "install( FILES ${HFILES} DESTINATION ${INCLUDE_INSTALL_DIR} )",
            "endif()\ninstall( FILES ${HFILES} DESTINATION ${INCLUDE_INSTALL_DIR} )", {plain = true})

        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "TIDY_STATIC")
        end

        local configs = {
            "-DBUILD_TAB2SPACE=OFF",
            "-DSUPPORT_CONSOLE_APP=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_DEBUG_LOG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_ALLOC_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_MEMORY_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("wasm") then
            opt.cxflags = "-DHAS_FUTIME=0"
            package:add("defines", "HAS_FUTIME=0")
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tidyCreate", {includes = "tidy.h"}))
    end)
