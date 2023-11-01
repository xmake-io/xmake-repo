package("linmath.h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/datenwolf/linmath.h")
    set_description("a lean linear math library, aimed at graphics programming. Supports vec3, vec4, mat4x4 and quaternions")

    add_urls("https://github.com/datenwolf/linmath.h.git")
    add_versions("2022.06.19", "3eef82841046507e16a0f6194a61cee2eadd34b3")

    on_install(function (package)
        os.cp("linmath.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mat4x4_mul", {includes = "linmath.h"}))
    end)
