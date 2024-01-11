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
-- @file        load.lua
--

function _get_apis()
    local apis = {}
    apis.values = {
        -- target.add_xxx
        "target.add_mrcflags"
        -- option.add_xxx
    ,   "option.add_mrcflags"
        -- toolchain.add_xxx
    ,   "toolchain.add_mrcflags"
    }
    apis.paths = {
        -- target.add_xxx
        "target.add_includedirs"
    ,   "target.add_sysincludedirs"
        -- option.add_xxx
    ,   "option.add_includedirs"
    ,   "option.add_sysincludedirs"
    }
    return apis
end

function main()
    return {apis = _get_apis()}
end


