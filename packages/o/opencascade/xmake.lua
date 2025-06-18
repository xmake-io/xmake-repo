package("opencascade")
    set_homepage("https://dev.opencascade.org/")
    set_description("Open CASCADE Technology (OCCT) is an open-source software development platform for 3D CAD, CAM, CAE.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V$(version).tar.gz",
            {version = function (version) return version:gsub("%.", "_") end})

    add_versions("7.9.1", "de442298cd8860f5580b01007f67f0ecd0b8900cfa4da467fa3c823c2d1a45df")

    add_deps("cmake")

    add_configs("draco",                    {description = "Build with Draco support (v7.6.0+).",             default = true, type = "boolean"})
    add_configs("d3d9",                     {description = "Build with D3D9 support (v7.6.0+).",              default = false, type = "boolean"})
    add_configs("extended_debug_messages",  {description = "Enable extended debug messages in Debug builds.", default = false, type = "boolean"})
    add_configs("ffmpeg",                   {description = "Build with FFMPEG support.",                      default = false, type = "boolean"})
    add_configs("freeimage",                {description = "Build with FreeImage support.",                   default = true, type = "boolean"})
    add_configs("freetype",                 {description = "Build with FreeType support.",                    default = true, type = "boolean"})
    add_configs("gles2",                    {description = "Build with OpenGL ES support (v7.6.0+).",         default = false, type = "boolean"})
    add_configs("opengl",                   {description = "Build with OpenGL support (v7.6.0+).",            default = true, type = "boolean"})    
    add_configs("openvr",                   {description = "Build with OpenVR support (v7.6.0+).",            default = true, type = "boolean"})
    add_configs("rapidjson",                {description = "Build with RapidJSON support.",                   default = true, type = "boolean"})
    add_configs("tbb",                      {description = "Build with TBB support.",                         default = true, type = "boolean"})
    add_configs("tk",                       {description = "Build with TK support for DRAW (v7.6.0+).",       default = false, type = "boolean"})
    add_configs("vtk",                      {description = "Build with VTK support.",                         default = false, type = "boolean"})
    add_configs("cxx_standard",             {description = "Select c++ standard to build.",                   default = "11", type = "string", values = {"11", "14", "17", "20", "23"}})

    -- Core OCCT modules
    add_configs("foundation_classes",     {description = "Build Foundation Classes module.",         default = true,  type = "boolean"})
    add_configs("modeling_data",          {description = "Build Modeling Data module.",              default = true,  type = "boolean"})
    add_configs("modeling_algorithms",    {description = "Build Modeling Algorithms module.",        default = true,  type = "boolean"})
    add_configs("visualization",          {description = "Build Visualization module.",              default = true,  type = "boolean"})
    add_configs("application_framework",  {description = "Build Application Framework module.",      default = true,  type = "boolean"})
    add_configs("data_exchange",          {description = "Build Data Exchange module.",              default = true,  type = "boolean"})
    add_configs("de_tools",               {description = "Build Data Exchange Tools module.",        default = false,  type = "boolean"})

    -- Optional / test-related. currently not supported.
    add_configs("draw",                   {description = "Build DRAW Test Harness and related modules.", default = false, type = "boolean"})
    

    on_load(function (package)

        local function handle_occt_module_config(modules)
            -- enables all previous entries in 'modules' if 'current' is enabled
           for i = #modules, 1, -1 do                   -- from last to first module
                local current = modules[i]
                if package:config(current) then          -- if this module is enabled
                    for j = 1, i - 1 do                   -- ensure all modules before this are enabled
                        local dep = modules[j]
                        if not package:config(dep) then
                            package:config_set(dep, true)
                            cprint("${yellow}warning: '${current}' requires '${dep}'. Auto-enabled '${dep}'.${clear}")
                        end
                    end
                    break   -- stop, because we've enabled all needed dependencies
                end
            end

        end

        package:config_set("foundation_classes", true) -- always built.
        package:config_set("draw", false) -- currently not supported.

        if package:version():lt("7.7.2") or package:version():gt("7.9.1") then
            package:config_set("de_tools", false)
        end

        handle_occt_module_config({
            "foundation_classes",
            "modeling_data",
            "modeling_algorithms",
            "visualization",
            "application_framework",
            "data_exchange",
            "draw"
        })

        -- currently not supported disabling
        package:config_set("gles2", false) -- currently not supported/tested
        package:config_set("d3d9", false) -- currently not supported/tested

        -- version specific disables
        local function config_set_all(configs, value)
            assert(type(configs) == "table", "Expected a table for config keys")

            for _, name in ipairs(configs) do
                package:config_set(name, value)
            end
        end

        if package:version():lt("7.6.0") then
            config_set_all({
                "ffmpeg", 
                "freeimage", 
                "opengl", 
                "openvr", 
                "freetype", 
                "vtk", 
                "gles2", 
                "d3d9" 
            }, false)

            package:config_set("freetype", true) -- freetype only optional from 7.6.0 on (?)
        end

        if not package:config("visualization") then
            config_set_all({
                "ffmpeg",
                "freeimage",
                "opengl",
                "openvr",
                "freetype",
                "vtk",
                "gles2",
                "d3d9"
            }, false)
        end

        if not package:config("data_exchange") then
            config_set_all({
                "draco",
                "rapidjson"
            }, false)     
        end

        if not package:config("draw") then
            config_set_all({
                "tk",
                "tcl"
            }, false)         
        end

        if not package:is_debug() then
            package:config_set("extended_debug_messages", false)
        end


        local occt_cmake_to_xmake_deps = {
        ["CSF_FREETYPE"]      = package:config("freetype")   and { deps = {"freetype"} } or nil,
        ["CSF_TclLibs"]       = package:config("tcl")        and { deps = {"tcl"} } or nil,
        ["CSF_fontconfig"]    = package:is_plat("linux")     and { deps = {"fontconfig"} } or nil,
        ["CSF_XwLibs"]        = package:is_plat("linux")     and { deps = {"libx11"} } or nil, -- ? not sure
        -- optional deps
        ["CSF_OpenGlLibs"]    = package:config("opengl")     and { deps = {"opengl"} } or nil,
        ["CSF_TclTkLibs"]     = package:config("tk")         and { deps = {"tk"} } or nil,
        ["CSF_FFmpeg"]        = package:config("ffmpeg")     and { deps = {"ffmpeg"} } or nil,
        ["CSF_FreeImagePlus"] = package:config("freeimage")  and { deps = {"freeimage"} } or nil,
        ["CSF_OpenVR"]        = package:config("openvr")     and { deps = {"openvr"} } or nil,
        ["CSF_RapidJSON"]     = package:config("rapidjson")  and { deps = {"rapidjson"} } or nil,
        ["CSF_Draco"]         = package:config("draco")      and { deps = {"draco"} } or nil,
        ["CSF_TBB"]           = package:config("tbb")        and { deps = {"tbb"} } or nil,
        ["CSF_VTK"]           = package:config("vtk")        and { deps = {"vtk"} } or nil,
        ["CSF_MMGR"]          = nil, -- no externals

        -- system libs
        ["CSF_androidlog"]    = package:is_plat("android")   and { syslinks = {"log"} } or nil,
        ["CSF_ThreadLibs"]    = package:is_plat("linux")     and { syslinks = {"pthread", "rt"} } or nil,
        ["CSF_dl"]            = package:is_plat("linux")     and { syslinks = {"dl"} } or nil,
        ["CSF_dpsLibs"]       = nil,
        ["CSF_XmuLibs"]       = nil,
        ["CSF_advapi32"]      = package:is_plat("windows")   and { syslinks = {"advapi32"} } or nil,
        ["CSF_gdi32"]         = package:is_plat("windows")   and { syslinks = {"gdi32"} } or nil,
        ["CSF_psapi"]         = package:is_plat("windows")   and { syslinks = {"psapi"} } or nil,
        ["CSF_shell32"]       = package:is_plat("windows")   and { syslinks = {"shell32"} } or nil,
        ["CSF_user32"]        = package:is_plat("windows")   and { syslinks = {"user32"} } or nil,
        ["CSF_winmm"]         = package:is_plat("windows")   and { syslinks = {"winmm"} } or nil,
        ["CSF_wsock32"]       = package:is_plat("windows")   and { syslinks = {"wsock32"} } or nil,
        ["CSF_d3d9"]          = nil,

        -- macOS / iOS frameworks
        ["CSF_Appkit"]        = package:is_plat("iphoneos") and { frameworks = {"UIKit"} }
                            or (package:is_plat("macosx") and { frameworks = {"AppKit"} } or nil),
        ["CSF_IOKit"]         = package:is_plat("macosx")    and { frameworks = {"IOKit"} } or nil,
        ["CSF_objc"]          = package:is_plat("macosx", "iphoneos")   and { syslinks = {"objc"} } or nil,
        }

        for cmake_dep, xmake_dep in pairs(occt_cmake_to_xmake_deps) do
            if xmake_dep then

                if xmake_dep.syslinks then
                    for _, syslib in ipairs(xmake_dep.syslinks) do
                        package:add("syslinks", syslib)
                    end
                end

                if xmake_dep.frameworks then
                    for _, fw in ipairs(xmake_dep.frameworks) do
                        package:add("frameworks", fw)
                    end
                end

                if xmake_dep.deps then
                    for _, dep in ipairs(xmake_dep.deps) do
                        package:add("deps", dep)
                    end
                end

            end
        end

        import("core.base.json")

        local occt_component_map = {}
        local json_file_name = "opencascade.modules.components." .. package:version() .. ".json"
        local json_file_path = path.join(os.scriptdir(), json_file_name)

        if os.isfile(json_file_path) then
            local json_str = io.readfile(json_file_path)
            occt_component_map = json.decode(json_str)
        else
            raise("Missing OpenCascade component map: %s\nEnsure the file exists for version %s.", json_file_name, version)
        end

        -- based on version 7.9.1. if any version adds new module, please add.
        -- do not remove modules even if the version removes one.
        -- DETools module introduced with v7.7 and removed in upcoming v8
        local occt_module_to_component_name = {
            FoundationClasses = "foundation-classes",
            ModelingData = "modeling-data",
            ModelingAlgorithms = "modeling-algorithms",
            Visualization = "visualization",
            ApplicationFramework = "application-framework",
            DataExchange = "data-exchange",
            DETools = "de-tools",
            Draw = "draw"
        }

        local conditional_modules = {
            FoundationClasses = package:config("foundation_classes"),
            ModelingData = package:config("modeling_data"),
            ModelingAlgorithms = package:config("modeling_algorithms"),
            Visualization = package:config("visualization"),
            ApplicationFramework = package:config("application_framework"),
            DataExchange = package:config("data_exchange"),
            DETools = package:config("de_tools"),
            Draw = package:config("draw")
        }

        local conditional_toolkits = { 
            TKD3DHost = package:config("d3d9") and package:config("visualization"),
            TKD3DHostTest = package:config("d3d9") and package:config("draw"),
            TKIVtk = package:config("vtk") and package:config("visualization"),
            TKIVtkDraw = package:config("vtk") and package:config("draw"),
            TKOpenGles = package:config("gles2") and package:config("visualization"),
            TKOpenGlesTest = package:config("gles2") and package:config("draw"),
            TKOpenGl = package:config("opengl") and package:config("visualization"),
            TKOpenGlTest = package:config("opengl") and package:config("draw"),
            -- executables that are excluded from components (is there any way to use them as components properly?)
            ExpToCasExe = false
        }


        -- first, only add components : programmatic add_components
        for occt_module, condition in pairs(conditional_modules) do
            if condition then
                local module_info = occt_component_map[occt_module]
                if module_info then
                    local module_comp_name = occt_module_to_component_name[occt_module]                  
                    package:add("components", module_comp_name)

                    for toolkit, toolkit_info in pairs(module_info) do                                                
                        if conditional_toolkits[toolkit] ~= false then
                            package:add("components", toolkit:lower())
                        end
                    end
                end
            end
        end

        -- second, handle component deps, links.. : programmatic on_component
        for occt_module, condition in pairs(conditional_modules) do
            if condition then
                local module_info = occt_component_map[occt_module]
                if module_info then
                    
                    local module_comp_name = occt_module_to_component_name[occt_module]
                    local module_component = package:component(module_comp_name)

                    for toolkit, toolkit_info in pairs(module_info) do      

                        
                        if conditional_toolkits[toolkit] ~= false then
                            
                            local toolkit_component = package:component(toolkit:lower())
                            
                            -- should we remove this from components?
                            if toolkit_info.syslinks then
                                for _, cmake_syslib in ipairs(toolkit_info.syslinks) do

                                    local dep_info  = occt_cmake_to_xmake_deps[cmake_syslib]
                                    if dep_info and dep_info.syslinks then
                                        for _, syslib in ipairs(dep_info.syslinks) do
                                            toolkit_component:add("syslinks", syslib)
                                            module_component:add("syslinks", syslib)
                                        end
                                    end
                                end
                            end
                            
                            -- should we remove this from components?
                            if toolkit_info.frameworks then
                                for _, cmake_syslib in ipairs(toolkit_info.frameworks) do

                                    local dep_info  = occt_cmake_to_xmake_deps[cmake_syslib]
                                    if dep_info and dep_info.frameworks then
                                        for _, framework in ipairs(dep_info.frameworks) do
                                            toolkit_component:add("frameworks", framework)
                                            module_component:add("frameworks", framework)
                                        end
                                    end
                                end
                            end
                            -- seems like component does not recognizes packages as deps
                            -- as it raise warning like unknown component (tbb)
                            -- skipping here as syslinks and  deps are still globally
                            -- available maybe it is best to remove above syslinks
                            -- per component and rely on package scope.

                            if toolkit_info.links then
                                for _, internal in ipairs(toolkit_info.links) do
                                    toolkit_component:add("links", internal)
                                end
                            end
                            
                            -- add toolkit itself as links
                            toolkit_component:add("links", toolkit)
                            -- add links to the module component as well
                            module_component:add("links", toolkit)
                        end
                    end
                end
            end
        end

        -- TODO add linkorders

    end)

    on_install(function (package)

        local raw_pdb_path = path.join(package:builddir(), "pdb")
        local pdb_dir = raw_pdb_path:gsub("\\", "/")  -- Force slash normalization

        -- Replace shared library .pdb path
        io.replace(
            "adm/cmake/occt_toolkit.cmake",
            "install (FILES  ${CMAKE_BINARY_DIR}/${OS_WITH_BIT}/${COMPILER}/bin\\${OCCT_INSTALL_BIN_LETTER}",
            "install (FILES  ${CMAKE_SOURCE_DIR}/" .. pdb_dir,
            {plain = true}
        )

        -- Replace static library .pdb path
        io.replace(
            "adm/cmake/occt_toolkit.cmake",
            "install (FILES  ${CMAKE_BINARY_DIR}/${OS_WITH_BIT}/${COMPILER}/lib\\${OCCT_INSTALL_BIN_LETTER}",
            "install (FILES  ${CMAKE_SOURCE_DIR}/" .. pdb_dir,
            {plain = true}
        )


        local configs = {}

        if package:version():lt("7.9.0") then
            table.insert(configs, "-DCMAKE_POLICY_VERSION_MINIMUM=3.5") -- CMake 4 support
        end
        
        table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0042=NEW") -- Relocatable shared libs on Macos

        table.insert(configs, "-DBUILD_LIBRARY_TYPE=" .. (package:config("shared") and "Shared" or "Static"))

        if package:version():ge("7.8.0") then
            table.insert(configs, "-DBUILD_CPP_STANDARD=C++" .. package:config("cxx_standard"))
        end

        if package:is_debug() then
            table.insert(configs, "-DBUILD_WITH_DEBUG=" .. (package:config("extended_debug_messages") and "ON" or "OFF"))
        end

        if package:is_plat("windows", "mingw") then
            table.insert(configs, "-DBUILD_SAMPLES_MFC=OFF")
            table.insert(configs, "-DUSE_D3D=" .. (package:config("d3d9") and "ON" or "OFF"))
        end

        if package:is_plat("macosx") then
            table.insert(configs, "-DUSE_GLX=OFF")
        end

        
        table.insert(configs, "-DINSTALL_SAMPLES=OFF")
        table.insert(configs, "-DINSTALL_TEST_CASES=OFF")

        table.insert(configs, "-DINSTALL_DIR_LAYOUT=Unix")
        table.insert(configs, "-DINSTALL_DIR_BIN=bin")
        table.insert(configs, "-DINSTALL_DIR_LIB=lib")
        table.insert(configs, "-DINSTALL_DIR_INCLUDE=include")
        table.insert(configs, "-DINSTALL_DIR_RESOURCE=res/resource")
        table.insert(configs, "-DINSTALL_DIR_DATA=res/data")
        table.insert(configs, "-DINSTALL_DIR_SAMPLES=res/samples")
        table.insert(configs, "-DINSTALL_DIR_DOC=res/doc")

        table.insert(configs, "-DBUILD_RESOURCES=OFF")
        table.insert(configs, "-DBUILD_USE_PCH=OFF")
        table.insert(configs, "-DBUILD_USE_VCPKG=OFF")
        table.insert(configs, "-DBUILD_Inspector=OFF")
        table.insert(configs, "-DBUILD_ENABLE_FPE_SIGNAL_HANDLER=OFF")
        table.insert(configs, "-DBUILD_DOC_Overview=OFF")
        table.insert(configs, "-DBUILD_SAMPLES_QT=OFF")
        table.insert(configs, "-DBUILD_RELEASE_DISABLE_EXCEPTIONS=ON")


         -- enable/disable occt modules
        table.insert(configs, "-DBUILD_MODULE_FoundationClasses=" .. (package:config("foundation_classes") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MODULE_ModelingData=" .. (package:config("modeling_data") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MODULE_ModelingAlgorithms=" .. (package:config("modeling_algorithms") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MODULE_Visualization=" .. (package:config("visualization") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MODULE_ApplicationFramework=" .. (package:config("application_framework") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_MODULE_DataExchange=" .. (package:config("data_exchange") and "ON" or "OFF"))
        
        if package:version():ge("7.7.2") or package:version():le("7.9.1") then
            table.insert(configs, "-DBUILD_MODULE_DETools=" .. (package:config("de_tools") and "ON" or "OFF"))
        end
        -- currently not supported
        table.insert(configs, "-DBUILD_MODULE_Draw=" .. (package:config("draw") and "ON" or "OFF"))
        
        table.insert(configs, "-DUSE_TBB=" .. (package:config("tbb") and "ON" or "OFF"))
        

        table.insert(configs, "-DUSE_FREEIMAGE=" .. (package:config("freeimage") and "ON" or "OFF"))    
        table.insert(configs, "-DUSE_FFMPEG=" .. (package:config("ffmpeg") and "ON" or "OFF"))          
        table.insert(configs, "-DUSE_VTK=" .. (package:config("vtk") and "ON" or "OFF"))          

        if package:version():ge("7.6.0") then
            table.insert(configs, "-DUSE_FREETYPE=" .. (package:config("freetype") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_OPENVR=" .. (package:config("openvr") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_GLES2=" .. (package:config("gles2") and "ON" or "OFF"))            
            table.insert(configs, "-DUSE_DRACO=" .. (package:config("draco") and "ON" or "OFF"))
            table.insert(configs, "-DUSE_TK=" .. (package:config("tk") and "ON" or "OFF"))              


        end

        local cmakelists = "CMakeLists.txt"
        local occt_csf_cmake_file = "adm/cmake/occt_csf.cmake"

        -- patches and dir injections
        local inc_dirs = {}
        local link_dirs = {}

        if package:config("tbb") then             

            local dep_tbb = package:dep("tbb")
            table.insert(configs, "-D3RDPARTY_TBB_DIR=" .. dep_tbb:installdir():gsub("\\", "/"))

            local tbb_libs = table.concat(dep_tbb:get("links") or {"tbb", "tbbmalloc", "tbbmalloc_proxy"}, " ")

            io.replace(
                occt_csf_cmake_file,
                "set (CSF_TBB \"tbb tbbmalloc\")",
                "set (CSF_TBB \"".. tbb_libs .. "\")",
                {plain = true}
            )

            print("------set (CSF_TBB \"".. tbb_libs .. "\")")

        end

        if package:config("freetype") then
            -- patches
            local dep_freetype = package:dep("freetype")
            table.insert(configs, "-D3RDPARTY_FREETYPE_DIR=" .. dep_freetype:installdir():gsub("\\", "/"))

            local freetype_libs = table.concat(dep_freetype:get("links") or {"freetype"}, " ")

            io.replace(
                occt_csf_cmake_file,
                "set (CSF_FREETYPE \"freetype\")",
                "set (CSF_FREETYPE \"".. freetype_libs .. "\")",
                {plain = true}
            )

            print("------set (CSF_FREETYPE \"" .. freetype_libs .. "\")")


        end

        if package:config("freeimage") then

            local dep_freeimage = package:dep("freeimage")
            table.insert(configs, "-D3RDPARTY_FREEIMAGE_DIR=" .. dep_freeimage:installdir():gsub("\\", "/"))

            -- freeimage get links somehow fails
            local freeimage_libs = table.concat(dep_freeimage:get("links") or {"freeimage"}, " ")
            io.replace(
                occt_csf_cmake_file,
                "set (CSF_FreeImagePlus \"freeimage\")",
                "set (CSF_FreeImagePlus \"".. freeimage_libs .. "\")",
                {plain = true}
            )

            print("------set (CSF_FreeImagePlus \"".. freeimage_libs .. "\")")

        end

        if package:config("ffmpeg") then

            local dep_ffmpeg = package:dep("ffmpeg")
            table.insert(configs, "-D3RDPARTY_FFMPEG_DIR=" .. dep_ffmpeg:installdir():gsub("\\", "/"))

            local ffmpeg_libs = dep_ffmpeg:get("links")

            io.replace(
                occt_csf_cmake_file,
                "set (CSF_FFmpeg \"avcodec avformat swscale avutil\")",
                "set (CSF_FFmpeg \"" .. table.concat(ffmpeg_libs, " ") .. "\")",
                {plain = true}
            )
        end

        if package:config("openvr") then

            local dep_openvr = package:dep("openvr")
            table.insert(configs, "-D3RDPARTY_OPENVR_DIR=" .. dep_openvr:installdir():gsub("\\", "/"))

            -- occt expects openvr.h as #include <openvr.h>
            local openvr_inc_dir = path.join(dep_openvr:installdir("include"), "openvr"):gsub("\\", "/")
            table.insert(configs, "-D3RDPARTY_OPENVR_INCLUDE_DIR=" .. openvr_inc_dir)

            -- Handle openvr links, defaulting for Windows 64-bit if undefined
            local openvr_libs = dep_openvr:get("links")
            if not openvr_libs then
                if package:is_targetos("windows") and package:is_targetarch("x64", "x86_64", "amd64") then
                    openvr_libs = {"openvr_api64"}
                else
                    openvr_libs = {"openvr_api"}
                end
            end

            io.replace(
                occt_csf_cmake_file,
                "set (CSF_OpenVR \"openvr_api\")",
                "set (CSF_OpenVR \"" .. table.concat(openvr_libs, " ") .. "\")",
                {plain = true}
            )

            print("------set (CSF_OpenVR \"" .. table.concat(openvr_libs, " ") .. "\")")
        end

        if package:config("rapidjson") then
            local dep_rapidjson = package:dep("rapidjson")
            table.insert(configs, "-D3RDPARTY_RAPIDJSON_DIR=" .. dep_rapidjson:installdir():gsub("\\", "/"))            
        end

        if package:config("draco") then

            local dep_draco = package:dep("draco")
            table.insert(configs, "-D3RDPARTY_DRACO_DIR=" .. dep_draco:installdir():gsub("\\", "/"))

            -- draco get links fails as well
            local draco_libs = table.concat(dep_draco:get("links") or {"draco"}, " ")
            io.replace(
                occt_csf_cmake_file,
                "set (CSF_Draco \"draco\")",
                "set (CSF_Draco \"" .. draco_libs .. "\")",
                {plain = true}
            )

        end


        import("package.tools.cmake").install(package, configs)


    end)

    on_test(function (package)
      
        assert(package:check_cxxsnippets({test = [[
           // #include <BRepBuilderAPI_MakeEdge.hxx>
           // #include <TopoDS_Edge.hxx>
           // #include <GC_MakeCircle.hxx>
           // #include <gce_MakeCirc.hxx>
           // #include <gp_Circ.hxx>
           //
           // #include <iostream>

            int main() {
           //     gp_Pnt pc(0, 0, 0);
           //     gp_Circ cir = gce_MakeCirc(pc, gp::DZ(), 5);
           //     auto geometry = GC_MakeCircle(cir).Value();
           //     TopoDS_Edge edge = BRepBuilderAPI_MakeEdge(geometry);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)