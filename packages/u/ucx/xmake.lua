package("ucx")

    set_homepage("https://openucx.org/")
    set_description("Unified Communication X")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/openucx/ucx/releases/download/v$(version)/ucx-$(version).tar.gz")
    add_versions("1.16.0", "f73770d3b583c91aba5fb07557e655ead0786e057018bfe42f0ebe8716e9d28c")
    add_versions("1.15.0", "4b202087076bc1c98f9249144f0c277a8ea88ad4ca6f404f94baa9cb3aebda6d")
    add_versions("1.11.0", "b7189b69fe0e16e3c03784ef674e45687a9c520750bd74a45125c460ede37647")

    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    on_load("linux", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
    end)

    on_install("linux", function (package)
        -- Already fixed in the upstream, please remove it in the next release.
        -- https://github.com/openucx/ucx/commit/98496827bef6f4619a4a8058443f61ef78b8ab72
        io.replace("src/ucm/ptmalloc286/malloc.c", "int nfences = 0;", "int __attribute__((unused)) nfences = 0;")
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
