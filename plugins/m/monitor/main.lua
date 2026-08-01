import("core.base.option")

-- get the serial port glob patterns for the current host (usb-serial bridges and cdc-acm devices)
function _port_patterns()
    if is_host("macosx") then
        return {"/dev/cu.usbserial*", "/dev/cu.usbmodem*", "/dev/cu.wchusbserial*", "/dev/cu.SLAB_USBtoUART*"}
    elseif is_host("linux", "bsd") then
        return {"/dev/ttyUSB*", "/dev/ttyACM*"}
    end
    return {}
end

-- list the available serial ports
function _list_ports()
    local ports = {}
    if is_host("windows") then
        local outdata = try { function () return os.iorunv("powershell", {"-NoProfile", "-Command", "[System.IO.Ports.SerialPort]::GetPortNames()"}) end }
        for _, line in ipairs(outdata and outdata:split("\n", {plain = true}) or {}) do
            line = line:trim()
            if #line > 0 then
                table.insert(ports, line)
            end
        end
    else
        for _, pattern in ipairs(_port_patterns()) do
            table.join2(ports, os.files(pattern))
        end
    end
    table.sort(ports)
    return ports
end

-- resolve the serial port, auto-detecting it when not specified
function _resolve_port()
    local port = option.get("port")
    if port then
        return port
    end
    local ports = _list_ports()
    if #ports == 0 then
        raise("no serial port found! please connect your device or specify it with ${bright}--port${clear}.")
    elseif #ports > 1 then
        raise("multiple serial ports found:\n  %s\nplease specify one with ${bright}--port${clear}.", table.concat(ports, "\n  "))
    end
    return ports[1]
end

-- monitor on unix: configure the port with stty, then stream it to stdout
function _monitor_unix(port, baud)
    local flags = {is_host("macosx") and "-f" or "-F", port, tostring(baud), "raw", "-echo", "clocal", "-crtscts"}

    -- data bits
    table.insert(flags, "cs" .. (option.get("databits") or "8"))

    -- parity
    local parity = option.get("parity") or "none"
    if parity == "none" then
        table.insert(flags, "-parenb")
    elseif parity == "even" then
        table.join2(flags, {"parenb", "-parodd"})
    elseif parity == "odd" then
        table.join2(flags, {"parenb", "parodd"})
    end

    -- stop bits
    table.insert(flags, tostring(option.get("stopbits")) == "2" and "cstopb" or "-cstopb")

    os.execv("stty", flags)
    os.execv("cat", {port})
end

-- monitor on windows: use the .NET SerialPort via powershell (no extra dependency)
function _monitor_windows(port, baud)
    local parity = ({none = "None", even = "Even", odd = "Odd"})[option.get("parity") or "none"]
    local stopbits = tostring(option.get("stopbits")) == "2" and "Two" or "One"
    local script = string.format([[
$ErrorActionPreference = 'Stop'
$p = New-Object System.IO.Ports.SerialPort '%s',%d,'%s',%s,'%s'
$p.Open()
try {
    while ($true) {
        $s = $p.ReadExisting()
        if ($s.Length -gt 0) { [Console]::Out.Write($s) } else { Start-Sleep -Milliseconds 20 }
    }
} finally { $p.Close() }
]], port, baud, parity, option.get("databits") or "8", stopbits)
    os.execv("powershell", {"-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script})
end

function main()

    -- just list the available serial ports?
    if option.get("list") then
        local ports = _list_ports()
        if #ports == 0 then
            print("no serial port found!")
        else
            print("the available serial ports:")
            for _, port in ipairs(ports) do
                print("  " .. port)
            end
        end
        return
    end

    -- resolve the port and baud rate
    local port = _resolve_port()
    local baud = tonumber(option.get("baud")) or 115200
    cprint("monitoring ${bright}%s${clear} @ ${bright}%d${clear} (Ctrl-C to exit)", port, baud)

    -- monitor until interrupted (Ctrl-C)
    try
    {
        function ()
            if is_host("windows") then
                _monitor_windows(port, baud)
            else
                _monitor_unix(port, baud)
            end
        end,
        catch
        {
            function () end
        }
    }
    print("\nmonitor closed")
end
