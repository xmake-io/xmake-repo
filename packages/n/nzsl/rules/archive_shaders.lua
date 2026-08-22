-- Merge binary shaders to archivess
rule("archive.shaders")
	set_extensions(".nzsla")
	add_deps("@nzsl/find_nzsl")

	if add_orders then
		add_deps("@nzsl/compile.shaders")
		add_orders("@nzsl/compile.shaders", "@nzsl/archive.shaders")
	else
		add_deps("@nzsl/compile.shaders", { order = true })
	end

	before_buildcmd_file(function (target, batchcmds, sourcefile, opt)
		import("core.base.semver")

		local nzsla = target:data("nzsla")
		local runenvs = target:data("nzsl_runenv")
		assert(nzsla, "nzsla not found! please install nzsl package with nzsla enabled")

		local fileconfig = target:fileconfig(sourcefile)

		batchcmds:show_progress(opt.progress, "${color.build.object}archiving.shaders %s", sourcefile)
		local argv = { "--archive" }
		if semver.compare(nzsla.version, "1.1.0") >= 0 then
			table.insert(argv, "--skip-unchanged")
		end

		if fileconfig.compress then
			if type(fileconfig.compress) == "string" then
				table.insert(argv, "--compress=" .. fileconfig.compress)
			else
				table.insert(argv, "--compress")
			end
		end

		local outputfile = sourcefile
		if fileconfig.header then
			table.insert(argv, "--header")
			if type(fileconfig.header) == "string" then
				outputfile = outputfile .. fileconfig.header
			end
		end

		table.insert(argv, "--output=" .. outputfile)

		for _, shaderfile in ipairs(fileconfig.files) do
			table.insert(argv, shaderfile)
			batchcmds:add_depfiles(shaderfile)
		end

		batchcmds:vrunv(nzsla.program, argv, { curdir = ".", envs = runenvs })

		-- add deps
		batchcmds:add_depvalues(nzsla.version)
		batchcmds:set_depmtime(os.mtime(outputfile))
		batchcmds:set_depcache(target:dependfile(sourcefile))
end)
