local PLUGIN = PLUGIN

print("BUT YOU???")
function PLUGIN:CreateMenuButtons( tTabs )
    tTabs["skills"] = {
        Create = function(info, dContainer)
            dContainer.panel = dContainer:Add("PRP.Menu.Skills")
        end,

        OnSelected = function(info, dContainer)
            -- dContainer.panel:RequestFocus()
        end,

        Sections = {
            ["jobs"] = {
                Create = function(info, dContainer)
                    dContainer.panel = dContainer:Add("PRP.Menu.Skills")
                end,

                OnSelected = function(info, dContainer)
                    -- dContainer.panel.searchEntry:RequestFocus()
                end
            }
        }
    }

    -- for k, v in pairs(ix.attributes.list) do
    --     tTabs["skills"].Sections[k] = {
    --         Create = function(info, dContainer)
    --             dContainer.panel = dContainer:Add("PRP.Menu.Skills")
    --         end,

    --         OnSelected = function(info, dContainer)
    --             -- dContainer.panel.searchEntry:RequestFocus()
    --         end
    --     }
    -- end
end