local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ChessAPI = WebSocket.connect("wss://chess-api.com/v1")

local Board = require(ReplicatedStorage.Modules.Board)
local MatchClient = require(Players.LocalPlayer.PlayerGui.Client.MatchClient)

local Files = {
  a = "8,",
  b = "7,",
  c = "6,",
  d = "5,",
  e = "4,",
  f = "3,",
  g = "2,",
  h = "1,"
}

local GetSquare = function(Position)
    local Square = Position:gsub(".", function(Character)
        return Files[Character] or Character
    end)

    return workspace.Board[Square]
end

local From = Instance.new("Highlight")
From.OutlineColor = Color3.fromRGB(255, 255, 255)
From.FillColor = Color3.fromRGB(255, 255, 255)
From.OutlineTransparency = 0
From.FillTransparency = 0.5

local To = Instance.new("Highlight")
To.OutlineColor = Color3.fromRGB(255, 228, 136)
To.FillColor = Color3.fromRGB(255, 228, 136)
To.OutlineTransparency = 0
To.FillTransparency = 0.5

ChessAPI.OnMessage:Connect(function(Message)
    local Response = HttpService:JSONDecode(Message)

    if Response.type == "bestmove" then
        From.Parent = GetSquare(Response.from)
        To.Parent = GetSquare(Response.to)
    elseif Response.type == "error" then
        ChessAPI:Close()
    end
end)

ChessAPI.OnClose:Connect(function()
    From:Destroy()
    To:Destroy()
end)

ReplicatedStorage.Connections.MovePiece.OnClientEvent:Connect(function()
    task.wait(1)

    ChessAPI:Send(HttpService:JSONEncode({
        fen = Board.createFENLine(MatchClient.currentMatch)
    }))
end)
