rule("compiler_setup")
    on_config(function(target)
        if target:has_tool("cxx", "cl") then
            -- MSVC
            target:add("cxxflags", "/bigobj", "/permissive-", "/Zc:__cplusplus", "/Zc:externConstexpr", "/Zc:inline", "/Zc:lambda", "/Zc:preprocessor", "/Zc:referenceBinding", "/Zc:strictStrings", "/Zc:throwingNew", {tools = "cl"})
            target:add("defines", "_CRT_SECURE_NO_WARNINGS", "_ENABLE_EXTENDED_ALIGNED_STORAGE")

            -- Enable the following additional warnings:
            target:add("cxflags", "/we4062", {tools = "cl"}) -- Switch case not handled (warning as error)
            target:add("cxflags", "/we4426", {tools = "cl"}) -- Optimization flags changed after including header, may be due to #pragma optimize() (warning as error)
            target:add("cxflags", "/we5038", {tools = "cl"}) -- Data member will be initialized after data member (warning as error)
        
            -- Disable the following warnings:
            target:add("cxflags", "/wd4251", {tools = "cl"}) -- class needs to have dll-interface to be used by clients of class blah blah blah
            target:add("cxflags", "/wd4275", {tools = "cl"}) -- DLL-interface class 'class_1' used as base for DLL-interface blah
        else
            -- GCC-compatible (GCC, Clang, ...)
            target:add("cxflags", "-Wtrampolines", {tools = "gcc"})
            target:add("cxflags", "-Werror=inconsistent-missing-override", {tools = "clang"})
            target:add("cxflags", "-Werror=pessimizing-move")
            target:add("cxflags", "-Werror=redundant-move")
            target:add("cxflags", "-Werror=reorder")
            target:add("cxflags", "-Werror=suggest-override", {tools = "gcc"})
            target:add("cxflags", "-Werror=switch")
        end 
    end)
