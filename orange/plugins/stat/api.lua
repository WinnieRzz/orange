local stat = require("orange.plugins.stat.stat")

local API = {}

API["/stat/status"] = function(req, res, next)
    local stat_result = stat.stat()

    local result = {
        success = true,
        data = stat_result
    }

    res:json(result)
end

return API