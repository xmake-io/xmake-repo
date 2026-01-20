package("cserialport")
    set_homepage("https://github.com/itas109/CSerialPort")
    set_description("CSerialPort is a lightweight cross-platform serial port library based on C++, which can easy to read and write serial port on multiple operating system.")
    set_license("LGPL-3.0")
   
    add_urls("https://github.com/itas109/CSerialPort/archive/refs/tags/$(version).tar.gz",
             "https://github.com/itas109/CSerialPort.git")

    add_versions("v4.3.3", "e500268b720aaa05fbf332bc2eea598c24b8a436dc52b16c008ec46d56ca0458")
    add_versions("v4.3.2", "0d10a0e978ab77b223dca8a37cfeb2b31676f2211d29a486f8e7173bb2e8c27d")
    add_versions("v4.3.1", "376f41866be65ddfed91f3d0fea91aaaf5ca7e645f9b9cfcdaa0a9182a0bb3ac")

    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "IOKit")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            import("core.base.semver")

            if package:is_arch("arm.*") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(cserialport/arm): need vs_toolset >= v143")
            end
        end)
    end

    on_install("!cross and !iphoneos and !android", function (package)
        local configs = {"-DCSERIALPORT_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:config("c_api") then
            io.replace("bindings/c/cserialport.h", "#define C_DLL_EXPORT __declspec(dllexport)", "#define C_DLL_EXPORT", {plain = true})
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                target("cserialport-c")
                    set_kind("static")
                    add_files("bindings/c/cserialport.cpp")
                    add_headerfiles("bindings/c/cserialport.h")
                    add_includedirs("include")
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                itas109::CSerialPort serialPort;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "CSerialPort/SerialPort.h"}))

        if package:config("c_api") then
            assert(package:has_cfuncs("CSerialPortInit", {includes = "cserialport.h"}))
        end
    end)
