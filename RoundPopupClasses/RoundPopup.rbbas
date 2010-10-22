#tag Class
Protected Class RoundPopup
Inherits Canvas
	#tag Event
		Function MouseDown(X As Integer, Y As Integer) As Boolean
		  dim result as HCMenu
		  dim oldSelectedItem as integer = self.menu.selectedItem
		  
		  dim ret as boolean = MouseDown(X, Y)
		  
		  if enabled and active then
		    clicked = true
		    self.refresh
		    result = menu.Open(self.window.left + self.left + 1, self.window.top + self.top, self.window)
		    if result <> nil then
		      if oldSelectedItem <> result.selectedItem then
		        self.UpdateMenuMark()
		        self.mText = self.menu.Items(self.menu.selectedItem).Text
		        Change
		      end if
		    end if
		    return true
		  end if
		  
		  return ret
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseEnter()
		  
		  if enabled and active then
		    roll = true
		    if not clicked then
		      self.refresh
		    end if
		  end if
		  
		  MouseEnter
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  
		  if enabled and active then
		    roll = false
		    if not clicked then
		      self.refresh
		    end if
		  end if
		  
		  MouseExit
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(X As Integer, Y As Integer)
		  
		  if enabled and active then
		    clicked = false
		    if not isInside(X,Y) then
		      roll = false
		    end if
		    self.refresh
		  end if
		  
		  MouseUp X, Y
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  self.inited = true
		  
		  Open()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics)
		  if self.width < 33 then
		    self.width = 33
		  end if
		  
		  if enabled and active then
		    if clicked then
		      g.drawPicture popClickLeftPict, 0, 0
		      g.drawPicture popClickMidPict, 14, 0, g.width-32, g.height, 0, 0, 10, 19
		      g.drawPicture popClickRightPict, g.width-18, 0
		    else
		      if roll then
		        g.drawPicture popRollLeftPict, 0, 0
		        g.drawPicture popRollMidPict, 14, 0, g.width-32, g.height, 0, 0, 10, 19
		        g.drawPicture popRollRightPict, g.width-18, 0
		      else
		        g.drawPicture popNormLeftPict, 0, 0
		        g.drawPicture popNormMidPict, 14, 0, g.width-32, g.height, 0, 0, 10, 19
		        g.drawPicture popNormRightPict, g.width-18, 0
		      end if
		    end if
		  else
		    g.drawPicture popNormLeftPict, 0, 0
		    g.drawPicture popNormMidPict, 14, 0, g.width-32, g.height, 0, 0, 10, 19
		    g.drawPicture popInactRightPict, g.width-18, 0
		  end if
		  
		  g.TextFont = "System"
		  g.TextSize = 12
		  if not enabled or not active then
		    g.ForeColor = &C808080
		  end if
		  g.drawString self.mText, 14, g.textAscent+1, g.width-32, true
		  
		  Paint g
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddRow(Item as string)
		  self.menu.addItem Item
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddRows(Items() as string)
		  dim Item as string
		  
		  for each Item in Items
		    self.menu.addItem Item
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddSeparator()
		  self.menu.addItem "-"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.RectControl
		  
		  self.InitGraphics
		  
		  self.menu = new HCMenu
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteAllRows()
		  redim self.menu.Items(-1)
		  redim self.menu.HArray(-1)
		  self.menu.selectedItem = -1
		  mText = ""
		  self.refresh
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub InitGraphics()
		  if not graphicsInited then
		    popNormLeftPict.mask.graphics.drawPicture popNormLeftMask, 0, 0
		    popNormMidPict.mask.graphics.drawPicture popNormMidMask, 0, 0
		    popNormRightPict.mask.graphics.drawPicture popNormRightMask, 0, 0
		    
		    popRollLeftPict.mask.graphics.drawPicture popRollLeftMask, 0, 0
		    popRollMidPict.mask.graphics.drawPicture popRollMidMask, 0, 0
		    popRollRightPict.mask.graphics.drawPicture popRollRightMask, 0, 0
		    
		    popClickLeftPict.mask.graphics.drawPicture popClickLeftMask, 0, 0
		    popClickMidPict.mask.graphics.drawPicture popClickMidMask, 0, 0
		    popClickRightPict.mask.graphics.drawPicture popClickRightMask, 0, 0
		    
		    popInactRightPict.mask.graphics.drawPicture popInactRightMask, 0, 0
		    
		    graphicsInited = true
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InsertRow(RowNumber as integer, Item as string)
		  if RowNumber > Ubound(self.menu.Items)+1 then
		    self.menu.InsertItem Item, Ubound(self.menu.Items)+1
		  else
		    self.menu.InsertItem Item, RowNumber
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function isInside(X as integer, Y as integer) As Boolean
		  if X>= 0 and X <= me.width then
		    if Y>= 0 and Y <= me.height then
		      return true
		    end if
		  end if
		  return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function List(Index as integer) As string
		  return self.menu.Items(Index).Text
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ListCount() As Integer
		  return ubound(self.menu.Items)+1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveRow(Index as integer)
		  self.menu.Items.remove(Index)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RowTag(Index as integer) As Variant
		  return self.menu.Items(Index).UserData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RowTag(Index as integer, assigns Value as Variant)
		  self.menu.Items(Index).UserData = Value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Text() As string
		  return self.mText
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateMenuMark()
		  dim i as integer
		  
		  for i = 0 to ubound(self.menu.items)
		    if i = self.menu.selectedItem then
		      self.menu.items(i).checked = true
		    else
		      self.menu.items(i).checked = false
		    end if
		  next
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Change()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseDown(X As Integer, Y As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseEnter()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseExit()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseUp(X As Integer, Y As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Paint(g As Graphics)
	#tag EndHook


	#tag Note, Name = Info
		
		RoundPopup
		REALbasic custom control to handle a round popup menu
		
		Copyright (c)2008-2010, Massimo Valle
		All rights reserved.
		
		this class make use of HierPop classes which are
		Copyright by Noah Desch <http://www.wireframesoftware.com/>
		
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:
		- Redistributions of source code must retain the above copyright notice,
		this list of conditions and the following disclaimer.
		- Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation and/or
		other materials provided with the distribution.
		- Neither the name of the author nor the names of its contributors may be used to
		endorse or promote products derived from this software without specific prior written permission.
		
		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
		IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
		IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
		OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#tag EndNote


	#tag Property, Flags = &h21
		Private clicked As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared graphicsInited As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private inited As boolean = false
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Setter
			Set
			  if not inited then
			    self.addRows split(value, endOfLine)
			  end if
			End Set
		#tag EndSetter
		InitialValue As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return self.menu.selectedItem
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  dim oldSelectedItem as integer = self.menu.selectedItem
			  
			  if value > ubound(self.menu.Items) then
			    self.menu.selectedItem = ubound(self.menu.Items)
			  elseif value < -1 then
			    self.menu.selectedItem = -1
			  else
			    self.menu.selectedItem = value
			  end if
			  
			  if not inited then
			    self.UpdateMenuMark()
			    if self.menu.selectedItem > -1 then
			      self.mText = self.menu.Items(self.menu.selectedItem).Text
			    end if
			  else
			    if oldSelectedItem <> self.menu.selectedItem then
			      self.UpdateMenuMark()
			      if self.menu.selectedItem > -1 then
			        self.mText = self.menu.Items(self.menu.selectedItem).Text
			      else
			        self.mText = ""
			      end if
			      self.refresh
			      Change
			    end if
			  end if
			End Set
		#tag EndSetter
		ListIndex As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		menu As HCMenu
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInitialValue As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mText As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private roll As boolean
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AcceptFocus"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptTabs"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="19"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Group="Behavior"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialValue"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ListIndex"
			Visible=true
			Group="Appearance"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			InheritedFrom="Canvas"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			InheritedFrom="Canvas"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
