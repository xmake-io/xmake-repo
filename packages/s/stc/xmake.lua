package("stc")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stclib/STC")
    set_description("A modern, user friendly, generic, type-safe and fast C99 container library: String, Vector, Sorted and Unordered Map and Set, Deque, Forward List, Smart Pointers, Bitset and Random numbers.")
    set_license("MIT")

    add_urls("https://github.com/stclib/STC/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stclib/STC.git")

    add_versions("v4.2", "f16c3185ba5693f0257e5b521f0b6b3c11041433a4abbbbc531370364eb75d0c")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        local defines = {"i_type=Floats", "i_val=float"}
        assert(package:has_cfuncs("Floats_push", {includes = "stc/cvec.h", configs = {defines = defines}}))
    end)
