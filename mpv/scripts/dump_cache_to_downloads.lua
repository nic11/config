local utils = require 'mp.utils'

local function dump_cache_to_downloads()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    local title = mp.get_property("media-title") or "output"

    title = title:gsub("[/\\?%%*:|\"<>]", "_")

    local output_path = home .. "/Downloads/mpv/" .. title .. ".mp4"

    mp.commandv("dump-cache", "0", "no", output_path)

    mp.osd_message("Dumping cache to: " .. output_path, 3)
    print("Dumping cache to: " .. output_path)
end

mp.add_key_binding("Shift+d", "dump-cache-download", dump_cache_to_downloads)
