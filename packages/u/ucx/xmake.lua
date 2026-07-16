package("ucx")
    set_homepage("https://openucx.org/")
    set_description("Unified Communication X")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/openucx/ucx/releases/download/v$(version)/ucx-$(version).tar.gz",
             "https://github.com/openucx/ucx.git")

    add_versions("1.21.0", "2374d2fcf3186fbfd5e27633ab153aabaeb6b4f503a88563d2aca67cf51ed2c1")
    add_versions("1.18.0", "fa75070f5fa7442731b4ef5fc9549391e147ed3d859afeb1dad2d4513b39dc33")
    add_versions("1.17.0", "34658e282f99f89ce7a991c542e9727552734ac6ad408c52f22b4c2653b04276")
    add_versions("1.16.0", "f73770d3b583c91aba5fb07557e655ead0786e057018bfe42f0ebe8716e9d28c")
    add_versions("1.15.0", "4b202087076bc1c98f9249144f0c277a8ea88ad4ca6f404f94baa9cb3aebda6d")
    add_versions("1.11.0", "b7189b69fe0e16e3c03784ef674e45687a9c520750bd74a45125c460ede37647")

    add_patches("1.21.0", "patches/1.21.0/fix_build.patch", "b32feccefd6f2c546e43c0e6faedb88eb0011f2cbc0f9fad1ce34326ecb7f399")
    add_patches("1.16.0", "patches/1.16.0/unused_variable.patch", "dd40219cf1989cd42ea19f334ea5c3e4e57736bcbad62fa6741f00a1bb89f0fc")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:version():ge("1.21.0") and not package:config("shared") then
            package:add("ldflags", "-Wl,--undefined=ucs_init")
        end
    end)

    on_install("linux", function (package)
        local configs = {"--disable-doxygen-doc", "--without-go", "--without-java", "--without-rte", "--without-fuse3", "--without-gdrcopy", "--without-rdmacm", "--without-knem", "--without-xpmem", "--without-ugni"}
        if package:config("cuda") then
            local cuda = package:dep("cuda"):fetch()
            table.insert(configs, "--with-cuda=" .. path.directory(cuda.sysincludedirs[1]))
        else
            table.insert(configs, "--without-cuda")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ucp_get_version_string", {includes = "ucp/api/ucp.h"}))
    end)
