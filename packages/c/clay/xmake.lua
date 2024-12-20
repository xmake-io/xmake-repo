package("clay")
    set_kind("library", {headeronly = true})
    set_homepage("https://nicbarker.com/clay")
    set_description("High performance UI layout library in C.")
    set_license("zlib")

    add_urls("https://github.com/nicbarker/clay/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nicbarker/clay.git")

    add_versions("v0.12", "b36f19352635edeb6d770fe77fab267982d9f206beb541849578de9f0aaff825")

    on_install(function (package)
        os.cp("clay.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("clay.h", {configs = {languages = "c++20"}}))
    end)
