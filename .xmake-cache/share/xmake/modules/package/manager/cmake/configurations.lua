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
-- @file        configurations.lua
--

-- get configurations
function main()
    return
    {
        link_libraries      = {description = "Set the cmake package dependencies, e.g. {\"abc::lib1\", \"abc::lib2\"}"},
        include_directories = {description = "Set the cmake package include directories, e.g. {\"${ZLIB_INCLUDE_DIRS}\"}"},
        search_mode         = {description = "Set the cmake package search mode, e.g. {\"config\", \"module\"}"},
        components          = {description = "Set the cmake package components, e.g. {\"regex\", \"system\"}"},
        moduledirs          = {description = "Set the cmake modules directories."},
        presets             = {description = "Set the preset values, e.g. {Boost_USE_STATIC_LIB = true}"},
        envs                = {description = "Set the run environments of cmake, e.g. {CMAKE_PREFIX_PATH = \"xxx\"}"},
    }
end

