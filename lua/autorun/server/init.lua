util.AddNetworkString( "LawsMenu" )
util.AddNetworkString( "LawsValue" )
util.AddNetworkString( "LawsPublic" )
util.AddNetworkString( "LawsToggle" )

hook.Add( "PlayerSay", "OpenLawText", function( ply, text, public )
  local text = string.lower( text )
  if ( text == "/laws" ) then
    if ply:Team() ~= TEAM_PRESIDENT then DarkRP.notify( ply, 1, 3, "Only the president can edit the laws.") return '' end
    net.Start( "LawsMenu" )
    net.Send( ply )
    return ''
  end
end)

hook.Add( "PlayerSay", "OpenLawAdmin", function( ply, text, public )
  local text = string.lower( text )
  if ( text == "/forcelaws" ) then
    if not ply:IsSuperAdmin() then DarkRP.notify( ply, 1, 3, "You must be a superadmin to use this command." ) return '' end
    net.Start( "LawsMenu" )
    net.Send( ply )
    return ''
  end
end)

net.Receive( "LawsValue", function()
  local lawValue = net.ReadString()
  net.Start( "LawsPublic" )
  net.WriteString( lawValue )
  net.Broadcast()
  DarkRP.notifyAll( 0, 3, "The laws have been updated.")
end)

hook.Add("PlayerSay", "ToggleLawBox", function(ply, text, public)
  local text = string.lower(text)
  if(text == "/togglelaws")
  then
    net.Start("LawsToggle")
    net.Send(ply)
    return ''
  end
end)
