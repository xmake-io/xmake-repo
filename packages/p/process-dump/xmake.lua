package("process-dump")
    set_kind("binary")
    set_homepage("http://split-code.com/processdump.html")
    set_description("Windows tool for dumping malware PE files from memory back to disk for analysis.")
    set_license("MIT")

    add_urls("https://github.com/glmcdona/Process-Dump/archive/refs/tags/$(version).tar.gz",
             "https://github.com/glmcdona/Process-Dump.git")

    add_versions("v2.1.1", "cd4e2327ce8fae5228d4790c73e4f3add9bff86e8f27ac9bcfc18f3373f61461")

    on_install("@windows", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++11")
            target("pd")
                set_kind("binary")
                add_files("pd/*.cpp", "pd/*.rc")
                add_headerfiles("pd/*.h")
                add_defines("UNICODE", "_UNICODE")
                add_syslinks("shlwapi", "psapi", "advapi32")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("pd")
    end)
