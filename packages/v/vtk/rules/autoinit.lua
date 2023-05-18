-- Generate vtk autoinit header file. Substitution for cmake vtk_module_autoinit.
--
-- Usage:
--
-- add_rules("@vtk/autoinit") -- all modules are included by default

rule("autoinit")
    on_config(function (target)
        import("core.cache.memcache")

        local properties = memcache.get("rule.vtk.autogen")
        if properties then

            -- add target definitions for autogen header
            local autogen_dir = target:autogendir()
            local autogen_header_dir = path.directory(path.directory(path.directory(path.directory(autogen_dir))))
            local autogen_header = path.join(autogen_header_dir, "vtkModuleAutoInit_all.h")
            for module, property in pairs(properties) do
                if property.needs_autoinit and property.implementations then
                    target:add("defines", format("vtk%s_AUTOINIT_INCLUDE=\"%s\"", module, autogen_header:gsub("\\", "/")))
                end
            end
        else

            -- parse vtk cmake configuration files
            local vtk_root = target:pkg("vtk"):installdir()
            local vtk_version = target:pkg("vtk"):version()
            local vtk_ver = format("vtk-%s.%s", vtk_version:major(), vtk_version:minor())
            local vtk_dir = path.join(vtk_root, "lib", "cmake", vtk_ver)
            local property_file = path.join(vtk_dir, "VTK-vtk-module-properties.cmake")
            assert(os.isfile(property_file), "VTK cmake configuration files not found!")
            local property_file_content = io.readfile(property_file):split('\n', {plain = true})
            properties = {}
            for _, line in ipairs(property_file_content) do
                local module = line:match("set_property%(TARGET \"VTK::(.-)\".+%)")
                if module then
                    if properties[module] == nil then
                        properties[module] = {needs_autoinit = false}
                    end
                    local needs_autoinit = line:find("set_property%(TARGET \"VTK::.-\" PROPERTY \"INTERFACE_vtk_module_needs_autoinit\" \"1\"%)")
                    if needs_autoinit then
                        properties[module].needs_autoinit = true
                    end
                    local implementable = line:find("set_property%(TARGET \"VTK::.-\" PROPERTY \"INTERFACE_vtk_module_implementable\" \"TRUE\"%)")
                    if implementable then
                        properties[module].implementable = true
                    end
                    local implements = line:match("set_property%(TARGET \"VTK::.-\" PROPERTY \"INTERFACE_vtk_module_implements\" \"VTK::(.-)\"%)")
                    if implements then
                        properties[module].implements = implements
                    end
                end
            end
            for module, property in pairs(properties) do
                local implement = property.implements
                if implement then
                    if properties[implement] and properties[implement].needs_autoinit then
                        assert(properties[implement].implementable, format("VTK module %s is not implementable!", implement))
                        if properties[implement].implementations == nil then
                            properties[implement].implementations = {"vtk" .. module}
                        else
                            table.insert(properties[implement].implementations, "vtk" .. module)
                        end
                    end
                end
            end

            -- generate autogen header
            local autogen_dir = target:autogendir()
            local autogen_header_dir = path.directory(path.directory(path.directory(path.directory(autogen_dir))))
            local autogen_header = path.join(autogen_header_dir, "vtkModuleAutoInit_all.h")
            local autogen_content = ""
            for module, property in pairs(properties) do
                if property.needs_autoinit and property.implementations then
                    local implementation_content = table.concat(property.implementations, ",")
                    autogen_content = autogen_content .. format("#define vtk%s_AUTOINIT %d(%s)\n", module, #property.implementations, implementation_content)
                    target:add("defines", format("vtk%s_AUTOINIT_INCLUDE=\"%s\"", module, autogen_header:gsub("\\", "/")))
                end
            end
            if not memcache.get("rule.vtk.autogen") then
                memcache.set("rule.vtk.autogen", properties)
                io.writefile(autogen_header, autogen_content)
            end
        end
    end)
