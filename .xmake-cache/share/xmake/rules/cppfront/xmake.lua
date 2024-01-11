--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        xmake.lua
--

-- define rule: cppfront.build
rule("cppfront.build")
    set_extensions(".cpp2")
    on_load(function (target)
        -- only cppfront source files? we need to patch cxx source kind for linker
        local sourcekinds = target:sourcekinds()
        if #sourcekinds == 0 then
            table.insert(sourcekinds, "cxx")
        end
        local cppfront = target:pkg("cppfront")
        if cppfront and cppfront:installdir() then
            local includedir = path.join(cppfront:installdir(), "include")
            if os.isdir(includedir) then
                target:add("includedirs", includedir)
            end
        end
    end)
    on_buildcmd_file(function (target, batchcmds, sourcefile_cpp2, opt)

        -- get cppfront
        import("lib.detect.find_tool")
        local cppfront = assert(find_tool("cppfront", {check = "-h"}), "cppfront not found!")

        -- get c++ source file for cpp2
        local sourcefile_cpp = target:autogenfile((sourcefile_cpp2:gsub(".cpp2$", ".cpp")))
        local basedir = path.directory(sourcefile_cpp)

        -- add objectfile
        local objectfile = target:objectfile(sourcefile_cpp)
        table.insert(target:objectfiles(), objectfile)

        -- add commands
        local argv = {"-o", path(sourcefile_cpp), path(sourcefile_cpp2)}
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.cpp2 %s", sourcefile_cpp2)
        batchcmds:mkdir(basedir)
        batchcmds:vrunv(cppfront.program, argv)
        batchcmds:compile(sourcefile_cpp, objectfile, {configs = {languages = "c++20"}})

        -- add deps
        batchcmds:add_depfiles(sourcefile_cpp2)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)


-- define rule: cppfront
rule("cppfront")

    -- add build rules
    add_deps("cppfront.build")

    -- set compiler runtime, e.g. vs runtime
    add_deps("utils.compiler.runtime")

    -- inherit links and linkdirs of all dependent targets by default
    add_deps("utils.inherit.links")

    -- support `add_files("src/*.o")` and `add_files("src/*.a")` to merge object and archive files to target
    add_deps("utils.merge.object", "utils.merge.archive")

    -- we attempt to extract symbols to the independent file and
    -- strip self-target binary if `set_symbols("debug")` and `set_strip("all")` are enabled
    add_deps("utils.symbols.extract")

