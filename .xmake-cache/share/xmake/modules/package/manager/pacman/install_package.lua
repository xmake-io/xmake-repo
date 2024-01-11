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
-- @file        install_package.lua
--

-- imports
import("core.base.option")
import("lib.detect.find_tool")
import("privilege.sudo")

-- install package
--
-- @param name  the package name
-- @param opt   the options, e.g. {verbose = true, pacman = "the package name"}
--
-- @return      true or false
--
function main(name, opt)

    -- init options
    opt = opt or {}

    -- find pacman
    local pacman = find_tool("pacman")
    if not pacman then
        raise("pacman not found!")
    end

    -- for msys2/mingw? mingw-w64-[i686|x86_64]-xxx
    if is_subhost("msys") and opt.plat == "mingw" then
        -- try to get the package prefix from the environment first
        -- https://www.msys2.org/docs/package-naming/
        local prefix = "mingw-w64-"
        local arch = (opt.arch == "x86_64" and "x86_64-" or "i686-")
        local msystem = os.getenv("MSYSTEM")
        if msystem and not msystem:startswith("MINGW") then
            local i, j = msystem:find("%D+")
            name = prefix .. msystem:sub(i, j):lower() .. "-" .. arch .. name
        else
            name = prefix .. arch .. name
        end
    end

    -- init argv
    local argv = {"-Sy", "--noconfirm", "--needed", "--disable-download-timeout", opt.pacman or name}
    if opt.verbose or option.get("verbose") then
        table.insert(argv, "--verbose")
    end

    -- install package directly if the current user is root
    if is_subhost("msys") or os.isroot() then
        os.vrunv(pacman.program, argv)
    -- install with administrator permission?
    elseif sudo.has() then

        -- install it if be confirmed
        local description = format("try installing %s with administrator permission", name)
        local confirm = utils.confirm({default = true, description = description})
        if confirm then
            sudo.vrunv(pacman.program, argv)
        end
    else
        raise("cannot get administrator permission!")
    end
end
