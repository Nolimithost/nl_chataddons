Config = {}

Config.AvailableCommands = {
    here = {
        enabled = true,
        drawDistance = 15.0,
        commandName = "here",
    },
    status = {
        enabled = true,
        drawDistance = 15.0,
        commandName = "status"
    },
    try = {
        enabled = true,
        drawDistance = 15.0,
        commandName = "try",

        results = {
            [0] = "YES",
            [1] = "NO"
        }
    },
}