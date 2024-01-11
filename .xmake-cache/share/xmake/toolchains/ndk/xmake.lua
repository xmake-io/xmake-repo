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

-- android ndk toolchain
--
-- @param sdkver    the platform sdk version
--
-- @code
-- target("test")
--     ...
--     set_toolchains("ndk")
--     set_toolchains("ndk", {sdkver = "23"})
-- @endcode
--
toolchain("ndk")

    -- set homepage
    set_homepage("https://developer.android.com/ndk")
    set_description("Android NDK")

    -- mark as standalone toolchain
    set_kind("standalone")

    -- check toolchain
    on_check("check")

    -- load toolchain
    on_load("load")
