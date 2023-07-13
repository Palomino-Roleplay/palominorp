local PANEL = {}

vgui.Register( "PRP.Menu", PANEL, "DFrame" )

local PRP_MENU = false
concommand.Add( "prp_menu", function()
    print("tested!")

    if PRP_MENU then
        PRP_MENU:Remove()
        PRP_MENU = false
    else
        PRP_MENU = vgui.Create( "PRP.Menu" )
    end
end )

print("why!!?")

concommand.Add( "prp_uitest", function()
    local imgURL = "http://loopback.gmod:3000/ui/bg/plymenu/" .. ScrW() .. "/" .. ScrH() -- Replace with your image URL

    -- Download the image and create a material
    local function DownloadImage(url, callback)
        print("download")
        http.Fetch(url, function(data)
            print("fetch")
            if data then
                local fileName = "plymenu_" .. ScrW() .. "x" .. ScrH() .. "_" .. math.floor(CurTime()) .. ".png"

                if file.Exists(fileName, "DATA") then
                    file.Delete(fileName, "DATA")
                end

                print("data")
                file.Write(fileName, data)
                callback(Material("data/" .. fileName, ""))
            end
        end, function(error)
            print("error")
            print(error)
        end )
    end

    DownloadImage(imgURL, function(material)
        -- Check if the material is valid
        print("downloaded")
        if not material:IsError() then
            print("not error")
            hook.Add("HUDPaint", "DisplayImageOnHUD", function()
                -- Get the screen size
                local screenW, screenH = ScrW(), ScrH()

                print("painting")
                
                -- Calculate the size and position of the image on the HUD
                local imgWidth, imgHeight = screenW * 1, screenH * 1
                local imgX, imgY = (screenW - imgWidth) * 1, (screenH - imgHeight) * 1
                
                print( imgX, imgY, imgWidth, imgHeight )

                -- Draw the image on the HUD
                surface.SetMaterial(material)
                surface.SetDrawColor(255, 255, 255, 245)
                surface.DrawTexturedRect(imgX, imgY, imgWidth, imgHeight)
            end )
        end
    end)
end )

concommand.Add( "prp_uitest_stop", function()
    hook.Remove( "HUDPaint", "DisplayImageOnHUD" )
end )