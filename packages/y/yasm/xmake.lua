package("yasm")
    set_kind("binary")
    set_homepage("https://yasm.tortall.net/")
    set_description("Modular BSD reimplementation of NASM.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/yasm/yasm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yasm/yasm.git")
    add_versions("v1.3.0", "f708be0b7b8c59bc1dbe7134153cd2f31faeebaa8eec48676c10f972a1f13df3")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DYASM_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("yasm --version")
        if package:is_plat("windows") then
            os.vrun("vsyasm --version")
        end
    end)
