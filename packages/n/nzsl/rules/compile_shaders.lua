-- Compile shaders to includables headers
rule("compile.shaders")
	set_extensions(".nzsl", ".nzslb")
	add_deps("@nzsl/find_nzsl")

	on_config(function (target)
		local archives = {}

		for _, sourcebatch in pairs(target:sourcebatches()) do
			local rulename = sourcebatch.rulename
			if rulename == "@nzsl/compile.shaders" then
				for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
					local fileconfig = target:fileconfig(sourcefile)
					if fileconfig and fileconfig.archive then
						local archivefiles = archives[fileconfig.archive]
						if not archivefiles then
							archivefiles = {}
							archives[fileconfig.archive] = archivefiles
						end
						table.insert(archivefiles, path.join(path.directory(sourcefile), path.basename(sourcefile) .. ".nzslb"))
					end
				end
			end
		end

		if not table.empty(archives) then
			assert(target:rule("@nzsl/archive.shaders"), "you must add the @nzsl/archive.shaders rule to the target")
			for archive, archivefiles in table.orderpairs(archives) do
				local args = { always_added = true, compress = true, files = archivefiles }
				if archive:endswith(".nzsla.h") or archive:endswith(".nzsla.hpp") then
					args.header = path.extension(archive)
					archive = archive:sub(1, -#args.header - 1) -- foo.nzsla.h => foo.nzsla
				end

				target:add("files", archive, args)
			end
		end
	end)

	before_buildcmd_file(function (target, batchcmds, shaderfile, opt)
		import("core.base.semver")

		local outputdir = target:data("nzsl_includedirs")
		local nzslc = target:data("nzslc")
		local runenvs = target:data("nzsl_runenv")
		assert(nzslc, "nzslc not found! please install nzsl package with nzslc enabled")

		local fileconfig = target:fileconfig(shaderfile) or {}
		local header = fileconfig.archive == nil

		-- add commands
		batchcmds:show_progress(opt.progress, "${color.build.object}compiling.shader %s", shaderfile)
		local argv = { "--compile=nzslb" .. (header and "-header" or ""), "--partial", "--optimize" }
		if semver.compare(nzslc.version, "1.1.0") >= 0 then
			table.insert(argv, "--skip-unchanged")
		end
		if outputdir then
			batchcmds:mkdir(outputdir)
			table.insert(argv, "--output=" .. outputdir)
		end

		-- handle --log-format
		local kind = target:data("plugin.project.kind") or ""
		if kind:match("vs") then
			table.insert(argv, "--log-format=vs")
		end

		table.insert(argv, shaderfile)

		batchcmds:vrunv(nzslc.program, argv, { curdir = ".", envs = runenvs })

		local outputfile = path.join(outputdir or path.directory(shaderfile), path.basename(shaderfile) .. ".nzslb" .. (header and ".h" or ""))

		-- add deps
		batchcmds:add_depfiles(shaderfile)
		batchcmds:add_depvalues(nzslc.version)
		batchcmds:set_depmtime(os.mtime(outputfile))
		batchcmds:set_depcache(target:dependfile(outputfile))
	end)
