package("cserialport")
    set_homepage("https://github.com/itas109/CSerialPort")
    set_description("CSerialPort is a lightweight cross-platform serial port library based on C++, which can easy to read and write serial port on multiple operating system. Also support C, C#, Java, Python, Node.js, Electron etc.")
    set_license("GNU Lesser General Public License v3.0")
   
    add_urls("https://github.com/itas109/CSerialPort/archive/refs/tags/$(version).tar.gz")
    -- add_urls("https://codeload.github.com/itas109/CSerialPort/zip/refs/tags/$(version)")
    add_versions("v4.3.1", "376f41866be65ddfed91f3d0fea91aaaf5ca7e645f9b9cfcdaa0a9182a0bb3ac")

    add_deps("cmake")

    on_install("windows", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCSERIALPORT_BUILD_EXAMPLES=" .. "OFF")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        
    end)


    on_test(function (package)
        assert(package:check_cxxsnippets({
            test=[[
                #include "CSerialPort/SerialPort.h"
                int main(int argc, char** argv) {
                    itas109::CSerialPort serialPort;
                    return 0;
                }
            ]]
        }), {configs = {languages = "c++11"}})
    end)

