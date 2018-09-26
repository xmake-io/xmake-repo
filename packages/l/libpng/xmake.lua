package("libpng")

    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")

    set_urls("https://github.com/glennrp/libpng/archive/$(version).zip",
             "https://github.com/glennrp/libpng.git")
    add_versions("v1.6.35", "3d22d46c566b1761a0e15ea397589b3a5f36ac09b7c785382e6470156c04247f")
    add_versions("v1.6.34", "7ffa5eb8f9f3ed23cf107042e5fec28699718916668bbce48b968600475208d3")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_build("windows", function (package)
        import("package.builder.cmake").build(package)
    end)

    on_install("windows", function (package)
        import("package.builder.cmake").install(package)
    end)

    on_build("macosx", "linux", function (package)
        import("package.builder.autoconf").build(package)
    end)

    on_install("macosx", "linux", function (package)
        import("package.builder.autoconf").install(package)
    end)
