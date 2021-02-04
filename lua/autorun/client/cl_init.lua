//creating fonts for later use
surface.CreateFont("open_sans_25b", {font = "Open Sans Bold", size = 25, weight = 800, antialias = true})
surface.CreateFont("open_sans_19b", {font = "Open Sans Bold", size = 19, weight = 800, antialias = true})
surface.SetFont("open_sans_19b") //I'm not sure if this is necessary but it makes me feel more comfortable

//literally the only color from the original code actually used
//will probably get rid of it later
local colour = {
   ["white"] = Color(220, 220, 220)
}
local laws = DarkRP.getLaws()
local showLawBox = true  //boolean value used to set whether box is shown

/*
This function is used to get the number of lines
The number of lines is used later to validate it's not too many
Otherwise it could take up too much of a screen
it returns the number of lines in the given text
*/
if laws.isEmpty() then laws = "Default Laws" end //not sure I like this, figure out how to remove it later if it's even necessary

function GetLineNum(text)
  local lineNum = select(2, text:gsub('\n','\n'))
  return lineNum
end

function OpenLawsEditor() //most of this function was from the original coder
  local Frame = vgui.Create( "DFrame" )
  Frame:SetSize( 600, 550 )
  Frame:SetTitle( "Laws Editor" )
  Frame:Center()
  Frame:SetVisible( true )
  Frame:SetDraggable( true )
  Frame:ShowCloseButton( true )
  Frame:MakePopup()
  Frame.Paint = function( self, w, h ) //I don't like these variables but I'm not comfortable changing them
    draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200) )
  end
//a lot of this you should go to facepunch wiki to figure out, not enough room to explain within code
  local lawList = vgui.Create( "DListView", Frame )
  lawList:SetDataHeight(25)
  lawList:AddColumn("#"):SetWidth(10)
  lawList:AddColumn("Law"):SetWidth(480)
  lawList:SetMultiSelect(false)

  for k,v in ipairs(laws) do
    lawList:AddLine(k,v)
  end
  //local lawTxt = laws or "Default laws."
  //TextEntry:SetPos( 8, 25 )
  //TextEntry:SetSize( 583, 480 )
  //TextEntry:SetText( lawTxt )
  //TextEntry:SetMultiline( true )
  //if (lawTxt == "") then lawTxt = "Default laws." end

  local DermaButton = vgui.Create( "DButton", Frame )
  DermaButton:SetText( "Update Laws" )
  DermaButton:SetPos( 178 , 512  )
  DermaButton:SetSize( 250, 30 )
  DermaButton.DoClick = function() //every time I try to seperate this function it breaks, so it stays here
    local lawValue = TextEntry:GetValue()
    //if the line number or character number is too high I want to block the change
    //this helps limit trolling slightly
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
  laws = DarkRP.getLaws()
end)

function DrawLawBox() //I think all of this function was from the original coder, so I can't explain much
  local lawTxt = laws or "Default laws." //changing this breaks things
  local x = ScrW() //width
  local y = ScrH() //height

  lawTxt = lawTxt:gsub("//", "\n"):gsub("\\n", "\n") //I'm not sure why this is here, but I'm not gonna fuck with it
  lawTxt = DarkRP.textWrap(lawTxt, "open_sans_19b", 445)

  if (lawTxt == "") then lawTxt = "Default laws." end //removing this breaks everything

  local txtWidth, txtHeight = surface.GetTextSize( lawTxt )

  draw.RoundedBox( 0, x * 0.76, y * 0.02, 455, txtHeight + 35, Color( 0, 0, 0, 128 ) )
  draw.DrawText( "Laws", "open_sans_25b", x * 0.766, y * 0.02, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )

//I'm not sure if all three of the following draws are necessary
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, Color(0, 0, 0, 170), 0)
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, Color(0, 0, 0, 100), 0)
  draw.DrawNonParsedText(lawTxt, "open_sans_19b", x * 0.766, y * 0.043, colour.white, 0)
end

function lawBoxToggle() //toggles the law box for users
  if(showLawBox)
  then
    hook.Add( "HUDPaint", "HUDPaint_LawBox", DrawLawBox)
  else
    hook.Remove( "HUDPaint", "HUDPaint_LawBox" )
  end
end

net.Receive("LawsToggle",function()
  showLawBox = !showLawBox //make the boolean value opposite of original value
  lawBoxToggle()
end)

hook.Add( "HUDPaint", "HUDPaint_LawBox", DrawLawBox)
