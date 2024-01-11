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

language("nim")
    add_rules("nim")
    set_sourcekinds {nc = ".nim"}
    set_sourceflags {nc = "ncflags"}
    set_targetkinds {binary = "ncld", static = "ncar", shared = "ncsh"}
    set_targetflags {binary = "ldflags", static = "arflags", shared = "shflags"}
    set_langkinds {nim = "nc"}
    set_mixingkinds("nc")

    on_load("load")

    set_nameflags {
        object = {
            "config.includedirs"
        ,   "target.symbols"
        ,   "target.warnings"
        ,   "target.defines"
        ,   "target.undefines"
        ,   "target.optimize:check"
        ,   "target.vectorexts:check"
        ,   "target.includedirs"
        ,   "toolchain.includedirs"
        }
    ,   binary = {
            "config.linkdirs"
        ,   "target.linkdirs"
        ,   "target.rpathdirs"
        ,   "target.strip"
        ,   "target.symbols"
        ,   "toolchain.linkdirs"
        ,   "toolchain.rpathdirs"
        ,   "config.links"
        ,   "target.links"
        ,   "toolchain.links"
        }
    ,   shared = {
            "config.linkdirs"
        ,   "target.linkdirs"
        ,   "target.strip"
        ,   "target.symbols"
        ,   "toolchain.linkdirs"
        ,   "config.links"
        ,   "target.links"
        ,   "toolchain.links"
        }
    ,   static = {
            "target.strip"
        ,   "target.symbols"
        }
    }

    set_menu {
                config =
                {
                    {category = "Cross Complation Configuration/Compiler Configuration"      }
                ,   {nil, "nc",         "kv", nil,         "The Nim Compiler"                }

                ,   {category = "Cross Complation Configuration/Linker Configuration"        }
                ,   {nil, "ncld",      "kv", nil,          "The Nim Linker"                  }
                ,   {nil, "ncar",      "kv", nil,          "The Nim Static Library Archiver" }
                ,   {nil, "ncsh",      "kv", nil,          "The Nim Shared Library Linker"   }

                ,   {category = "Cross Complation Configuration/Builtin Flags Configuration" }
                ,   {nil, "linkdirs",   "kv", nil,         "The Link Search Directories"     }
                }
            }

