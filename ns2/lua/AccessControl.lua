

UserAccess = {
  Users = {},
}

local UserEntry = {
  Name = "fsfod",
  SteamID = 143987489374,
  GroupList = {},
}

local Group = {
  Id = 1,
  Name = "Root",
  ImmunityLevel = 1,
}

function UserAccess:CreateUser(name, steamId)

  local user = {
    Name = name,
    SteamID = steamId,
  }
 
  table.insert()
end

function UserAccess:IsUserInGroup(user, group)
  
end

function UserAccess:AddUserToGroup(user, group)
  
end

function UserAccess:RemoveUserFromGroup(user, group)
  
end

SVStorage = {
  Users = {},
  Groups = {},
  NextGroupId = 1
}

function SVStorage:CreateGroup(name)

  local group = {name, NextGroupId}
  
  table.insert(self.Groups, group)
  
  self.NextGroupId = self.NextGroupId+1
  
  return group
end

function SVStorage:CreateUser(name, steamId)
  
  if(self.Users[steamId]) then
    error("A user with that steam id already exists")
  end
  
  local user = {name, steamId, 0}

  self.Users[steamId] = user
 
  return user
end