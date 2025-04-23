-- Merge binary shaders to archivess
rule("find_nzsl")
	on_config(function(target)
		import("core.project.project")
		import("core.tool.toolchain")
		import("lib.detect.find_tool")

		-- on windows+asan/mingw we need run envs because of .dll dependencies which may be not part of the PATH
		local envs
		if is_plat("windows") then
			local msvc = target:toolchain("msvc")
			if msvc and msvc:check() then
				envs = msvc:runenvs()
			end
		elseif is_plat("mingw") then
			local mingw = target:toolchain("mingw")
			if mingw and mingw:check() then
				envs = mingw:runenvs()
			end
		end
		target:data_set("nzsl_envs", envs)

		-- find nzsl binaries
		local nzsl = project.required_package("nzsl~host") or project.required_package("nzsl")
		local nzsldir
		if nzsl then
			nzsldir = path.join(nzsl:installdir(), "bin")
			local osenvs = os.getenvs()
			envs = envs or {}
			for env, values in pairs(nzsl:get("envs")) do
				local flatval = path.joinenv(values)
				local oldenv = envs[env] or osenvs[env]
				if not oldenv or oldenv == "" then
					envs[env] = flatval
				elseif not oldenv:startswith(flatval) then
					envs[env] = flatval .. path.envsep() .. oldenv
				end
			end
		end

		local nzsla = find_tool("nzsla", { version = true, paths = nzsldir, envs = envs })
		local nzslc = find_tool("nzslc", { version = true, paths = nzsldir, envs = envs })

		target:data_set("nzsla", nzsla)
		target:data_set("nzslc", nzslc)
		target:data_set("nzsl_runenv", envs)
	end)
