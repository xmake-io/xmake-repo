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
-- @file        find_cmake.lua
--

-- imports
import("lib.detect.find_program")
import("lib.detect.find_programver")
import("core.tool.toolchain")

-- find cmake
--
-- @param opt   the argument options, e.g. {version = true}
--
-- @return      program, version
--
-- @code
--
-- local cmake = find_cmake()
-- local cmake, version = find_cmake({version = true})
--
-- @endcode
--
function main(opt)

    -- init options
    opt = opt or {}
    if is_host("windows") then
        opt.paths = "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Kitware\\CMake;InstallDir)\\bin"
    end

    -- find program
    local program = find_program(opt.program or "cmake", opt)
    if not program and is_host("windows") then
        -- we always use host/arch to avoid windows/arm64, because we are building packages for cross-compilation
        local msvc = toolchain.load("msvc", {plat = os.host(), arch = os.arch()})
        if msvc:check() then
            opt.envs = msvc:runenvs() -- we attempt to find it from vstudio environments
            opt.force = true
            program = find_program(opt.program or "cmake", opt)
        end
    end

    -- find program version
    local version = nil
    if program and opt and opt.version then
        version = find_programver(program, opt)
    end
    return program, version
end
