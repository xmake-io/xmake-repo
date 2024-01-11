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
-- @file        cfeatures.lua
--

-- set features
function _set(feature, condition)
    _g.features = _g.features or {}
    _g.features[feature] = condition
end

-- get features
function main()

    -- init conditions
    local msvc_minver = "_MSC_VER >= 1200"
    local msvc_2005   = "_MSC_VER >= 1400"
    local msvc_2010   = "_MSC_VER >= 1600"
    local msvc_2019   = "_MSC_VER >= 1920"

    -- set language standard supports
    _set("c_std_89", msvc_2005)
    _set("c_std_99", msvc_2019)

    -- set features
    _set("c_static_assert",       msvc_2010)
    _set("c_restrict",            msvc_2005)
    _set("c_variadic_macros",     msvc_2005)
    _set("c_function_prototypes", msvc_minver)

    -- get features
    return _g.features
end

