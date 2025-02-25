package("google-gn")

    set_kind("binary")
    set_homepage("https://gn.googlesource.com/gn")
    set_description("GN is a meta-build system that generates build files for Ninja.")

    add_urls("https://gn.googlesource.com/gn.git")
    add_versions("2025.02.24", "68b72c326a153f574f289099f77d85a92389d492")

    add_deps("python 3.x", "ninja", {kind = "binary"})

    on_install(function (package)
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrun(python .. " build/gen.py")
        os.vrunv("ninja", {"-C", "out"})
        os.cp("out/gn*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("gn --version")
    end)
