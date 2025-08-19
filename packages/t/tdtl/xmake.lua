package("tdtl")
    set_kind("binary")
    set_description("Toolset for building tdlib.")
    set_license("BSL-1.0")

    add_urls("https://github.com/tdlib/td.git")
    add_versions("1.8.51", "bb474a201baa798784d696d2d9d762a9d2807f96")

    local tools = {
        {
            project = "tl-parser",
            executable = "tl-parser",
            sourcedir = "td/generate/tl-parser/"
        },
        {
            project = "tl_generate_mtproto",
            executable = "generate_mtproto",
            sourcedir = "td/generate/"
        },
        {
            project = "tl_generate_common",
            executable = "generate_common",
            sourcedir = "td/generate/"
        },
        {
            project = "tl_generate_json",
            executable = "generate_json",
            sourcedir = "td/generate/"
        },
        {
            project = "generate_mime_types_gperf",
            executable = "generate_mime_types_gperf",
            sourcedir = "tdutils/generate/"
        }
    }

    add_deps("cmake", "zlib")
    add_deps("gperf")
    on_install(function (package)
        local targets = {}
        for _, tool in ipairs(tools) do
            table.insert(targets, tool.project)
        end
        io.replace("tdutils/CMakeLists.txt", "add_dependencies(tdutils tdmime_auto)", "", {plain = true})
        io.replace("tdutils/CMakeLists.txt", "${TDMIME_AUTO}\n", "", {plain = true})
        io.replace("td/generate/CMakeLists.txt", "${TDMIME_AUTO}\n", "", {plain = true})
        io.replace("td/generate/CMakeLists.txt", "COMMAND", "COMMENT", {plain = true})

        if is_plat("mingw", "msys") then
            io.replace("td/generate/tl-parser/wgetopt.h", "#ifdef __GNU_LIBRARY__", "#if 1", {plain = true})
            io.replace("td/generate/tl-parser/wgetopt.c", "extern char *getenv();", "#include <stdlib.h>", {plain = true})
        end

        import("package.tools.cmake").build(package, {}, {target = targets, builddir = "build"})

        os.cd("build")
        for _, tool in ipairs(tools) do
            local tooldir = tool.sourcedir .. tool.executable
            if is_host("windows") then
                tooldir = tooldir .. ".exe"
            end
            os.cp(tooldir, package:installdir("bin"))
        end
    end)

    on_test(function (package)
        for _, tool in ipairs(tools) do
            local tooldir = package:installdir("bin", tool.executable)
            if is_host("windows") then
                tooldir = tooldir .. ".exe"
            end
            assert(os.isexec(tooldir), tool.executable .. " not found!")
        end
    end)
