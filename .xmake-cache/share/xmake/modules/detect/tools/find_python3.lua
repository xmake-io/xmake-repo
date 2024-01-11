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
-- @file        find_python3.lua
--

-- imports
import("lib.detect.find_program")
import("lib.detect.find_programver")

-- find python
--
-- @param opt  the arguments, e.g. {version = true}
--
-- @return     program, version
--
-- @code
--
-- local python = find_python3()
-- local python, version = find_python3({version = true})
--
-- @endcode
--
function main(opt)

    -- init options
    opt = opt or {}
    if is_host("windows") then
        opt.paths = opt.paths or {}
        local keys = winos.registry_keys("HKEY_CURRENT_USER\\SOFTWARE\\Python\\PythonCore\\3.*\\InstallPath")
        for _, key in ipairs(keys) do
            local value = try {function () return winos.registry_query(key .. ";ExecutablePath") end}
            if value and os.isfile(value) then
                table.insert(opt.paths, value)
            end
        end
    end

    -- find program
    local program = find_program(opt.program or "python3", opt)
    if not program then
        opt.force = true
        program = find_program("python", opt)
        opt.version = true
    end

    -- find program version
    local version = nil
    if program and opt.version then
        opt.command = function ()
            local outs, errs = os.iorunv(program, {"--version"})
            return ((outs or "") .. (errs or "")):trim()
        end
        version = find_programver(program, opt)
    end

    -- check version
    if version and not version:startswith("3.") then
        return
    end
    return program, version
end
