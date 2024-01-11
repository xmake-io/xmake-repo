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
-- @file        format.lua
--

task("format")
    set_category("plugin")
    on_run("main")
    set_menu {
                usage = "xmake format [options] [arguments]",
                description = "Format the current project.",
                options = {
                    {'s', "style",  "kv", nil,  "Set the path of .clang-format file, a coding style",
                                                values = {"LLVM", "Google", "Chromium", "Mozilla", "WebKit"}},
                    {nil, "create", "k", nil,   "Create a .clang-format file from a coding style"},
                    {'f', "files",  "v", nil,   "Set files path with pattern",
                                                "e.g.",
                                                "    - xmake format -f src/main.c",
                                                "    - xmake format -f 'src/*.c" .. path.envsep() .. "src/**.cpp'"}
                }
            }



