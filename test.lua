import("lib.detect.find_library")
local lib = find_library("execinfo", { "/usr/lib", "/usr/local/lib" })
print(lib.link)
