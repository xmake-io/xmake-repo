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
-- @file        menu.lua
--

-- define module
local menu          = menu or {}

-- load modules
local os            = require("base/os")
local path          = require("base/path")
local utils         = require("base/utils")
local table         = require("base/table")
local language      = require("language/language")

-- get the option menu for action: xmake config or global
function menu.options(action)

    -- check
    assert(action)

    -- load all languages
    local languages, errors = language.load()
    if not languages then
        os.raise(errors)
    end

    -- load and merge all language options
    local exist     = {}
    local results   = {}
    for _, instance in pairs(languages) do

        -- get menu
        local menu = instance:menu()
        if menu then

            -- get the options for this action
            local options = menu[action]
            if options then

                -- get the language option
                for _, option in ipairs(options) do

                    -- merge it and remove repeat
                    local name = option[2] or option[1]
                    if name then
                        if not exist[name] then
                            table.insert(results, option)
                            exist[name] = true
                        end
                    else
                        table.insert(results, option)
                    end
                end
            end
        end
    end

    -- ok?
    return results
end

-- return module
return menu
