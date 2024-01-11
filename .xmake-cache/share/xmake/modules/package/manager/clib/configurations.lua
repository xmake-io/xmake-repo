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
-- @author      Adel Vilkov (aka RaZeR-RBI)
-- @file        configurations.lua
--

-- get configurations
function main()
    return
    {
        save = {description = "save dependency in project's package.json", default = false, type = "boolean"},
        save_dev = {description = "save as development dependency in project's package.json", default = false, type = "boolean"},
        outputdir = {description = "package installation directory relative to project root", default = "clib"},
    }
end

