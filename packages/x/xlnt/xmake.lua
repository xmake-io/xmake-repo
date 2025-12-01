package("xlnt")
    set_homepage("https://github.com/tfussell/xlnt")
    set_description("Cross-platform user-friendly xlsx library for C++11+")
    set_license("MIT")

    add_urls("https://github.com/tfussell/xlnt.git")

    add_versions("2022.12.04", "297b331435d6dee09bf89c8a5ad974b01f18039b")

    add_deps("cmake")
    add_deps("utfcpp", "miniz")
    -- TODO: unbundle libstudxml?

    on_load(function (package)
        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "XLNT_STATIC")
        end
    end)

    on_install(function (package)
        -- fix gcc15
        io.replace("include/xlnt/utils/time.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("include/xlnt/utils/timedelta.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("include/xlnt/utils/variant.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})
        io.replace("include/xlnt/cell/phonetic_run.hpp", "#include <string>", "#include <string>\n#include <cstdint>", {plain = true})

        io.replace("source/CMakeLists.txt", "${XLNT_SOURCE_DIR}/../third-party/utfcpp", "", {plain = true})
        io.replace("source/CMakeLists.txt", "${XLNT_SOURCE_DIR}/../third-party/miniz", "", {plain = true})
        io.writefile("third-party/miniz/miniz.c", "")

        local file = io.open("source/CMakeLists.txt", "a")
        if file then
            file:write([[
                find_package(utf8cpp CONFIG REQUIRED)
                find_package(miniz CONFIG REQUIRED)
                target_link_libraries(xlnt PUBLIC utf8cpp::utf8cpp miniz::miniz)
            ]])
            file:close()
        end

        local configs = {"-DCMAKE_DEBUG_POSTFIX=''"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSTATIC=" .. (not package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xlnt/xlnt.hpp>

            void test(){
                xlnt::workbook wb;
                xlnt::worksheet ws = wb.active_sheet();
                ws.cell("A1").value(5);
                wb.save("example.xlsx");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
