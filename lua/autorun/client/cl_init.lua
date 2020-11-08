surface.CreateFont("open_sans_25b", {font = "Open Sans Bold", size = 25, weight = 800, antialias = true})
surface.CreateFont("open_sans_19b", {font = "Open Sans Bold", size = 19, weight = 800, antialias = true})
surface.SetFont("open_sans_19b")

local colour = {
   //["pure_white"] = Color(255, 255, 255),
   ["white"] = Color(220, 220, 220),
   //["grey"] = Color(155, 155, 155),
   //["darkest"] = Color(43, 49, 55),
   //["dark"] = Color(55, 61, 67),
   //["light"] = Color(101, 111, 123),
}

local showLawBox = true

function GetLineNum(text)
  local lineNum = select(2, text:gsub('\n','\n'))
  return lineNum
end

function OpenLawsEditor()
  local Frame = vgui.Create( "DFrame" )
  Frame:SetSize( 600, 550 )
  Frame:SetTitle( "Laws Editor" )
  Frame:Center()
  Frame:SetVisible( true )
  Frame:SetDraggable( true )
  Frame:ShowCloseButton( true )
  Frame:MakePopup()
  Frame.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200) )
  end

  local TextEntry = vgui.Create( "DTextEntry", Frame )
  local lawTxt = laws or "Default laws."
  TextEntry:SetPos( 8, 25 )
  TextEntry:SetSize( 583, 480 )
  TextEntry:SetText( lawTxt )
  TextEntry:SetMultiline( true )
  if (lawTxt == "") then lawTxt = "Default laws." end

  local DermaButton = vgui.Create( "DButton", Frame )
  DermaButton:SetText( "Update Laws" )
  DermaButton:SetPos( 178 , 512  )
  DermaButton:SetSize( 250, 30 )
  DermaButton.DoClick = function()
    local lawValue = TextEntry:GetValue()
    if(GetLineNum(lawValue) > 14)
    then
      notification.AddLegacy("Exceeded line limit", 1, 3)
      return
    end
    if(string.len(lawValue) > 800)
    then
      notification.AddLegacy("Exceeded character limit", 1, 3)
      return
    end
    net.Start( "LawsValue" )
    net.WriteString( lawValue )
    net.SendToServer()
  end
end

net.Receive( "LawsMenu", OpenLawsEditor )

net.Receive( "LawsPublic", function()
  laws = net.ReadString()
end)

function DrawLawBox()
  local lawTxt = laws or "Default laws."
  local x = ScrW()
  local y = ScrH()

  lawTxt = lawTxt:gsub("//", "\n"):gsub("\\n", "\n")
  lawTxt = DarkRP.textWrap(lawTxt, "open_sans_19b", 445)

  if (lawTxt == "") then lawTxt = "Default laws." end

  local txtWidth, txtHeight = surface.GetTextSize( lawTxt )

  surface.SetDrawColor(0, 0, 0, 128)
  surface.DrawRect(x * 0.76, y * 0.02, 455, txtHeight + 35)
  surface.SetFont("open_sans_25b")
  surface.SetTextColor(255, 255, 255, 255)
  surface.SetTextPos(x * 0.766, y * 0.02)
  surface.DrawText("Laws")
  //draw.RoundedBox( 0, x * 0.76, y * 0.02, 455, txtHeight + 35, Color( 0, 0, 0, 128 ) )
  //draw.DrawText( "Laws", "open_sans_25b", x * 0.766, y * 0.02, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
  surface.SetFont("open_sans_19b")
  surface.SetColor(colour.white)
  surface.SetPos(x * 0.766, y * 0.043)
  surface.DrawText(lawTxt)
  /*
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, Color(0, 0, 0, 170), 0)
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, Color(0, 0, 0, 100), 0)
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, colour.white, 0)
*/
end

net.Receive("LawsToggle",function()
  showLawBox = !showLawBox
  print("Lawbox value: ", showLawBox) //debug
end)

if(showLawBox)
then
  hook.Add( "HUDPaint", "HUDPaint_LawBox", DrawLawBox)
else
  hook.Remove( "HUDPaint", "HUDPaint_LawBox" )
end
