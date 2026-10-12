package("libopusfile")
    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/opusfile.git")

    add_versions("0.12+20260328", "6dfd29e7adb87f2e193575fc3fa88cbf1a0b27df")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::opusfile")
    elseif is_plat("linux") then
        add_extsources("pacman::opusfile", "apt::libopusfile-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::opusfile")
    end

    add_deps("cmake", "libogg", "libopus")

    on_install(function (package)
        io.replace("include/opusfile.h", "# include <opus_multistream.h>", "# include <opus/opus_multistream.h>", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOP_DISABLE_DOCS=ON")
        table.insert(configs, "-DOP_DISABLE_EXAMPLES=ON")
        table.insert(configs, "-DOP_DISABLE_HTTP=ON")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("op_open_file", {includes = "opus/opusfile.h"}))
    end)
