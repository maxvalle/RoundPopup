#tag Class
Protected Class ConItem
	#tag Method, Flags = &h0
		Sub Constructor()
		  Enabled = true
		  Mark = chr(&h12)
		  Visible = True
		  FontColor = textColor
		  IconEnabled = true
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Text As String)
		  Constructor()
		  Me.Text = Text
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawInto(G As Graphics, X As Integer, Y As Integer, TextSize As Integer, DrawMark As Boolean, DrawEnabled As Boolean)
		  Dim ItemIcon As Picture
		  Dim MarkWidth As Integer
		  Dim AltColor As Color
		  
		  G.textFont = "System"
		  G.TextSize = TextSize
		  G.ForeColor = TextColor
		  MarkWidth = G.StringWidth(Mark)+5
		  
		  If DrawEnabled then
		    AltColor = FontColor
		  else
		    AltColor = rgb(FontColor.Red+120,FontColor.Green+120,FontColor.Blue+120)
		  End if
		  
		  If IconID>256 and TargetMacOS then
		    
		    #IF TargetMacOS
		      ItemIcon = App.resourceFork.getCicn(IconID)
		      
		      If DrawMark then
		        If Checked then
		          G.DrawString Mark,X,G.Height/1.4+Y
		        end if
		        
		        #IF TargetMacOS
		          G.DrawPicture ItemIcon,X+MarkWidth,(G.Height/2)-(ItemIcon.Height/2)+Y
		        #ENDIF
		        G.ForeColor = AltColor
		        G.TextFont = Font
		        G.Bold = InStr(Style,"bold")>0
		        G.Italic = InStr(Style,"italic")>0
		        G.Underline = InStr(Style,"underline")>0
		        G.DrawString Text, ItemIcon.width+5+MarkWidth+X, G.Height/1.4+Y
		        
		      else
		        G.ForeColor = AltColor
		        G.TextFont = Font
		        G.Bold = InStr(Style,"bold")>0
		        G.Italic = InStr(Style,"italic")>0
		        G.Underline = InStr(Style,"underline")>0
		        
		        G.DrawPicture ItemIcon,X,(G.Height/2)-(ItemIcon.Height/2)+Y
		        G.DrawString Text, ItemIcon.width+5+X, G.Height/1.4+Y
		      End if
		    #ENDIF
		    
		  else
		    if DrawMark then
		      If Checked then
		        G.DrawString Mark,X,G.Height/1.4+Y
		      end if
		      
		      G.ForeColor = AltColor
		      G.TextFont = Font
		      G.Bold = InStr(Style,"bold")>0
		      G.Italic = InStr(Style,"italic")>0
		      G.Underline = InStr(Style,"underline")>0
		      G.DrawString Text, MarkWidth+X, G.Height/1.4+Y
		      
		    else
		      G.ForeColor = AltColor
		      G.TextFont = Font
		      G.Bold = InStr(Style,"bold")>0
		      G.Italic = InStr(Style,"italic")>0
		      G.Underline = InStr(Style,"underline")>0
		      
		      G.DrawString Text, X, G.Height/1.4+Y
		    End if
		  End if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Setup(Menu As Integer, Num As Integer, byref LI As Integer, Tree() As HCMenu, UseHelp As Boolean, BaseMenu As Integer)
		  Dim BLI As Integer
		  
		  BLI = LI
		  
		  #IF TargetCarbon and not TargetMachO
		    SetupCarbon( Menu, Num, BLI, Tree, UseHelp )
		  #ELSEIF TargetMachO
		    SetupMachO( Menu, Num, BLI, Tree, UseHelp )
		  #ELSEIF TargetWin32
		    SetupWin32( Menu, Num, BLI, Tree, UseHelp, BaseMenu )
		  #ELSEIF TargetMacOSClassic
		    SetupMacOS( Menu, Num, BLI, Tree, UseHelp )
		  #ENDIF
		  
		  LI = BLI
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetupCarbon(Menu As Integer, Num As Integer, byref LI As Integer, Tree() As HCMenu, UseHelp As Boolean)
		  #pragma DisableBackgroundTasks
		  #IF TargetCarbon and not TargetMachO
		    
		    dim err, i, UB, stylsize As Integer
		    dim fnt, Clr, styl, col as memoryBlock
		    dim BLI As Integer
		    dim FText As String
		    
		    Declare Sub SetMenuItemText Lib "CarbonLib" (theMenu as Integer, item as Short, itemString as PString)
		    Declare Function AppendMenuItemText Lib "CarbonLib" (menu as Integer, inString as PString) as Integer
		    Declare Sub CheckItem Lib "CarbonLib" alias "CheckMenuItem" (theMenu as Integer, item as Short, checked as Boolean)
		    Declare Sub SetItemMark Lib "CarbonLib" (theMenu as Integer, item as Short, markChar as Integer)
		    Declare Sub DisableMenuItem Lib "CarbonLib" (theMenu as Integer, item as Short)
		    Declare Function SetMenuItemHierarchicalID Lib "CarbonLib" (inMenu as Integer, inItem as Short, inHierID as Short) as Short
		    Declare Sub SetItemIcon Lib "CarbonLib" (theMenu as Integer, item as Short, iconIndex as Short)
		    Declare Function SetMenuItemFontID Lib "CarbonLib" (inMenu as Integer, inItem as Short, inFontID as Short) as Short
		    Declare Sub GetFNum lib "CarbonLib" (fname as pstring, id as ptr)
		    Declare Sub SetMCEntries Lib "CarbonLib" (num as integer, menuCTbl as ptr)
		    Declare Sub SetItemStyle Lib "CarbonLib" (theMenu as Integer, item as Short, chStyle as ptr)
		    
		    Declare Sub EnableMenuItemIcon Lib "CarbonLib" (theMenu as Integer, item as integer)
		    Declare Sub DisableMenuItemIcon Lib "CarbonLib" (theMenu as Integer, item as integer)
		    Declare Function SetMenuItemIndent Lib "CarbonLib" (inMenu as Integer, inItem as integer, inIndent as Integer) as Integer
		    Declare Function SetMenuItemIconHandle Lib "CarbonLib" (inMenu as Integer, inItem as Short, inIconType as Short, inIconHandle as Integer) as Short
		    Declare Function ChangeMenuItemAttributes Lib "CarbonLib" (menu as Integer, item as short, setTheseAttributes as integer, clearTheseAttributes as integer) as Integer
		    
		    BLI = LI
		    
		    If Visible then
		      If Len(Text)=0 then
		        FText = " "
		      else
		        FText = Text.ConvertEncoding( Encodings.SystemDefault )
		        'FText = text
		      End if
		      
		      if Not InhibitNewItem then
		        err = AppendMenuItemText( Menu, FText ) // Add new menu item
		      else
		        InhibitNewItem = false
		        SetMenuItemText Menu, Num, FText
		      end if
		      
		      err = SetMenuItemIndent(Menu, Num, IndentLevel)
		      If Checked then // Checked
		        CheckItem Menu, Num, Checked
		        SetItemMark Menu, Num, asc(Mark.ConvertEncoding( Encodings.SystemDefault ))
		      End if
		      If IconID<>0 then // PPC Icon
		        Select Case IConType
		        case 0 // cicn resID
		          SetItemIcon Menu, Num, IconID-256
		        case 1 // IconRef
		          err = SetMenuItemIconHandle(Menu, Num, 6, IconID)
		        end Select
		      End if
		      
		      // Style    // <-- CONVERTED
		      If InStr(Style,"bold")>0 then
		        StylSize = StylSize+1
		      End if
		      If InStr(Style,"italic")>0 then
		        StylSize = StylSize+2
		      End if
		      If InStr(Style,"underline")>0 then
		        StylSize = StylSize+4
		      End if
		      If InStr(Style,"outline")>0 then
		        StylSize = StylSize+8
		      End if
		      If InStr(Style,"shadow")>0 then
		        StylSize = StylSize+16
		      End if
		      If StylSize>0 then
		        Styl = NewMemoryBlock(4)
		        Styl.byte(3) = StylSize
		        SetItemStyle Menu, Num, Styl.Ptr(0)
		      End if
		      
		      If Not Me.Enabled then // Enabled
		        DisableMenuItem Menu, Num
		      End if
		      If Not IconEnabled and IconID<>0 then // Icon Enabled
		        DisableMenuItemIcon Menu, Num
		      else
		        EnableMenuItemIcon Menu, Num
		      end if
		      
		      If Font<>"" and Font<>"system" then // font
		        fnt=newmemoryBlock(2)
		        getfnum Font, fnt
		        err = SetMenuItemFontID( Menu, Num, fnt.Short(0) )
		      End if
		      
		      If Me.Hierarchical and HierMenu<>Nil then
		        HierMenu.BuildHierOrder(BLI ) // Make the submenu
		        
		        // Append the HierMenus to the search list
		        UB=Ubound(HierMenu.HArray)
		        for i = 0 to UB
		          Tree.Append HierMenu.HArray(i)
		        next
		        Redim HierMenu.HArray(-1)
		        
		        err = SetMenuItemHierarchicalID( Menu, Num, HierMenu.LastMenu ) // Attach the submenu
		        
		        
		        If HierSelectable then
		          err = ChangeMenuItemAttributes(Menu,Num, 4, 0)
		        end if
		      End if
		      
		      // Color    // <-- CONVERTED
		      'If FontColor.Red<>TextColor.Red or FontColor.Green<>TextColor.Green or FontColor.Blue<>TextColor.Blue then
		      'Clr =NewMemoryBlock(30)
		      'Clr.short(0) = BLI // menu ID
		      'If BLI=1000 and UseHelp then //item number
		      'Clr.short(2) = Num+2 // account for help item and separator
		      'else
		      'Clr.short(2) = Num
		      'End if
		      'Clr.uShort(10) = FontColor.Red*257 // text color
		      'Clr.uShort(12) = FontColor.Green*257
		      'Clr.uShort(14) = FontColor.Blue*257
		      'SetMCEntries 1,Clr
		      'End if
		      
		    End if
		    
		    LI = BLI
		  #ENDIF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetupMachO(Menu As Integer, Num As Integer, byref LI As Integer, Tree() As HCMenu, UseHelp As Boolean)
		  #pragma DisableBackgroundTasks
		  #IF TargetMachO
		    
		    dim err, i, UB, stylsize As Integer
		    dim fnt, Clr, styl, col as memoryBlock
		    dim BLI As Integer
		    dim FText As String
		    
		    Declare Sub SetMenuItemText Lib "Carbon" (theMenu as Integer, item as Short, itemString as PString)
		    Declare Function AppendMenuItemText Lib "Carbon" (menu as Integer, inString as PString) as Integer
		    Declare Sub CheckItem Lib "Carbon" alias "CheckMenuItem" (theMenu as Integer, item as Short, checked as Boolean)
		    Declare Sub SetItemMark Lib "Carbon" (theMenu as Integer, item as Short, markChar as Integer)
		    Declare Sub DisableMenuItem Lib "Carbon" (theMenu as Integer, item as Short)
		    Declare Function SetMenuItemHierarchicalID Lib "Carbon" (inMenu as Integer, inItem as Short, inHierID as Short) as Short
		    Declare Sub SetItemIcon Lib "Carbon" (theMenu as Integer, item as Short, iconIndex as Short)
		    Declare Function SetMenuItemFontID Lib "Carbon" (inMenu as Integer, inItem as Short, inFontID as Short) as Short
		    Declare Sub GetFNum lib "Carbon" (fname as pstring, id as ptr)
		    Declare Sub SetMCEntries Lib "Carbon" (num as integer, menuCTbl as ptr)
		    Declare Sub SetItemStyle Lib "Carbon" (theMenu as Integer, item as Short, chStyle as ptr)
		    
		    Declare Sub EnableMenuItemIcon Lib "Carbon" (theMenu as Integer, item as integer)
		    Declare Sub DisableMenuItemIcon Lib "Carbon" (theMenu as Integer, item as integer)
		    Declare Function SetMenuItemIndent Lib "Carbon" (inMenu as Integer, inItem as integer, inIndent as Integer) as Integer
		    Declare Function SetMenuItemIconHandle Lib "Carbon" (inMenu as Integer, inItem as Short, inIconType as Short, inIconHandle as Integer) as Short
		    Declare Function ChangeMenuItemAttributes Lib "Carbon" (menu as Integer, item as short, setTheseAttributes as integer, clearTheseAttributes as integer) as Integer
		    
		    BLI = LI
		    
		    If Visible then
		      If Len(Text)=0 then
		        FText = " "
		      else
		        FText = Text.ConvertEncoding( Encodings.SystemDefault )
		        'FText = text
		      End if
		      
		      if Not InhibitNewItem then
		        err = AppendMenuItemText( Menu, FText ) // Add new menu item
		      else
		        InhibitNewItem = false
		        SetMenuItemText Menu, Num, FText
		      end if
		      
		      err = SetMenuItemIndent(Menu, Num, IndentLevel)
		      If Checked then // Checked
		        CheckItem Menu, Num, Checked
		        SetItemMark Menu, Num, asc(Mark.ConvertEncoding( Encodings.SystemDefault ))
		      End if
		      If IconID<>0 then // PPC Icon
		        Select Case IConType
		        case 0 // cicn resID
		          SetItemIcon Menu, Num, IconID-256
		        case 1 // IconRef
		          err = SetMenuItemIconHandle(Menu, Num, 6, IconID)
		        end Select
		      End if
		      
		      // Style    // <-- CONVERTED
		      If InStr(Style,"bold")>0 then
		        StylSize = StylSize+1
		      End if
		      If InStr(Style,"italic")>0 then
		        StylSize = StylSize+2
		      End if
		      If InStr(Style,"underline")>0 then
		        StylSize = StylSize+4
		      End if
		      If InStr(Style,"outline")>0 then
		        StylSize = StylSize+8
		      End if
		      If InStr(Style,"shadow")>0 then
		        StylSize = StylSize+16
		      End if
		      If StylSize>0 then
		        Styl = NewMemoryBlock(4)
		        #if TargetX86
		          Styl.littleEndian = false
		        #endif
		        Styl.byte(3) = StylSize
		        SetItemStyle Menu, Num, Styl.Ptr(0)
		      End if
		      
		      If Not Me.Enabled then // Enabled
		        DisableMenuItem Menu, Num
		      End if
		      If Not IconEnabled and IconID<>0 then // Icon Enabled
		        DisableMenuItemIcon Menu, Num
		      else
		        EnableMenuItemIcon Menu, Num
		      end if
		      
		      If Font<>"" and Font<>"system" then // font
		        fnt=newmemoryBlock(2)
		        getfnum Font, fnt
		        err = SetMenuItemFontID( Menu, Num, fnt.Short(0) )
		      End if
		      
		      If Me.Hierarchical and HierMenu<>Nil then
		        HierMenu.BuildHierOrder(BLI ) // Make the submenu
		        
		        // Append the HierMenus to the search list
		        UB=Ubound(HierMenu.HArray)
		        for i = 0 to UB
		          Tree.Append HierMenu.HArray(i)
		        next
		        Redim HierMenu.HArray(-1)
		        
		        err = SetMenuItemHierarchicalID( Menu, Num, HierMenu.LastMenu ) // Attach the submenu
		        
		        
		        If HierSelectable then
		          err = ChangeMenuItemAttributes(Menu,Num, 4, 0)
		        end if
		      End if
		      
		      // Color    // <-- CONVERTED
		      'If FontColor.Red<>TextColor.Red or FontColor.Green<>TextColor.Green or FontColor.Blue<>TextColor.Blue then
		      'Clr =NewMemoryBlock(30)
		      'Clr.short(0) = BLI // menu ID
		      'If BLI=1000 and UseHelp then //item number
		      'Clr.short(2) = Num+2 // account for help item and separator
		      'else
		      'Clr.short(2) = Num
		      'End if
		      'Clr.uShort(10) = FontColor.Red*257 // text color
		      'Clr.uShort(12) = FontColor.Green*257
		      'Clr.uShort(14) = FontColor.Blue*257
		      'SetMCEntries 1,Clr
		      'End if
		      
		    End if
		    
		    LI = BLI
		  #ENDIF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetupMacOS(Menu As Integer, Num As Integer, byref LI As Integer, Tree() As HCMenu, UseHelp As Boolean)
		  #pragma DisableBackgroundTasks
		  #IF TargetMacOSClassic
		    #IF not TargetCarbon and not TargetMachO
		      
		      dim err, i, UB, stylsize As Integer
		      dim fnt, Clr, styl, col as memoryBlock
		      dim BLI As Integer
		      dim FText As String
		      
		      #IF Target68k
		        dim AppendText As String
		      #ENDIF
		      
		      #IF TargetPPC // ppc classic
		        Declare Function AppendMenuItemText Lib "MenusLib" (menu as Integer, inString as PString) as Integer
		        Declare Sub DisableMenuItem Lib "MenusLib" (theMenu as Integer, item as Short)
		      #ELSE // 68k classic
		        #IF Target68k
		          Declare Sub AppendMenuItemText Lib "InterfaceLib" alias "MacAppendMenu" (menu as Integer, data as PString) Inline68K("A933")
		          Declare Sub DisableMenuItem Lib "InterfaceLib" alias "DisableItem" (theMenu as Integer, item as Short) Inline68K("A93A")
		        #ENDIF
		      #ENDIF
		      
		      // fat classic
		      Declare Sub SetMenuItemText Lib "InterfaceLib" (theMenu as Integer, item as Short, itemString as PString) Inline68K("A947")
		      Declare Sub CheckItem Lib "InterfaceLib" (theMenu as Integer, item as Short, checked as Boolean) Inline68K("A945")
		      Declare Sub SetItemMark Lib "InterfaceLib" (theMenu as Integer, item as Short, markChar as Integer) Inline68K("A944")
		      Declare Function SetMenuItemHierarchicalID Lib "AppearanceLib" (inMenu as Integer, inItem as Short, inHierID as Short) as Short Inline68K("303C040DA825")
		      Declare Sub SetItemIcon Lib "InterfaceLib" (theMenu as Integer, item as Short, iconIndex as Short) Inline68K("A940")
		      Declare Function SetMenuItemFontID Lib "AppearanceLib" (inMenu as Integer, inItem as Short, inFontID as Short) as Short Inline68K("303C040FA825")
		      Declare Sub GetFNum lib "InterfaceLib" (fname as pstring, id as ptr) Inline68K("A900")
		      Declare Sub SetMCEntries Lib "InterfaceLib" (numEntries as Short, menuCEntries as Ptr) Inline68K("AA65")
		      Declare Sub SetItemStyle Lib "InterfaceLib" (theMenu as Integer, item as Short, chStyle as ptr) Inline68K("A942")
		      
		      Declare Sub DisableMenuItemIcon Lib "MenusLib" (theMenu as Integer, item as integer) Inline68K("303C0020A825")
		      Declare Sub EnableMenuItemIcon Lib "MenusLib" (theMenu as Integer, item as integer) Inline68K("303C0019A825")
		      Declare Function SetMenuItemIconHandle Lib "AppearanceLib" (inMenu as Integer, inItem as Short, inIconType as Short, inIconHandle as Integer) as Short Inline68K("303C0606A825")
		      
		      BLI = LI
		      
		      If Visible then
		        If Len(Text)=0 then
		          FText = " "
		        else
		          FText = text
		        End if
		        
		        #IF Target68k // account for 68k menu properties in the AppendMenu call
		          AppendText = " "
		          if checked and Not (Hierarchical and HierMenu<>Nil) then // 68k checked
		            AppendText = AppendText+"!"+Mark
		          end if
		          ub = countFields(Style," ") // 68k style
		          for i = 1 to UB
		            AppendText = AppendText+"<"+Uppercase(Left(NthField(Style," ",i),1))
		          next
		          
		          If IconID<>0 then // 68k Icon
		            if IConType = 0 then // cicn resID
		              AppendText = AppendText+"^"+hex(IconID)
		            end if
		          End if
		          
		          If Not InhibitNewItem then
		            AppendMenuItemText Menu, AppendText
		            SetMenuItemText Menu, Num, FText // account for metacharacters that may be in menu text
		          else
		            SetMenuItemText Menu, Num, FText
		            CheckItem Menu, Num, checked and Not (Hierarchical and HierMenu<>Nil)
		            InHibitNewItem = false
		          end if
		          If IconID<>0 and IconType=1 then
		            err = SetMenuItemIconHandle(Menu, Num, 6, IconID) // 68k IconRef
		          end if
		          
		        #ELSE // PPC Menu Setup
		          
		          If Not InhibitNewItem then
		            AppendMenuItemText Menu, FText  // Add new menu item
		          else
		            SetMenuItemText Menu, Num, FText
		            InhibitNewItem = false
		          end if
		          If Checked then // Checked
		            CheckItem Menu, Num, Checked
		            SetItemMark Menu, Num, asc(Mark)
		          End if
		          
		          If IconID<>0 then // PPC Icon
		            Select Case IConType
		            case 0 // cicn resID
		              SetItemIcon Menu, Num, IconID-256
		            case 1 // IconRef
		              err = SetMenuItemIconHandle(Menu, Num, 6, IconID)
		            end Select
		          End if
		          
		          // Style    // <-- CONVERTED
		          if Lenb( Style ) > 0 then
		            If InStr(Style,"bold")>0 then
		              StylSize = StylSize+1
		            End if
		            If InStr(Style,"italic")>0 then
		              StylSize = StylSize+2
		            End if
		            If InStr(Style,"underline")>0 then
		              StylSize = StylSize+4
		            End if
		            If InStr(Style,"outline")>0 then
		              StylSize = StylSize+8
		            End if
		            If InStr(Style,"shadow")>0 then
		              StylSize = StylSize+16
		            End if
		            If StylSize>0 then
		              Styl = NewMemoryBlock(4)
		              Styl.byte(3) = StylSize
		              SetItemStyle Menu, Num, Styl.Ptr(0)
		            End if
		          end if
		          
		        #ENDIF // 68k
		        
		        If Not Enabled then // Enabled
		          DisableMenuItem Menu, Num
		        End if
		        If Not IconEnabled and IconID<>0 then // Icon Enabled
		          DisableMenuItemIcon Menu, Num
		        elseif IconID<>0 then
		          EnableMenuItemIcon Menu, Num
		        end if
		        
		        If Font<>"" and Font<>"system" then // font
		          fnt=newmemoryBlock(2)
		          getfnum Font, fnt
		          err = SetMenuItemFontID Menu, Num, fnt.Short(0)
		        End if
		        
		        If Me.Hierarchical and HierMenu<>Nil then
		          HierMenu.BuildHierOrder(BLI ) // Make the submenu
		          
		          // Append the HierMenus to the search list
		          UB=Ubound(HierMenu.HArray)
		          for i = 0 to UB
		            Tree.Append HierMenu.HArray(i)
		          next
		          Redim HierMenu.HArray(-1)
		          If Ubound( HierMenu.Items )=-1 then
		            DisableMenuItem Menu, Num
		          end if
		          
		          err = SetMenuItemHierarchicalID( Menu, Num, HierMenu.LastMenu ) // Attach the submenu
		        End if
		        
		        // Color    // <-- CONVERTED
		        If FontColor.Red<>TextColor.Red or FontColor.Green<>TextColor.Green or FontColor.Blue<>TextColor.Blue then
		          Clr =NewMemoryBlock(30)
		          Clr.short(0) = LI // menu ID
		          If BLI=1000 and UseHelp then //item number
		            Clr.short(2) = Num+2 // account for help item and separator
		          else
		            Clr.short(2) = Num
		          End if
		          Clr.uShort(10) = FontColor.Red*257 // text color
		          Clr.uShort(12) = FontColor.Green*257
		          Clr.uShort(14) = FontColor.Blue*257
		          SetMCEntries 1,Clr
		        End if
		      End if
		      
		      LI = BLI
		      
		    #ENDIF
		  #ENDIF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetupWin32(Menu As Integer, Num As Integer, byref LI As Integer, Tree() As HCMenu, UseHelp As Boolean, BaseMenu As Integer)
		  #pragma DisableBackgroundTasks
		  #IF TargetWin32
		    
		    dim err, i, UB, BLI, Flags, Ident As Integer
		    dim WinResult As Boolean
		    
		    const MF_POPUP=&H00000010
		    const MF_SEPARATOR=&H00000800
		    const MF_GRAYED =&H00000001
		    const MF_DISABLED=&H00000002
		    const MF_CHECKED=&H00000008
		    const MF_BYPOSITION=&H00000400
		    
		    Declare Function AppendMenuA Lib "User32.dll" (Menu as Integer, flags as integer, something as integer, text as CString) As Boolean
		    Declare Function CheckMenuRadioItem Lib "User32.dll" (Menu as Integer, first as integer, last as integer, check as integer, flags as integer) As Boolean
		    
		    
		    BLI = LI
		    
		    If Visible then
		      If Text = "-" then
		        Flags = Flags+MF_SEPARATOR // Separator
		      End if
		      If Not Enabled then
		        Flags = Flags+MF_GRAYED // dissabled
		      End if
		      If Checked then
		        If Mark<>"•" then    // <-- CONVERTED
		          Flags = Flags+MF_CHECKED // standard checkmark
		        end if
		      End if
		      
		      If Me.Hierarchical and HierMenu<>Nil then
		        HierMenu.BuildHierOrder(BLI) // Make the submenu
		        UB=Ubound(HierMenu.HArray)
		        for i = 0 to UB
		          Tree.Append HierMenu.HArray(i)
		        next
		        Redim HierMenu.HArray(-1)
		        
		        Ident = HierMenu.MenuNum
		        Flags = MF_POPUP
		      else
		        Ident = BaseMenu+Num
		      End if
		      
		      WinResult = AppendMenuA(Menu, Flags, ident, Text)
		      
		      If Checked and Mark="•" then    // <-- CONVERTED
		        WinResult = CheckMenuRadioItem(Menu,num-1,num-1,num-1,MF_BYPOSITION)
		      end if
		    End if
		    
		    LI = BLI
		    
		  #ENDIF
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Checked As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Enabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Font As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FontColor As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		Hierarchical As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HierMenu As HCMenu
	#tag EndProperty

	#tag Property, Flags = &h0
		HierSelectable As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IconEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IconID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IconType As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IndentLevel As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		InhibitNewItem As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Mark As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Style As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Text As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UserData As Variant
	#tag EndProperty

	#tag Property, Flags = &h0
		Visible As Boolean
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Checked"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Font"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Hierarchical"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HierSelectable"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconEnabled"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconID"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconType"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IndentLevel"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InhibitNewItem"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Mark"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Style"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Text"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
