package("annoy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/spotify/annoy")
    set_description("Approximate Nearest Neighbors in C++/Python optimized for memory usage and loading/saving to disk")
    set_license("Apache-2.0")

    add_urls("https://github.com/spotify/annoy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/spotify/annoy.git")

    add_versions("v1.17.3", "c121d38cacd98f5103b24ca4e94ca097f18179eed3037e9eb93ad70ec1e6356e")
    add_versions("v1.17.2", "ad3518f36bdd5ea54576dfe1c765c93d5c737342f269aada2cd7ff1bc0d0cd93")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("annoy/annoylib.h", {configs = {languages = "c++11"}}))
    end)
