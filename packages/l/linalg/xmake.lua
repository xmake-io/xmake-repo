package("linalg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sgorsten/linalg")
    set_description("linalg.h is a single header, public domain, short vector math library for C++.")
    set_license("Unlicense license")

    add_urls("https://github.com/sgorsten/linalg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sgorsten/linalg.git")

    add_versions("v2.2", "28640228988186edaf7729177bfab4c91170b303ad489407a4228ceb55a73ec2")

    on_install(function (package)
        os.cp("linalg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace linalg::aliases;
            float4 test(float3 a, float3 b, float3 c) {
                float3 n = cross(b-a, c-a);
                return {n, -dot(n,a)};
            }
        ]]}, {configs = {languages = "c++11"}, includes = "linalg.h"}))
    end)
