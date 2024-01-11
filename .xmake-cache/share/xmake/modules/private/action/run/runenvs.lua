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
-- @author      ruki, OpportunityLiu, SirLynix
-- @file        runenvs.lua
--

-- imports
import("core.base.hashset")

-- add search directories for all dependent shared libraries on windows
function _make_runpath_on_windows(target)

    local pathenv = {}
    local searchdirs = hashset.new()
    local function insert(dir)
        if not path.is_absolute(dir) then
            dir = path.absolute(dir, os.projectdir())
        end
        if searchdirs:insert(dir) then
            table.insert(pathenv, dir)
        end
    end

    -- recursively add targets and dep targets linkdirs
    local seentargets = hashset.new()
    local function insert_target(target)
        if seentargets:insert(target) then
            for _, linkdir in ipairs(target:get("linkdirs")) do
                insert(linkdir)
            end
            for _, opt in ipairs(target:orderopts()) do
                for _, linkdir in ipairs(opt:get("linkdirs")) do
                    insert(linkdir)
                end
            end
            for _, pkg in ipairs(target:orderpkgs()) do
                for _, linkdir in ipairs(pkg:get("linkdirs")) do
                    insert(linkdir)
                end
            end
            for _, dep in ipairs(target:orderdeps()) do
                if dep:kind() == "shared" then
                    insert(dep:targetdir())
                end
                insert_target(dep)
            end
            for _, toolchain in ipairs(target:toolchains()) do
                local runenvs = toolchain:runenvs()
                if runenvs and runenvs.PATH then
                    for _, env in ipairs(path.splitenv(runenvs.PATH)) do
                        insert(env)
                    end
                end
            end
        end
    end

    insert_target(target)

    return pathenv
end

-- flatten envs ({PATH = {"A", "B"}} => {PATH = "A;B"})
function _flatten_envs(envs)
    local flatten_envs = {}
    for name, values in pairs(envs) do
        flatten_envs[name] = path.joinenv(values)
    end
    return flatten_envs
end

-- join addenvs and setenvs in a common envs table
function join(addenvs, setenvs)
    local envs = os.joinenvs(addenvs and _flatten_envs(addenvs) or {})
    if setenvs then
        envs = os.joinenvs(envs, _flatten_envs(setenvs))
    end
    return envs
end

function make(target)

    -- check
    assert(target)

    -- add run environments
    local set = {}
    local add = {}
    local runenvs = target:get("runenvs")
    if runenvs then
        for name, values in pairs(runenvs) do
            add[name] = table.wrap(values)
        end
    end
    local runenv = target:get("runenv")
    if runenv then
        for name, value in pairs(runenv) do
            set[name] = table.wrap(value)
            if add[name] then
                utils.warning(format("both add_runenvs and set_runenv called on environment variable \"%s\", the former one will be ignored.", name))
                add[name] = nil
            end
        end
    end

    -- add search directories for all dependent shared libraries on windows
    if target:is_plat("windows") or (target:is_plat("mingw") and is_host("windows")) then
        -- get PATH table
        local pathenv = add["PATH"] or set["PATH"]
        local runpath = _make_runpath_on_windows(target)
        if pathenv == nil then
            add["PATH"] = runpath
        else
            table.append(pathenv, table.unpack(runpath))
        end
    end
    return add, set
end
