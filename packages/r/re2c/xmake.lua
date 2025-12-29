package("re2c")
    set_kind("binary")
    set_homepage("https://re2c.org")
    set_description("Lexer generator for C, C++, D, Go, Haskell, Java, JS, OCaml, Python, Rust, Swift, V and Zig.")
    set_license("Public Domain")

    add_urls("https://github.com/skvadrik/re2c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/skvadrik/re2c.git", {submodules = false})

    add_versions("4.4", "490a9f3a733c3b56f52067ceddc9b7a53065a55e3945f6dd1770012d97c25acd")
    add_versions("4.3.1", "6963eabb99eb6ca1dd0ee37a9fa6900778c998f99f46b5ba746076d16d78300f")
    add_versions("4.3", "39cd7048a817cf3d7d0c2e58a52fb3597d6e1bc86b1df32b8a3cd755c458adfd")
    add_versions("4.2", "01b56c67ca2d5054b1aafc41ef5c15c50fbb6a7e760b1b2346e6116ef039525e")

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("mingw", "msys") and package:is_arch("i386") then
            -- src/options/opt.cc.obj alignof(max_align_t) 16, src/main.cc alignof(max_align_t) 8, why?
            io.replace("src/util/allocator.h", "(sizeof(void*) == 4) ? alignof(max_align_t) : sizeof(void*)", "8", {plain = true})
        end

        local configs = {"-DRE2C_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("re2c --version")
        end
    end)
