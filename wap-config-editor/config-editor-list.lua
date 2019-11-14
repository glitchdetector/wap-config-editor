-- Page details
local PAGE_NAME = "config-editor-list"
local PAGE_TITLE = "Config Files"
local PAGE_ICON = "edit"

-- Sidebar badge controls
local SHOW_PAGE_BADGE = false
local PAGE_BADGE_TEXT = "OK!"
local PAGE_BADGE_TYPE = "success"

local AVAILABLE_CONFIG_FILES = {}
function RefreshAvailableConfigFiles()
    local ft = GetConvar("wap_config_extension", "*.cfg")
    local n = os.tmpname()
    os.execute("dir "..ft.." /b /A:-D-H /S > " .. n)
    local r = {}
    for l in io.lines(n) do
        local s = l:gsub("\\", "/")
        table.insert(r, s)
    end
    os.remove(n)
    AVAILABLE_CONFIG_FILES = r
end
RefreshAvailableConfigFiles()

local function CreatePage(FAQ, data, add)
    if data.refresh then
        RefreshAvailableConfigFiles()
    end
    add(FAQ.ButtonGroup({
        FAQ.Button("success", {
            FAQ.TextIcon("sync-alt"),
            "Refresh List"
        }, {href = FAQ.GenerateDataUrl(PAGE_NAME, {refresh = "yes"})}, "a"),
        FAQ.Button("secondary", {
            FAQ.Icon("wrench"),
        }, {href = FAQ.GenerateDataUrl("settings", {resource = GetCurrentResourceName()})}, "a"),
    }))
    for _, fileName in next, AVAILABLE_CONFIG_FILES do
        local secret = GenerateSecret(fileName)
        add(FAQ.Node("div", {class = "my-1"}, {
            FAQ.Form("config-editor", {id = secret}, FAQ.Button("primary form-control text-left", {
                FAQ.TextIcon("edit"),
                fileName,
            }, {type = "submit"}))
        }))
    end
    return true, "OK"
end

-- Automatically sets up a page and sidebar option based on the above configurations
-- This should not need to be altered, and serves as the foundation of the plugin
Citizen.CreateThread(function()
    local PAGE_ACTIVE = false
    local FAQ = exports['webadmin-lua']:getFactory()
    exports['webadmin']:registerPluginOutlet("nav/sideList", function(data) --[[R]]--
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        local _PAGE_ACTIVE = PAGE_ACTIVE PAGE_ACTIVE = false
        return FAQ.SidebarOption(PAGE_NAME, PAGE_ICON, PAGE_TITLE, SHOW_PAGE_BADGE and PAGE_BADGE_TEXT or false, PAGE_BADGE_TYPE, _PAGE_ACTIVE) --[[R]]--
    end)
    exports['webadmin']:registerPluginPage(PAGE_NAME, function(data) --[[E]]--
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        PAGE_ACTIVE = true
        return FAQ.Nodes({ --[[R]]--
            FAQ.PageTitle(PAGE_TITLE),
            FAQ.BuildPage(CreatePage, data), --[[R]]--
        })
    end)
end)

SetHttpHandler(function(req, res)
	local path = req.path
	if req.path == '/save' then
        if GetConvar("wap_config_enable", "true") ~= "true" then
            res.send(json.encode({
                status = true,
                message = "Config Editor is disabled",
            }))
            return
        end
        if GetConvar("wap_config_readonly", "false") == "true" then
            res.send(json.encode({
                status = true,
                message = "Config Editor is in read-only mode",
            }))
            return
        end
    	if req.method == 'POST' then
        	req.setDataHandler(function(body)
                local data = json.decode(body)
                if data and data.secret and data.file and data.content then
                    local valid, secretType = IsValidSecret(data.secret)
                    if valid and secretType == "editor" then
                        local fileId = data.file
                        local fileValid, file = IsValidSecret(fileId)
                        if fileValid then
                            local content = data.content
                            local f = assert(io.open(file, "r+"))

                            -- Save backup file
                            local t = f:read("*all")
                            SaveResourceFile(GetCurrentResourceName(), "backup.bak", t, -1)

                            f:write(content)
                            io.close(f)
                            res.send(json.encode({
                                status = true,
                                message = "Saved file!",
                            }))
                            return
                        end
                    end
                end
                res.send(json.encode({
                    status = false,
                    message = "Failed to save file",
                }))
                return
            end)
    	end
    end
end)
