-- Page details
local PAGE_NAME = "config-editor"
local PAGE_TITLE = "Config Editor"
local PAGE_ICON = "edit"

-- Sidebar badge controls
local SHOW_PAGE_BADGE = false
local PAGE_BADGE_TEXT = "OK!"
local PAGE_BADGE_TYPE = "success"

local function CreatePage(FAQ, data, add)
    if GetConvar("wap_config_enable", "true") ~= "true" then return false, "Config Editor is disabled" end
    local readonly = (GetConvar("wap_config_readonly", "false") == "true")
    if data.id then
        local fileId = data.id
        local valid, file = IsValidSecret(fileId)
        if valid then
            local f = assert(io.open(file, "r"))
            local t = f:read("*all")
            f:close()

            add(FAQ.Node("h2", {class = "text-muted"}, file))

            local target = "/" .. GetCurrentResourceName() .. "/save"
            local secret = GenerateSecret("editor")
            local script = FAQ.Node("script", {type = ""}, [[
                function submitConfigForm() {
                    function reqListener () {
                        let resp = JSON.parse(this.responseText)
                        console.log(resp)
                        if (resp.status == true) {
                            let e = document.getElementById("cfgEditorOKAlert");
                            e.style = "display: block";
                        } else {
                            let e = document.getElementById("cfgEditorNOKAlert");
                            e.style = "display: block";
                        }
                    }

                    let object = {
                        secret: "]]..secret..[[",
                        file: "]]..fileId..[[",
                        content: document.getElementById("cfgFileContents").value
                    };

                    let json = JSON.stringify(object);

                    var oReq = new XMLHttpRequest();
                    oReq.addEventListener("load", reqListener);
                    oReq.open("POST", "]] .. target .. [[");
                    oReq.send(json);
                }
            ]])
            add(script)
            local form = FAQ.Node("div", {}, {
                FAQ.Node("textarea", {id = "cfgFileContents", name = "contents", style = "width:100%;", rows = "25", disabled = (readonly and "disabled" or nil)}, t),
            })
            add(form)
            local footer = FAQ.Node("div", {}, {
                FAQ.Button((readonly and "secondary" or "success"), (readonly and "Read-Only" or "Save File"), {type = "button", onclick="submitConfigForm()", disabled = (readonly and "disabled" or nil)}),
                FAQ.Node("div", {id = "cfgEditorOKAlert", style = "display: none"}, FAQ.Alert("primary", "File saved!")),
                FAQ.Node("div", {id = "cfgEditorNOKAlert", style = "display: none"}, FAQ.Alert("danger", "An error occured")),
            })
            add(footer)
        else
            return false, "Invalid file"
        end
    else
        return false, "No file specified"
    end
    return true, "OK"
end

-- Automatically sets up a page and sidebar option based on the above configurations
-- This should not need to be altered, and serves as the foundation of the plugin
Citizen.CreateThread(function()
    local PAGE_ACTIVE = false
    local FAQ = exports['webadmin-lua']:getFactory()
    exports['webadmin']:registerPluginPage(PAGE_NAME, function(data) --[[E]]--
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        PAGE_ACTIVE = true
        return FAQ.Nodes({ --[[R]]--
            FAQ.PageTitle(PAGE_TITLE),
            FAQ.BuildPage(CreatePage, data), --[[R]]--
        })
    end)
end)
