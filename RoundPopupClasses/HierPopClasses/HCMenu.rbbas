#tag Class
Protected Class HCMenu
	#tag Method, Flags = &h0
		Sub AddItem(C As ConItem)
		  #pragma DisableBackgroundTasks
		  Items.Append C
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddItem(Title As String)
		  #pragma DisableBackgroundTasks
		  Items.Append New ConItem(Title)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AssertMenuItemProperties(H As HCMenu)
		  #pragma DisableBackgroundTasks
		  Dim i, UB, LI, Skiped, Start As Integer
		  
		  UB = Ubound(H.Items)
		  For i = 0 to UB
		    
		    Redim HArray(-1)
		    HArray.Append Me
		    // populate the menu with the associated items
		    LI = LastMenu
		    
		    // Add the items
		    UB=Ubound(Items)
		    for i = 0 to UB
		      If Items(i).Visible then
		        H.Items(i).InhibitNewItem = true
		        Items(i).Setup( MenuNum, i+1-Skiped+Start, LI, HArray, UseHelp, LastMenu)
		      else
		        Skiped = Skiped+1
		      End if
		    next
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BuildHierOrder(byref LastVal As Integer)
		  #pragma DisableBackgroundTasks
		  dim UB As Integer
		  
		  #IF TargetWin32
		    Const MENU_STEP = 1000
		  #ELSE
		    Const MENU_STEP = 1
		  #ENDIF
		  
		  LastVal = LastVal+MENU_STEP
		  LastMenu = LastVal
		  MakeMe()
		  
		  UB =Ubound(HArray)
		  
		  If UB<>-1 then
		    LastVal = HArray(UB).LastMenu+MENU_STEP
		  End if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Cleanup(UB As Integer)
		  dim i As Integer
		  dim err As Boolean
		  
		  #Pragma DisableBackgroundTasks
		  
		  #if TargetCarbon and not TargetMachO
		    Declare Sub MacDeleteMenu Lib "CarbonLib" alias "DeleteMenu" (menuID as Short)
		    Declare Sub DisposeMenu Lib "CarbonLib" (theMenu as Integer)
		  #ELSEIF TargetMachO
		    Declare Sub MacDeleteMenu Lib "Carbon" alias "DeleteMenu" (menuID as Short)
		    Declare Sub DisposeMenu Lib "Carbon" (theMenu as Integer)
		  #ELSEIF TargetWin32
		    Declare Function DestroyMenu Lib "User32.dll" (menuID as integer) As Boolean
		  #ELSEIF TargetMacOSClassic
		    Declare Sub DisposeMenu Lib "InterfaceLib" (theMenu as Integer) Inline68K("A932")
		    Declare Sub MacDeleteMenu Lib "InterfaceLib" alias "DeleteMenu" (menuID as Short) Inline68K("A936")
		  #ENDIF
		  
		  #IF TargetWin32 // Windows cleanup
		    err = DestroyMenu(MenuNum)
		  #ENDIF
		  
		  for i = 0 to UB
		    #IF TargetMacOS // mac cleanup
		      MacDeleteMenu HArray(i).LastMenu
		      DisposeMenu HArray(i).MenuNum
		    #ENDIF
		    
		    HArray(i).LastMenu = 1000
		    HArray(i).MenuNum = 0
		    HArray(i) = Nil
		  next
		  
		  Redim HArray(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  #pragma DisableBackgroundTasks
		  Redim Items(-1)
		  Redim HArray(-1)
		  Constructor("M")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Title As String)
		  #pragma DisableBackgroundTasks
		  Redim Items(-1)
		  Redim HArray(-1)
		  
		  '#IF TargetCarbon
		  'Declare Function LMGetSysFontSize Lib "CarbonLib" () as Short
		  '#ELSE
		  '#IF TargetMacOS
		  'Declare Function LMGetSysFontSize Lib "InterfaceLib" () as Short Inline68K("3EB80BA8")
		  '#ENDIF
		  '#ENDIF
		  
		  LastMenu = 1000
		  HelpString = "Help"
		  SpaceForMark = true
		  DefaultItem = -1
		  Me.Title = Title
		  
		  '#IF TargetMacOS
		  'FontSize = LMGetSysFontSize()
		  '#ENDIF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertItem(C As ConItem, Index As Integer)
		  #pragma DisableBackgroundTasks
		  Items.Insert Index,C
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertItem(Title As String, Index As Integer)
		  #pragma DisableBackgroundTasks
		  Items.Insert index, New ConItem(Title)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeFontMenu(ActualFont As Boolean)
		  // builds a font menu
		  
		  Dim i, UB As Integer
		  Dim C As ConItem
		  Dim F As String
		  
		  UB = FontCount-1
		  Redim Items(UB)
		  for i = 0 to UB
		    F = Font(i)
		    C = New ConItem(F)
		    
		    If ActualFont then
		      C.Font = F
		    end if
		    
		    Items(i) = C
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub MakeMe()
		  #pragma DisableBackgroundTasks
		  
		  // Makes the menu
		  Dim i, UB, Skiped, Start, err As Integer
		  Dim LI As Integer
		  
		  #IF TargetCarbon and not TargetMachO
		    Dim FCount As MemoryBlock
		    Declare Function NewMenu Lib "CarbonLib" (menuID as Short, menuTitle as PString) as Integer
		    Declare Sub InsertMenu Lib "CarbonLib" (theMenu as Integer, beforeID as Short)
		    Declare Function SetMenuExcludesMarkColumn Lib "CarbonLib" (menu as Integer, excludesMark as Boolean) as Integer
		    Declare Function SetMenuFont Lib "CarbonLib" (menu as Integer, FontID As short, fontSize As short) As Short
		  #ELSEIF TargetMachO
		    Dim FCount As MemoryBlock
		    Declare Function NewMenu Lib "Carbon" (menuID as Short, menuTitle as PString) as Integer
		    Declare Sub InsertMenu Lib "Carbon" (theMenu as Integer, beforeID as Short)
		    Declare Function SetMenuExcludesMarkColumn Lib "Carbon" (menu as Integer, excludesMark as Boolean) as Integer
		    Declare Function SetMenuFont Lib "Carbon" (menu as Integer, FontID As short, fontSize As short) As Short
		  #ELSEIF TargetWin32
		    Dim Winerr As Boolean
		    Declare Function CreatePopupMenu Lib "User32.dll" () As Integer
		    Declare Function AppendMenuA Lib "User32.dll" (Menu as Integer, flags as integer, something as integer, text as CString) As Boolean
		  #ELSEIF TargetMacOS
		    Declare Function NewMenu Lib "InterfaceLib" (menuID as Short, menuTitle as PString) as Integer Inline68K("A931")
		    Declare Sub InsertMenu Lib "InterfaceLib" (theMenu as Integer, beforeID as Short) Inline68K("A935")
		    #IF TargetMacOSClassic
		      Declare Function SetMenuExcludesMarkColumn Lib "MenusLib" (menu as Integer, excludesMark as Boolean) as Integer
		      Declare Function SetMenuFont Lib "MenusLib" (menu as Integer, FontID As short, fontSize As short) As Short
		    #ENDIF
		  #ENDIF
		  
		  Redim HArray(-1)
		  HArray.Append Me
		  
		  // Create a new menu at the toolbox level
		  #IF TargetMacOS
		    MenuNum = NewMenu( LastMenu, "M" )
		    InsertMenu MenuNum, -1
		    
		    #IF TargetMacOSClassic
		      If not SpaceForMark then
		        err = SetMenuExcludesMarkColumn(MenuNum,true)
		      end if
		      err = SetMenuFont(MenuNum,0,FontSize)
		    #ENDIF
		    
		    #IF TargetCarbon or TargetMachO
		      If not SpaceForMark then
		        err = SetMenuExcludesMarkColumn(MenuNum,true)
		      end if
		      err = SetMenuFont(MenuNum,0,FontSize)
		    #ENDIF
		  #ENDIF // MacOS
		  
		  #IF TargetWin32
		    MenuNum = CreatePopupMenu()
		    If UseHelp and LastMenu = 1000 then // windows does not automatically add help items
		      WinErr = AppendMenuA(MenuNum,0,1000,HelpString)
		      WinErr = AppendMenuA(MenuNum,&H00000800,1001,"-")
		      Start = 2
		    End if
		  #ENDIF
		  
		  // populate the menu with the associated items
		  LI = LastMenu
		  
		  // Add the items
		  UB=Ubound(Items)
		  for i = 0 to UB
		    If Items(i).Visible then
		      Items(i).Setup( MenuNum, i+1-Skiped+Start, LI, HArray, UseHelp, LastMenu)
		    else
		      Skiped = Skiped+1
		    End if
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeMenuFromResource(ResID As Integer)
		  #pragma DisableBackgroundTasks
		  
		  // builds a menu from a menu resource
		  
		  #IF TargetMacOS
		    
		    Dim Data As String
		    Dim Menu As MemoryBlock
		    Dim Enabled As Integer
		    Dim Pos As Integer
		    
		    Dim C As ConItem
		    Dim H As HCMenu
		    
		    Data = App.ResourceFork.GetResource( "MENU", ResID )
		    if Data = "" then
		      Redim Items(-1)
		      Return
		    end if
		    
		    Menu = NewMemoryBlock( Lenb(Data) )
		    Menu.StringValue( 0, Menu.Size ) = Data
		    
		    Title = Menu.PString( 14 )
		    Pos = Menu.Byte( 14 ) + 15
		    
		    While Pos + 5 < Menu.Size
		      C = New ConItem( Menu.PString(Pos) )
		      Pos = Pos + Menu.Byte( Pos ) + 1
		      C.IconID = Menu.Byte( Pos ) + 256
		      Pos = Pos+1
		      
		      if Menu.Byte( Pos ) = &H1B then
		        C.Hierarchical = true
		        H = New HCMenu
		        H.MakeMenuFromResource( Menu.Byte( Pos+1 ) )
		        C.HierMenu = H
		      end if
		      
		      Pos = Pos + 3
		      Items.Append C
		    wend
		    
		  #ENDIF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub OffsetToVisible(H As HCMenu)
		  #pragma DisableBackgroundTasks
		  
		  // Finds the actual item in the array (accounts for the difference between the number returned by
		  // the toolbox and invisible items which may be in between)
		  
		  dim i, UB As Integer
		  UB = Ubound(H.Items)
		  
		  for i = 0 to UB
		    if not H.Items(i).Visible then
		      H.SelectedItem = H.SelectedItem+1
		    end if
		    If H.SelectedItem = i then
		      exit
		    End if
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Open(X As Integer, Y As Integer) As HCMenu
		  #pragma DisableBackgroundTasks
		  return Open(X,Y,Nil)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Open(X As Integer, Y As Integer, W As Window) As HCMenu
		  #pragma DisableBackgroundTasks
		  Dim H As HCMenu
		  
		  // A window reference (W) must be passed for the win32 version to display a menu
		  Dim i, UB, Skiped As Integer
		  
		  // Make the menu
		  MakeMe()
		  
		  // Display menu and get result
		  H = ShowMenu(X,Y, W)
		  
		  // release extra menu references
		  Cleanup( Ubound(HArray) )
		  
		  If H<>Nil then
		    If H.SelectedItem=-1 then
		      return H
		    elseif H.Items(H.SelectedItem).Enabled then
		      return H
		    end if
		  End if
		  
		  return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetAllEnabled(Enabled As Boolean)
		  #pragma DisableBackgroundTasks
		  Dim i, UB As Integer
		  UB = Ubound(Items)
		  for i = 0 to UB
		    Items(i).Enabled = Enabled
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShowMenu(X As Integer, Y As Integer, W As Window) As HCMenu
		  Dim i, UB, err, SizeTemp, MenuWidth, MenuHeight, MyX, MyY As Integer
		  Dim MnuID, SType, Out As MemoryBlock
		  Dim Pt, AEDescBlock, MenuRef As MemoryBlock
		  Dim Clr As MemoryBlock
		  
		  'struct MenuInfo {
		  'MenuID              menuID;                 /* in Carbon use Get/SetMenuID*/
		  'short               menuWidth;              /* in Carbon use Get/SetMenuWidth*/
		  'short               menuHeight;             /* in Carbon use Get/SetMenuHeight*/
		  'Handle              menuProc;               /* not supported in Carbon*/
		  'long                enableFlags;            /* in Carbon use Enable/DisableMenuItem, IsMenuItemEnable*/
		  'Str255              menuData;               /* in Carbon use Get/SetMenuTitle*/
		  '};
		  
		  #if TargetCarbon and not TargetMachO
		    Declare Function GetMenuHeight Lib "CarbonLib" (menu as Integer) as Short
		    Declare Function GetMenuWidth Lib "CarbonLib" (menu as Integer) as Short
		    Declare Function ContextualMenuSelect Lib "CarbonLib" (inMenu as Integer, inGlobalLocation as Ptr, inReserved as Boolean, inHelpType as Integer, inHelpItemString as PString, inSelection as Ptr, outUserSelectionType as Ptr, outMenuID as Ptr, outMenuItem as Ptr) as Integer
		    Declare Function PopUpMenuSelect Lib "CarbonLib" (menu as Integer, top as Short, left as Short, popUpItem as Short) as Integer
		    Declare Sub CalcMenuSize Lib "CarbonLib" (menu as Integer)
		    Declare Function SetMenuFont Lib "CarbonLib" (menu as Integer, FontID As short, fontSize As short) As Short
		  #ELSEIF TargetMachO
		    Declare Function GetMenuHeight Lib "Carbon" (menu as Integer) as Short
		    Declare Function GetMenuWidth Lib "Carbon" (menu as Integer) as Short
		    Declare Function ContextualMenuSelect Lib "Carbon" (inMenu as Integer, inGlobalLocation as Ptr, inReserved as Boolean, inHelpType as Integer, inHelpItemString as PString, inSelection as Ptr, outUserSelectionType as Ptr, outMenuID as Ptr, outMenuItem as Ptr) as Integer
		    Declare Function PopUpMenuSelect Lib "Carbon" (menu as Integer, top as Short, left as Short, popUpItem as Short) as Integer
		    Declare Sub CalcMenuSize Lib "Carbon" (menu as Integer)
		    Declare Function SetMenuFont Lib "Carbon" (menu as Integer, FontID As short, fontSize As short) As Short
		  #ELSEIF TargetWin32
		    Dim Winerr As Boolean
		    Dim WinResult As Integer
		    Dim WinStr As String
		    Dim WinFlags As Integer
		    
		    const MF_BYPOSITION=&H00000400
		    const TPM_LEFTALIGN=&h0000
		    const TPM_RIGHTALIGN=&h0008
		    const TPM_TOPALIGN=&h0000
		    const TPM_BOTTOMALIGN=&h0020
		    
		    Declare Function TrackPopupMenuEx Lib "User32.dll" (inMenu as Integer, flags as integer, xPos as integer, yPos as integer, window as integer, overlap as integer) As Integer
		    Declare Function SetMenuDefaultItem Lib "User32.dll" (inMenu as Integer, Item as integer, ByPos as integer) As Boolean
		  #ELSEIF TargetMacOSClassic
		    Declare Function PopUpMenuSelect Lib "InterfaceLib" (menu as Integer, top as Short, left as Short, popUpItem as Short) as Integer Inline68K("A80B")
		    Declare Function ContextualMenuSelect Lib "ContextualMenu" (inMenu as Integer, inGlobalLocation as Ptr, inReserved as Boolean, inHelpType as Integer, inHelpItemString as PString, inSelection as Ptr, outUserSelectionType as Ptr, outMenuID as Ptr, outMenuItem as Ptr) as Integer Inline68K("7003AA72")
		    Declare Sub CalcMenuSize Lib "InterfaceLib" (theMenu as Integer) Inline68K("A948")
		    Declare Function SetMenuFont Lib "MenusLib" (menu as Integer, FontID As short, fontSize As short) As Short
		  #ENDIF
		  
		  // Prepare to get the result
		  SType = NewMemoryBlock(4)
		  #if TargetMacOS and TargetX86
		    SType.littleEndian = false
		  #endif
		  MnuID = NewMemoryBlock(2)
		  Out = NewMemoryBlock(2)
		  AEDescBlock = NewMemoryBlock(8)
		  
		  
		  #IF TargetMacOS
		    
		    // Setup the point
		    Pt = NewMemoryBlock(4)
		    Pt.Short(0)=Y
		    Pt.Short(2)=X
		    CalcMenuSize MenuNum
		    
		    // get menu dimensions
		    #if TargetCarbon or TargetMachO
		      MenuWidth = GetMenuWidth(MenuNum)
		      MenuHeight = GetMenuHeight(MenuNum)
		    #else
		      MenuRef = NewMemoryBlock(4)
		      MenuRef.Long(0) = MenuNum
		      MenuRef = MenuRef.Ptr(0).Ptr(0)
		      MenuWidth = MenuRef.Short(2)
		      MenuHeight = MenuRef.Short(4)
		    #endif
		    
		  #ENDIF
		  
		  // handle menu placement
		  #IF TargetMacOS
		    Select Case MousePlacement
		    case 1
		      Pt.Short(2) = Pt.Short(2)-MenuWidth
		    case 2
		      Pt.Short(0) = Pt.Short(0)-MenuHeight
		    case 3
		      Pt.Short(2) = Pt.Short(2)-MenuWidth
		      Pt.Short(0) = Pt.Short(0)-MenuHeight
		    end Select
		    MyX = Pt.Short(2)
		    MyY = Pt.Short(0)
		  #ELSE
		    // win32 mouseplacement
		    Select Case MousePlacement
		    case 1
		      Winflags = TPM_RIGHTALIGN
		    case 2
		      Winflags = TPM_BOTTOMALIGN
		    case 3
		      Winflags = WinFlags+ TPM_BOTTOMALIGN
		      Winflags = WinFlags+ TPM_RIGHTALIGN
		    end Select
		  #ENDIF
		  
		  
		  #IF TargetMacOS // MacOS menu    // <-- CONVERTED
		    If UseHelp then
		      // show menu with help item
		      err = ContextualMenuSelect( MenuNum, Pt.Ptr(0), false, 2, HelpString, AEDescBlock, SType, MnuID, Out)
		    else
		      // show menu without help item
		      SelectedItem = SelectedItem+1
		      Stype.Long(0) = PopUpMenuSelect( MenuNum, MyY, MyX, SelectedItem )
		      SelectedItem = SelectedItem-1
		      MnuID.Short(0) = Stype.Short(0)
		      Out.Short(0) = Stype.Short(2)
		      If MnuID.short(0)=0 then
		        Stype.Long(0) = 0
		      else
		        Stype.Long(0) = 1
		      End if
		    End if
		  #ELSE // Win32 menu  // <-- CONVERTED
		    
		    If DefaultItem<>-1 then // display selected item under mouse
		      Winerr = SetMenuDefaultItem(MenuNum,SelectedItem,MF_BYPOSITION)
		    end if
		    WinResult = TrackPopupMenuEX(MenuNum,&h0100+&h0080+Winflags,X,Y,W.WinHWND,0)
		    WinStr = Str( WinResult )
		    
		    MnuID.Short(0) = val( Left(WinStr,Len(WinStr)-3) )*1000
		    Out.Short(0) = val( Right(WinStr,3) )
		    
		    If MnuID.short(0)=0 then
		      Stype.Long(0) = 0 // no selection
		    else
		      If MnuID.Short(0)=1000 and UseHelp and LastMenu=1000 and Out.Short(0) = 0 then
		        SType.Long(0) = 3 // help chosen
		      else
		        Stype.Long(0) = 1 // regular item
		        if MnuID.Short(0)=1000 and UseHelp and LastMenu=1000 then
		          Out.Short(0) = Out.Short(0)-2 // offset for help item
		        end if
		      End if
		    End if
		    
		  #ENDIF
		  
		  
		  // Return the result
		  UB = Ubound(HArray)
		  Select Case SType.Long(0)
		  case 1
		    // Format the result
		    for i = 0 to UB
		      If HArray(i).LastMenu = MnuID.Short(0) then
		        HArray(i).SelectedItem = Out.Short(0)-1
		        err = i
		        exit
		      End if
		    next
		    
		    OffsetToVisible(HArray(err))
		    return HArray(err)
		  case 3 // Help was chosen
		    SelectedItem = -1
		    return Me
		  else // no selection
		    return Nil
		  End Select
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		DefaultItem As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		FontSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		HArray(0) As HCMenu
	#tag EndProperty

	#tag Property, Flags = &h0
		HelpString As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Items(0) As ConItem
	#tag EndProperty

	#tag Property, Flags = &h0
		LastMenu As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MenuNum As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MousePlacement As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		SelectedItem As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		SpaceForMark As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UseHelp As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		UserData As Variant
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="DefaultItem"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontSize"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpString"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastMenu"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuNum"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MousePlacement"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectedItem"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SpaceForMark"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
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
			Name="UseHelp"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
