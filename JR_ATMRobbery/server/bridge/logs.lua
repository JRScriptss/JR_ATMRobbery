local function getOSTime()
    local date = os.date('*t')
    if date.month < 10 then date.month = "0" ..date.month end
    return date.day .. "/" .. date.month .. " - " .. date.hour .. " hours " .. date.min .. " minutes"
end

    function webhooks(message, colors)
    local discordEmbed = {
        ["type"] = "rich",
        ["title"] = "JR_ATMRobbery",
        ["color"] = colors,
        ["description"] = message,
        ["author"] = {
            ["name"] = "JR_ATMRobbery",
            ["url"] = "https://discord.gg/xa3Brpc2Zp",
            ["icon_url"] = "https://cdn.discordapp.com/attachments/1320803062801109113/1391402826198155345/NEWRRLOGO.png?ex=686bc45c&is=686a72dc&hm=04659db8f18559387b5d3f633db9647b86a309e6f00d20392cd54e8eb88f4faa&"
        },
        ["footer"] = {
            ["text"] = os.date("%d/%m/%Y %H:%M:%S"),
            ["icon_url"] = "https://cdn.discordapp.com/attachments/1320803062801109113/1391402826198155345/NEWRRLOGO.png?ex=686bc45c&is=686a72dc&hm=04659db8f18559387b5d3f633db9647b86a309e6f00d20392cd54e8eb88f4faa&"
        },
        ["thumbnail"] = {
            ["url"] = ""
        }
    }
    PerformHttpRequest(Config.WebhooksLinks, function() end, 'POST', json.encode({
        username = "JR_ATMRobbery",
        embeds = { discordEmbed }
    }), {['Content-Type'] = 'application/json'})
end
