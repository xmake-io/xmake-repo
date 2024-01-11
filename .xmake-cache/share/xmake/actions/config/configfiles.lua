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
-- @file        configfiles.lua
--

-- imports
import("core.base.option")
import("core.base.semver")
import("core.project.config")
import("core.project.depend")
import("core.project.project")
import("core.platform.platform")
import("lib.detect.find_tool")

-- get all configuration files
function _get_configfiles()
    local configfiles = {}
    for _, target in table.orderpairs(project.targets()) do
        if target:is_enabled() then

            -- get configuration files for target
            local srcfiles, dstfiles, fileinfos = target:configfiles()
            for idx, srcfile in ipairs(srcfiles) do

                -- get destinate file and file info
                local dstfile  = dstfiles[idx]
                local fileinfo = fileinfos[idx]

                -- get source info
                local srcinfo = configfiles[dstfile]
                if not srcinfo then
                    srcinfo = {}
                    configfiles[dstfile] = srcinfo
                end

                -- save source file
                if srcinfo.srcfile then
                    assert(path.absolute(srcinfo.srcfile) == path.absolute(srcfile), "file(%s) and file(%s) are writing a same file(%s)", srcfile, srcinfo.srcfile, dstfile)
                else
                    srcinfo.srcfile  = srcfile
                    srcinfo.fileinfo = fileinfo
                end

                -- we use first target to get dependfile path
                -- @see https://github.com/xmake-io/xmake/issues/3321
                if not srcinfo.dependfile then
                    srcinfo.dependfile = target:dependfile(srcfile)
                end

                -- save targets
                srcinfo.targets = srcinfo.targets or {}
                table.insert(srcinfo.targets, target)
            end
        end
    end
    return configfiles
end

-- get the builtin variables
function _get_builtinvars_target(target)

    -- get version variables
    local builtinvars = {}
    local version, version_build = target:version()
    if version then
        builtinvars.VERSION = version
        try {function ()
            local v = semver.new(version)
            if v then
                builtinvars.VERSION_MAJOR = v:major()
                builtinvars.VERSION_MINOR = v:minor()
                builtinvars.VERSION_ALTER = v:patch()
            end
        end}
        if version_build then
            builtinvars.VERSION_BUILD = version_build
        end
    end
    return builtinvars
end

-- get the git builtin variables
function _get_builtinvars_git(builtinvars)
    local cmds =
    {
        GIT_TAG         = {"describe", "--tags"},
        GIT_TAG_LONG    = {"describe", "--tags", "--long"},
        GIT_BRANCH      = {"rev-parse", "--abbrev-ref", "HEAD"},
        GIT_COMMIT      = {"rev-parse", "--short", "HEAD"},
        GIT_COMMIT_LONG = {"rev-parse", "HEAD"},
        GIT_COMMIT_DATE = {"log", "-1", "--date=format:%Y%m%d%H%M%S", "--format=%ad"}
    }
    for name, argv in pairs(cmds) do
        builtinvars[name] = function ()
            local result
            local git = find_tool("git")
            if git then
                result = try {function ()
                    return os.iorunv(git.program, argv)
                end}
            end
            if not result then
                result = "none"
            end
            return result:trim()
        end
    end
end

-- get the global builtin variables
function _get_builtinvars_global()
    local builtinvars = _g.builtinvars_global
    if builtinvars == nil then
        builtinvars =
        {
            arch  = config.get("arch") or os.arch()
        ,   plat  = config.get("plat") or os.host()
        ,   host  = os.host()
        ,   mode  = config.get("mode") or "release"
        ,   debug = is_mode("debug") and 1 or 0
        ,   os    = platform.os()
        }
        local builtinvars_upper = {}
        for name, value in pairs(builtinvars) do
            builtinvars_upper[name:upper()] = type(value) == "string" and value:upper() or value
        end
        table.join2(builtinvars, builtinvars_upper)
        _get_builtinvars_git(builtinvars)
        _g.builtinvars_global = builtinvars
    end
    return builtinvars
end

-- generate the configuration file
function _generate_configfile(srcfile, dstfile, fileinfo, targets)

    -- trace
    if option.get("verbose") then
        cprint("${dim}generating %s to %s ..", srcfile, dstfile)
    end

    -- only copy it?
    local generated = false
    if fileinfo.onlycopy then
        if os.mtime(srcfile) > os.mtime(dstfile) then
            os.cp(srcfile, dstfile)
            generated = true
        end
    else
        -- generate to the temporary file first
        local dstfile_tmp = path.join(os.tmpdir(), hash.uuid4(srcfile))
        os.tryrm(dstfile_tmp)
        os.cp(srcfile, dstfile_tmp)

        -- get all variables
        local variables = fileinfo.variables or {}
        for _, target in ipairs(targets) do

            -- get variables from the target
            for name, value in pairs(target:get("configvar")) do
                if variables[name] == nil then
                    value = table.unwrap(value)
                    variables[name] = value
                    variables["__extraconf_" .. name] = target:extraconf("configvar." .. name, value)
                end
            end

            -- get variables from the target.options
            for _, opt in ipairs(target:orderopts()) do
                for name, value in pairs(opt:get("configvar")) do
                    if variables[name] == nil then
                        variables[name] = table.unwrap(value)
                        variables["__extraconf_" .. name] = opt:extraconf("configvar." .. name, value)
                    end
                end
            end

            -- get the builtin variables from the target
            for name, value in pairs(_get_builtinvars_target(target)) do
                if type(value) == "function" then
                    value = value()
                end
                if variables[name] == nil then
                    variables[name] = value
                end
            end
        end
        -- get the global builtin variables
        for name, value in pairs(_get_builtinvars_global()) do
            if type(value) == "function" then
                value = value()
            end
            if variables[name] == nil then
                variables[name] = value
            end
        end

        -- replace all variables
        local pattern = fileinfo.pattern or "%${([^\n]-)}"
        io.gsub(dstfile_tmp, "(" .. pattern .. ")", function(_, variable)

            -- get variable name
            variable = variable:trim()

            -- is ${define variable}?
            local isdefine = false
            if variable:startswith("define ") then
                variable = variable:split("%s")[2]
                isdefine = true
            end

            -- is ${default variable xxx}?
            local default = nil
            local isdefault = false
            if variable:startswith("default ") then
                local varinfo = variable:split("%s")
                variable  = varinfo[2]
                default   = varinfo[3]
                isdefault = true
                assert(default ~= nil, "please set default value for variable(%s)", variable)
            end

            -- get variable value
            local value = variables[variable]
            local extraconf = variables["__extraconf_" .. variable]
            if isdefine then
                if value == nil then
                    value = ("/* #undef %s */"):format(variable)
                elseif type(value) == "boolean" then
                    if value then
                        value = ("#define %s 1"):format(variable)
                    else
                        value = ("/* #define %s 0 */"):format(variable)
                    end
                elseif type(value) == "number" then
                    value = ("#define %s %d"):format(variable, value)
                elseif type(value) == "string" then
                    local quote = true
                    local escape = false
                    if extraconf then
                        -- disable to wrap quote, @see https://github.com/xmake-io/xmake/issues/1694
                        if extraconf.quote == false then
                            quote = false
                        end
                        -- escape path seperator when with quote, @see https://github.com/xmake-io/xmake/issues/1872
                        if quote and extraconf.escape then
                            escape = true
                        end
                    end
                    if quote then
                        if escape then
                            value = value:gsub("\\", "\\\\")
                        end
                        value = ("#define %s \"%s\""):format(variable, value)
                    else
                        value = ("#define %s %s"):format(variable, value)
                    end
                else
                    raise("unknown variable(%s) type: %s", variable, type(value))
                end
            elseif isdefault then
                if value == nil then
                    value = default
                else
                    value = tostring(value)
                end
            else
                assert(value ~= nil, "cannot get variable(%s) in %s.", variable, srcfile)
            end
            dprint("  > replace %s -> %s", variable, value)
            if type(value) == "table" then
                dprint("invalid variable value", value)
            end
            return value
        end)

        -- update file if the content is changed
        if os.isfile(dstfile_tmp) then
            if os.isfile(dstfile) then
                if io.readfile(dstfile_tmp) ~= io.readfile(dstfile) then
                    os.cp(dstfile_tmp, dstfile)
                    generated = true
                else
                    -- I forget why I added it here, but if we switch the option, mode,
                    -- this will cause the whole project to be rebuilt,
                    -- even if nothing in config.h has been changed.
                    --
                    --os.touch(dstfile, {mtime = os.time()})
                end
            else
                os.cp(dstfile_tmp, dstfile)
                generated = true
            end
        end
    end

    -- trace
    cprint("generating %s ... %s", srcfile, generated and "${color.success}${text.success}" or "${color.success}cache")
end

-- the main entry function
function main(opt)

    -- enter project directory
    opt = opt or {}
    local oldir = os.cd(project.directory())

    -- generate all configuration files
    local configfiles = _get_configfiles()
    for dstfile, srcinfo in pairs(configfiles) do
        depend.on_changed(function ()
            _generate_configfile(srcinfo.srcfile, dstfile, srcinfo.fileinfo, srcinfo.targets)
        end, {files = srcinfo.srcfile,
              lastmtime = os.mtime(dstfile),
              dependfile = srcinfo.dependfile,
              changed = opt.force})
    end

    -- leave project directory
    os.cd(oldir)
end
