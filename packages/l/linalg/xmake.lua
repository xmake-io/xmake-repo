package("linalg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sgorsten/linalg")
    set_description("linalg.h is a single header, public domain, short vector math library for C++.")
    set_license("Unlicense license")
    add_urls("https://github.com/sgorsten/linalg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sgorsten/linalg.git")

    add_versions("v2.2", "4460f1f5b85ccc81ffcf49aa450d454db58ca90e")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("linalg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        using namespace linalg::aliases;
        // Compute the coefficients of the equation of a plane containing points a, b, and c
        float4 compute_plane(float3 a, float3 b, float3 c)
        {
            float3 n = cross(b-a, c-a);
            return {n, -dot(n,a)};
        }
    ]]}, {configs = {languages = "c++17"}, includes = "linalg.h"}))
    end)
