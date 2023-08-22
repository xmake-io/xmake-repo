package("libgpiod")
    set_homepage("https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/")
    set_description("libgpiod - C library and tools for interacting with the linux GPIO character device (gpiod stands for GPIO device)")
    
    add_urls("https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-$(version).tar.gz",
             "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git")
    add_versions("v2.0.1", "62071ac22872d9b936408e4a067d15edcdd61dce864ace8725eacdaefe23b898")
    add_versions("v2.0", "1e4dbbe8b3f32adf8818f1b0dfd322876aa9477c")
    add_versions("v1.6.4", "9ae6a5ffa77462fee4fc34c24a7c2459a2a5851f")

    add_deps("autoconf", "automake", "libtool","pkg-config")
    add_cxxflags("--std=c++17")

    on_install("macos", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-tools=yes")
        table.insert(configs, "-enable-bindings-cxx")
        table.insert(configs, "--prefix="..package:installdir())
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.runv("gpiodetect")
    end)
