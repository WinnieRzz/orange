local ipairs = ipairs
local tonumber = tonumber
local cjson = require("cjson")
local IO = require("orange.utils.io")
local Store = require("orange.store.base")
local FileStore = Store:extend()

function FileStore:new(options)
    options = options or {}
    self._name = options.name or "file-store"
    FileStore.super.new(self, self._name)
    self.store_type = "file"
    self.file_path = options.file_path
    self.data = {}
    if not self.loaded then
        ngx.log(ngx.ERR, "load file store configurations... ", options.file_path)
        self:load()
        self.loaded = true
    end
end

function FileStore:load()
    local status, err = pcall(function()
        local config_content = IO.read_file(self.file_path)
        local config = cjson.decode(config_content)
        if config then
            self.data = config
        end
    end)
    if not status or err then
        ngx.log(ngx.ERR, "load file store error: ", err)
        os.exit(1)
    end
end


function FileStore:set(k, v)
    if not k or k == "" then return false, "nil key." end
    ngx.log(ngx.ERR, " file_store \"", self._name, "\" set:", k)
    self.data[k] = v
end

function FileStore:get(k)
    if not k or k == "" then return nil end
    ngx.log(ngx.ERR, " file_store \"", self._name, "\" get:", k)
    return self.data[k]
end

function FileStore:get_all()
    return self.data
end


function FileStore:store()
    local config_content = cjson.encode(self.data)
    local result, err = IO.write_to_file(self.file_path, config_content)

    if result and not err then
        ngx.log(ngx.ERR, " file_store store success.")
        self:load()
        return true
    else
        ngx.log(ngx.ERR, " file_store store error:", err)
        return false
    end
end



return FileStore