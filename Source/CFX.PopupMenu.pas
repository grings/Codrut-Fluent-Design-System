unit CFX.PopupMenu;

interface

uses
  SysUtils,
  Winapi.Windows,
  Classes,
  Types,
  UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Threading,
  System.Generics.Collections,
  Vcl.Menus,
  CFX.Graphics,
  CFX.VarHelpers,
  Vcl.Forms,
  DateUtils,
  IOUtils,
  CFX.Utilities,
  CFX.ThemeManager,
  CFX.BlurMaterial,
  CFX.Classes,
  CFX.UIConsts,
  CFX.Colors,
  CFX.Math,
  CFX.GDI,
  CFX.Linker,
  CFX.Animations,
  CFX.Types;

  type
    // Class
    FXPopupItem = class;

    // Menu
    FXPopupItems = class(TMPersistent)
    private
      FItems: TArray<FXPopupItem>;

      function GetItem(AIndex: Integer): FXPopupItem;

    protected
      // Serialization
      procedure DefineProperties(Filer: TFiler); override;
      procedure ReadData(Stream: TStream);
      procedure WriteData(Stream: TStream);

    public
      // Constructors
      constructor Create(AOwner: TPersistent); override;
      destructor Destroy; override;

      // Items
      property Item[AIndex: Integer]: FXPopupItem read GetItem; default;

      function Count: integer;
      function IndexOf(AText: string): integer;
      procedure Add(AItem: FXPopupItem);
      procedure Delete(Index: integer; AndFree: boolean = true);

      procedure Clear(AndFree: boolean = true);
    end;

    // Popup Container
    FXPopupContainer = class({TPopupMenu}FXComponent)
    private
      FText: string;
      FHint: string;

      FChecked: Boolean;
      FEnabled: Boolean;
      FDefault: Boolean;
      FRadioItem: Boolean;
      FVisible: Boolean;

      FImage: FXIconSelect;
      FItems: FXPopupItems;

      FShortCut: string;

      FOnClick: TNotifyEvent;
      FOnHover: TNotifyEvent;

      FAutoCheck: Boolean;

      FBounds: TRect;

      function HasSubItems: boolean;
      procedure SetChecked(const Value: boolean);
      function GetMenuItem(Index: Integer): FXPopupContainer;
      function GetIndex: integer;

    published
      property Text: string read FText write FText;
      property Hint: string read FHint write FHint;

      property Enabled: boolean read FEnabled write FEnabled default True;
      property Checked: boolean read FChecked write SetChecked default False;
      property AutoCheck: boolean read FAutoCheck write FAutoCheck default False;
      property RadioItem: boolean read FRadioItem write FRadioItem default False;

      property IsDefault: boolean read FDefault write FDefault default False;
      property Visible: boolean read FVisible write FVisible default True;

      property Image: FXIconSelect read FImage write FImage;

      // Useless
      property Items: FXPopupItems read FItems write FItems;

      property Shortcut: string read FShortcut write FShortcut;

      property OnClick: TNotifyEvent read FOnClick write FOnClick;
      property OnHover: TNotifyEvent read FOnHover write FOnHover;

      property MenuIndex: integer read GetIndex;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Items
      property MenuItems[Index: Integer]: FXPopupContainer read GetMenuItem;

      function GetMenuItemCount: integer;
      function IsSeparator: boolean;

      // Stream Conversion
      procedure SaveToStream(AStream: TStream);
      procedure LoadFromStream(AStream: TStream);
    end;

    FXPopupItem = class(FXPopupContainer, FXControl)
    private
      // Animation
      FAnim: TIntAni;
      FAnimType: FXAnimateSelection;

      // Size and Position
      NormalHeight,
      NormalWidth: integer;

      FDropPoint: TPoint;

      // Form
      FForm: TForm;

      FGlassBlur: FXBlurMaterial;

      FCustomColors: FXColorSets;
      FDrawColors: FXColorSet;

      // Settings
      FItemPressed: boolean;
      FHoverOver: integer;

      FFlatMenu: boolean;
      FEnableRadius: boolean;
      FEnableBorder: boolean;

      procedure Animation;

      procedure SetHover(Index: integer);

      function IsOpen: boolean;
      function GetParentPopupMenu: FXPopupItem;

      procedure GlassUp(Sender: TObject; Button: TMouseButton;
                        Shift: TShiftState; X, Y: Integer);
      procedure GlassDown(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
      procedure GlassEnter(Sender: TObject);
      procedure GlassMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

      procedure FormPosition;
      procedure CloseMenu(FreeMem: boolean = false);
      procedure CloseAllWindows;

      procedure OpenItem(MenuIndex: integer);
      procedure ExecuteItem(MenuIndex: integer);
      function GetOpenChildIndex: integer;
      function HasChildOpen: boolean;
      procedure CloseChildWindow;

      function IndexIsValid(Index: integer): boolean;

      procedure FormLoseFocus(Sender: TObject);
      procedure FormKeyPress(ender: TObject; var Key: Word; Shift: TShiftState);

      procedure FormOnShow(Sender: TObject);
      procedure OnPaintControl(Sender: TObject);

      procedure PopupAtPointS(Point: TPoint);

    published
      property CustomColors: FXColorSets read FCustomColors write FCustomColors;

      property AnimationType: FXAnimateSelection read FAnimType write FAnimType default FXAnimateSelection.Linear;

      property FlatMenu: boolean read FFlatMenu write FFlatMenu default false;
      property EnableBorder: boolean read FEnableBorder write FEnableBorder default true;
      property EnableRadius: boolean read FEnableRadius write FEnableRadius default true;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Interface
      function IsContainer: Boolean;
      procedure UpdateTheme(const UpdateChildren: Boolean);

      function Background: TColor;
    end;

    // Popup Menu
    FXPopupMenu = class(FXPopupItem, FXControl)
    private
      FOnPopup: TNotifyEvent;
      FCloseOnInteract,
      FCloseOnExecute: boolean;

    published
      property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;

      property CloseOnInteract: boolean read FCloseOnInteract write FCloseOnInteract default false;
      property CloseOnExecute: boolean read FCloseOnExecute write FCloseOnExecute default true;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // TPopupMenu Inherited
      procedure Popup(X, Y: integer); //override;

      // Custom Implementations
      procedure PopupAtCursor;
      procedure PopupAtPoint(Point: TPoint);
    end;

implementation

{ FXPopupContainer }

constructor FXPopupContainer.Create(AOwner: TComponent);
begin
  inherited;
  FImage := FXIconSelect.Create(Self);
  FItems := FXPopupItems.Create(Self);

  Enabled := true;

  AutoCheck := false;
  Checked := false;
  RadioItem := false;
  Visible := true;

  Text := Name;
end;

destructor FXPopupContainer.Destroy;
begin
  FreeAndNil(FImage);
  inherited;
end;

function FXPopupContainer.GetIndex: integer;
var
  I: Integer;
begin
  Result := -1;

  if Owner is FXPopupContainer then
    for I := 0 to FXPopupContainer(Owner).GetMenuItemCount - 1 do
      if FXPopupContainer(Owner).MenuItems[I] = Self then
        Exit(I);
end;

function FXPopupContainer.GetMenuItem(Index: Integer): FXPopupContainer;
begin
  Result := Items.Item[Index]
end;

function FXPopupContainer.GetMenuItemCount: integer;
begin
  Result := Items.Count;
end;

function FXPopupContainer.HasSubItems: boolean;
begin
  Result := GetMenuItemCount <> 0;
end;

function FXPopupContainer.IsSeparator: boolean;
begin
  Result := Text = '-';
end;

procedure FXPopupContainer.LoadFromStream(AStream: TStream);
var
  Reader: TReader;
begin
  Reader := TReader.Create(AStream, 4096);
  try
    Reader.ReadSignature;
    // The FLoaded refrence need to be initialised
    Reader.BeginReferences;
    Reader.ReadComponent(Self);
  finally
    Reader.Free;
  end;
end;

procedure FXPopupContainer.SaveToStream(AStream: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(AStream, 4096);
  try
    Writer.WriteSignature;
    Writer.WriteComponent(Self);
  finally
    Writer.Free;
  end;
end;

procedure FXPopupContainer.SetChecked(const Value: boolean);
var
  I: integer;
begin
  FChecked := Value;

  if RadioItem then
    if Owner is FXPopupContainer then
      begin
        with FXPopupContainer(Owner) do
          for I := Self.MenuIndex - 1 downto 0 do
            begin
              if (not MenuItems[I].RadioItem) then
                Break;

              MenuItems[I].FChecked := false;
            end;

        with FXPopupContainer(Owner) do
          for I := Self.MenuIndex + 1 to GetMenuItemCount - 1 do
            begin
              if (not MenuItems[I].RadioItem) then
                Break;

              MenuItems[I].FChecked := false;
            end;
      end;
end;

{ FXPopupMenu }

constructor FXPopupMenu.Create(AOwner: TComponent);
begin
  inherited;
  // Properties
  FAnimType := FXAnimateSelection.Linear;

  CloseOnInteract := false;
  CloseOnExecute := true;

  // Update Children (children not required)
  UpdateTheme(false);
end;

destructor FXPopupMenu.Destroy;
begin

  inherited;
end;

procedure FXPopupMenu.Popup(X, Y: integer);
begin
  inherited;
  PopupAtPoint(Point(X, Y));
end;

procedure FXPopupMenu.PopupAtCursor;
begin
  PopupAtPoint( Mouse.CursorPos );
end;

procedure FXPopupMenu.PopupAtPoint(Point: TPoint);
begin
  inherited;
  PopupAtPointS( Point );

  // Notify Event
  if Assigned(OnPopup) then
    OnPopup( Self );
end;

{ FXPopupItem }

procedure FXPopupItem.Animation;
var
  LinearUpwards: boolean;
begin
  // Anim
  FAnim := TIntAni.Create;

  // Settings
  FAnim.AniKind := akIn;
  FAnim.AniFunctionKind := afkQuadratic;

  FAnim.Duration := 50;

  with FForm do
    begin
      // Prepare
      case FAnimType of
        FXAnimateSelection.Instant: begin
          AlphaBlendValue := 255;
          Height := NormalHeight;
          Width := NormalWidth;
        end;
        FXAnimateSelection.Opacity: begin
          Height := NormalHeight;
          Width := NormalWidth;

          FAnim.StartValue := 0;
          FAnim.DeltaValue := 255;
        end;
        FXAnimateSelection.Linear: begin
          AlphaBlendValue := 255;
          Width := NormalWidth;

          LinearUpwards := FDropPoint.Y > Top;

          FAnim.StartValue := NormalHeight - POPUP_ANIMATE_SIZE;
          FAnim.DeltaValue := POPUP_ANIMATE_SIZE;
        end;
        FXAnimateSelection.Square: begin
          AlphaBlendValue := 255;

          LinearUpwards := FDropPoint.Y > Top;

          FAnim.StartValue := NormalHeight - POPUP_ANIMATE_SIZE;
          FAnim.DeltaValue := POPUP_ANIMATE_SIZE;
        end;
      end;

      // Sync
      FAnim.OnSync := procedure(Value: integer)
      begin
        case FAnimType of
          FXAnimateSelection.Opacity: AlphaBlendValue := Value;
          FXAnimateSelection.Linear: begin
            Height := Value;

            if LinearUpwards then
              begin
                Top := FDropPoint.Y - Value;
              end;
          end;
          FXAnimateSelection.Square: begin
            Height := Value;
            Width := trunc(Value / FAnim.EndValue * (NormalWidth - POPUP_ANIMATE_X_SIZE)) + POPUP_ANIMATE_X_SIZE;

            if LinearUpwards then
              begin
                Top := FDropPoint.Y - Value;
              end;
          end;
        end;
      end;
    end;

  // Start
  FAnim.Start;
end;

function FXPopupItem.Background: TColor;
begin
  Result := FDrawColors.Background;
end;

procedure FXPopupItem.CloseAllWindows;
var
  I: Integer;
begin
  CloseMenu(true);

  for I := 0 to GetMenuItemCount - 1 do
    FXPopupItem(MenuItems[I]).CloseAllWindows;
end;

procedure FXPopupItem.CloseChildWindow;
var
  Index: integer;
begin
  Index := GetOpenChildIndex;

  if Index <> -1 then
    FXPopupItem(MenuItems[Index]).CloseMenu;
end;

procedure FXPopupItem.CloseMenu(FreeMem: boolean);
begin
  if IsOpen then
    FForm.Close;

  if FreeMem and (FForm <> nil) then
    begin
      FForm.Free;
      FForm := nil;
    end;
end;

constructor FXPopupItem.Create(AOwner: TComponent);
begin
  inherited;
  FCustomColors := FXColorSets.Create(False);
  FDrawColors := FXColorSet.Create;
  FEnableBorder := true;
  FEnableRadius := true;
  FFlatMenu := false;

  if (AOwner is FXPopupMenu) then
    begin
      FAnimType := (AOwner as FXPopupMenu).FAnimType;
      FCustomColors.Assign((AOwner as FXPopupMenu).CustomColors);
    end;
end;

destructor FXPopupItem.Destroy;
begin

  inherited;
end;

procedure FXPopupItem.ExecuteItem(MenuIndex: integer);
var
  Item: FXPopupItem;
begin
  Item := FXPopupItem(MenuItems[MenuIndex]);

  // Execute
  if (not Item.HasSubItems) and Assigned( Item.OnClick ) then
    begin
      if FXPopupMenu(GetParentPopupMenu).CloseOnExecute then
        CloseAllWindows;

      Item.OnClick(Item);
    end;
end;

procedure FXPopupItem.FormKeyPress(ender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Direction, NewPos: integer;
  Valid: boolean;
begin
  case Key of
    27: CloseMenu;

    37: if not (Self is FXPopupMenu) then
      CloseMenu();

    39: if IndexIsValid(FHoverOver) then
      OpenItem(FHoverOver);

    13, 32: if IndexIsValid(FHoverOver) then
      ExecuteItem(FHoverOver);

    38, 40: begin
      // Up/Down
      if Key = 38 then
        Direction := -1
      else
        Direction := 1;

      // Add Value
      NewPos := FHoverOver;
      repeat
        Inc(NewPos, Direction);

        Valid := IndexIsValid(NewPos);
      until (not Valid) or (Valid and not MenuItems[NewPos].IsSeparator);

      if Valid then
        FHoverOver := NewPos;

      FGlassBlur.Repaint;
    end;
  end;
end;

procedure FXPopupItem.FormLoseFocus(Sender: TObject);
begin
  if not HasChildOpen then
    if Self is FXPopupMenu then
      CloseAllWindows
    else
      begin
        // Moved back in the menu
        CloseMenu;

        // Entire Menu Lost Focus
        if Self.Owner is FXPopupItem then
          if FXPopupItem(Self.Owner).IsOpen then
            FXPopupItem(Self.Owner).FForm.SetFocus;
      end;
end;

procedure FXPopupItem.FormOnShow(Sender: TObject);
begin
  // Position
  FForm.Left := FDropPoint.X;
  FForm.Top := FDropPoint.Y;

  FormPosition;

  // Animate
  Animation;
end;

procedure FXPopupItem.FormPosition;
var
  AHeight, AWidth: integer;
begin
  // Get Supposed values
  AHeight := NormalHeight;
  AWidth := NormalWidth;

  // Left
  with FForm do
    begin
      Left := FDropPoint.X;
      Top := FDropPoint.Y;

      // Set Position
      if Left < Screen.DesktopRect.Left then
        Left := Screen.DesktopRect.Left;
      if Top < Screen.DesktopRect.Top then
        Top := Screen.DesktopRect.Top;

      OutputDebugString( PChar(FForm.Left.ToString) );
      if Left + AWidth > Screen.DesktopRect.Right then
        Left := Mouse.CursorPos.X - AWidth;
      OutputDebugString( PChar(FForm.Left.ToString) );

      if Top + AHeight > Screen.DesktopRect.Bottom then
        Top := Mouse.CursorPos.Y - AHeight;
    end;
end;

function FXPopupItem.GetOpenChildIndex: integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to GetMenuItemCount - 1 do
    if FXPopupItem(MenuItems[I]).IsOpen then
      Exit(I);
end;

function FXPopupItem.GetParentPopupMenu: FXPopupItem;
begin
  Result := Self;

  while not (Result is FXPopupMenu) do
    begin
      Result := FXPopupItem(Result.Owner);
    end;

  if not (Result is FXPopupMenu) then
    Result := nil;
end;

procedure FXPopupItem.GlassDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FItemPressed := true;
  SetHover(FHoverOver);
end;

procedure FXPopupItem.GlassEnter(Sender: TObject);
begin
  FItemPressed := false;
  SetHover(FHoverOver);
end;

procedure FXPopupItem.GlassMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  I, FHoverPrevious: Integer;
  Hover: boolean;
  Item: FXPopupItem;
begin
  // Previous
  FHoverPrevious := FHoverOver;

  // Search
  Hover := false;
  for I := 0 to GetMenuItemCount - 1 do
    if MenuItems[I] is FXPopupItem then
      begin
        if MenuItems[I].FBounds.Contains(Point(X,Y)) and MenuItems[I].Enabled then
          begin
            SetHover(I);

            Hover := true;

            Break;
          end;
      end;

  /// None Found
  if not Hover then
    SetHover(-1);

  // Notify
  if (FHoverOver <> -1) and (FHoverOver <> FHoverPrevious) then
    begin
      Item := FXPopupItem(MenuItems[FHoverOver]);

      // Close windows if exists
      CloseChildWindow;;

      // Hover
      if Assigned( Item.OnHover ) then
        Item.OnHover(Item);

      // Extend
      if Item.HasSubItems and not Item.IsOpen then
        OpenItem( FHoverOver );
    end;
end;

procedure FXPopupItem.GlassUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Item: FXPopupItem;
begin
  FItemPressed := false;
  SetHover(FHoverOver);

  // Notify
  if IndexIsValid(FHoverOver) then
    begin
      Item := FXPopupItem(MenuItems[FHoverOver]);

      if Item.AutoCheck then
        if (not Item.RadioItem) xor (Item.RadioItem and not Item.Checked) then
          begin
            Item.Checked := not Item.Checked;

            if FXPopupMenu(GetParentPopupMenu).CloseOnInteract then
              CloseAllWindows;
          end;

      // Execute
      ExecuteItem(FHoverOver);

      // Re-Open
      if Item.HasSubItems and not Item.IsOpen then
        OpenItem( FHoverOver );

    end;
end;

function FXPopupItem.HasChildOpen: boolean;
begin
  Result := GetOpenChildIndex <> -1;
end;

function FXPopupItem.IndexIsValid(Index: integer): boolean;
begin
  Result := (Index > -1) and (Index < GetMenuItemCount);
end;

function FXPopupItem.IsContainer: Boolean;
begin
  Result := true;
end;

function FXPopupItem.IsOpen: boolean;
begin
  Result := (FForm <> nil) and FForm.Visible;
end;

procedure FXPopupItem.OnPaintControl(Sender: TObject);
var
  I, X, ActualX, Y, BiggestWidth: integer;
  R: TRect;
  Text: string;
  XPress: boolean;

  B: TGDIBrush;
  TextDrawFlags: TTextFormat;
  LineColor: TColor;
  LineOpacity: integer;

  RoundR: TRoundRect;

  // Raise
  AnyHasIcon,
  AnyCanBeChecked: boolean;
begin
  with FGlassBlur.GetCanvas do
    begin
      FForm.Font.Color := FDrawColors.ForeGround;

      Pen.Color := FDrawColors.ForeGround;
      Brush.Color := FDrawColors.ForeGround;
      Font.Color := FDrawColors.ForeGround;

      // Initiate Variabiles
      Y := POPUP_SPACING_TOPBOTTOM;
      BiggestWidth := 0;

      LineColor := Pen.Color;

      XPress := FItemPressed;

      // Invert for Dark Mode
      if ThemeManager.DarkTheme then
        XPress := not XPress;

      // Selected
      if XPress then
        LineOpacity := 40
      else
        LineOpacity := 20;

      // Brush
      B := GetRGB( Font.Color, LineOpacity ).MakeGDIBrush;

      // Text Output
      TextDrawFlags := [tfSingleLine, tfCenter, tfVerticalCenter];

      // Default Round
      RoundR.SetRoundness( POPUP_SELECTION_ROUND );

      // Get Status
      AnyHasIcon := false;
      AnyCanBeChecked := false;

      for I := 0 to GetMenuItemCount - 1 do
        if MenuItems[I].Image.Enabled then
          begin
            AnyHasIcon := true;
            Break;
          end;

      for I := 0 to GetMenuItemCount - 1 do
        if not MenuItems[I].HasSubItems and (MenuItems[I].AutoCheck or MenuItems[I].RadioItem or MenuItems[I].Checked) then
          begin
            AnyCanBeChecked := true;
            Break;
          end;

      // Draw
      for I := 0 to GetMenuItemCount - 1 do
        begin
          // Hidden
          if not MenuItems[I].Visible then
            Continue;

          // Analise
          if not MenuItems[I].IsSeparator then
            begin
              X := POPUP_ITEM_SPACINT;

              Brush.Style := bsClear;

              // Highlight Item
              if I = FHoverOver then
                begin
                  RoundR.Rect := Rect(POPUP_LINE_SPACING, Y + POPUP_FRACTION_SPACE, FForm.Width - POPUP_LINE_SPACING, Y + POPUP_ITEM_HEIGHT - POPUP_FRACTION_SPACE);
                  GDIRoundRect(RoundR, B, nil);
                end;

              // Checkmark / Radio
              if not MenuItems[I].HasSubItems and (MenuItems[I].AutoCheck or MenuItems[I].Checked or MenuItems[I].RadioItem) then
                begin
                  R := Rect( X, Y, X + POPUP_ITEM_SPACINT, Y + POPUP_ITEM_HEIGHT );

                  if MenuItems[I].Checked then
                    begin
                      if MenuItems[I].RadioItem then
                        Text := POPUP_RADIO
                      else
                        Text := POPUP_CHECKMARK;

                      Font.Assign( FForm.Font );
                      Font.Name := ThemeManager.IconFont;
                      if not MenuItems[I].Enabled then
                        Font.Color := POPUP_TEXT_DISABLED;

                      Font.Height :=  GetMaxFontHeight(FGlassBlur.GetCanvas, Text, R.Width, R.Height);

                      TextRect(R, Text, TextDrawFlags);
                    end;
                end;


              if AnyCanBeChecked then
                X := X + POPUP_ITEM_HEIGHT;

              // Icon
              with MenuItems[I].Image do
                if Enabled then
                  begin
                    Font.Assign( FForm.Font );
                    if not MenuItems[I].Enabled then
                      Font.Color := POPUP_TEXT_DISABLED;

                    R := Rect( X, Y, X + POPUP_ITEM_SPACINT, Y + POPUP_ITEM_HEIGHT );
                    DrawIcon(FGlassBlur.GetCanvas, R);
                  end;

              if MenuItems[I].Image.Enabled or (AnyHasIcon and not AnyCanBeChecked) then
                X := X + POPUP_ITEM_HEIGHT;

              // Text
              Text := MenuItems[I].Text;

              if MenuItems[I].IsDefault then
                Font.Style := [fsBold];

              Font.Assign( FForm.Font );

              if not MenuItems[I].Enabled then
                Font.Color := POPUP_TEXT_DISABLED;

              R := Rect(X, Y, X + TextWidth( Text ), Y + POPUP_ITEM_HEIGHT);

              TextRect( R, Text, TextDrawFlags);

              X := X + TextWidth(Text) + POPUP_ITEM_SPACINT;

              // Shortcut
              if (MenuItems[I].ShortCut <> '') and (not MenuItems[I].HasSubItems) then
                begin
                  ActualX := X;
                  Text := MenuItems[I].Shortcut;

                  Font.Assign( FForm.Font );
                  Font.Size := round( Font.Size * 2.5 / 3 );

                  if not MenuItems[I].Enabled then
                    Font.Color := POPUP_TEXT_DISABLED;

                  X := FForm.Width - POPUP_ITEM_SPACINT - TextWidth(Text);

                  R := Rect(X, Y, X + TextWidth( Text ), Y + POPUP_ITEM_HEIGHT);

                  TextRect( R, Text, TextDrawFlags);

                  X := ActualX;
                  X := X + TextWidth(Text) + POPUP_ITEM_SPACINT;
                end;

              // Sub Items
              if MenuItems[I].HasSubItems then
                begin
                  ActualX := X;
                  Text := #$E76C;

                  Font.Assign( FForm.Font );

                  Font.Name := ThemeManager.IconFont;
                  Font.Size := round( Font.Size * 2.8 / 3 );

                  X := FForm.Width - POPUP_ITEM_SPACINT - TextWidth(Text);

                  R := Rect(X, Y, X + TextWidth( Text ), Y + POPUP_ITEM_HEIGHT);

                  TextRect( R, Text, TextDrawFlags);

                  X := ActualX;
                  X := X + TextWidth(Text) + POPUP_ITEM_SPACINT;
                end;

              // Width
              if X > BiggestWidth then
                NormalWidth := X;

              if NormalWidth < POPUP_MINIMUM_WIDTH then
                NormalWidth := POPUP_MINIMUM_WIDTH;

              // Bounds
              with MenuItems[I].FBounds do
                begin
                  TopLeft.X := POPUP_LINE_SPACING;
                  TopLeft.y := Y;

                  BottomRight.X := NormalWidth - BiggestWidth;
                  BottomRight.Y := Y + POPUP_ITEM_HEIGHT;
                end;

              // Next
              Y := Y + POPUP_ITEM_HEIGHT;
            end
          else
            begin
              X := POPUP_LINE_SPACING;

              Brush.Style := bsSolid;

              R := Rect(X, Y, FForm.Width - X, Y + POPUP_SEPARATOR_HEIGHT);

              //Rectangle( R );
              GDITint( R, LineColor, 100 );

              // Next
              Y := Y + POPUP_SEPARATOR_HEIGHT;
            end;
        end;

      // End
      Y := Y + POPUP_SPACING_TOPBOTTOM;

      // Resize
      if (FForm.Height <> Y) and ((FAnim = nil) or FAnim.Finished) then
        FForm.Height := Y;

      // Data
      NormalHeight := Y;


      // Final Border
      Pen.Width := 1;
      if FEnableRadius then
        for I := 0 to POPUP_MENU_ROUND - 1 do
          begin
            if I = POPUP_MENU_ROUND - 1 then
              begin
                if FEnableBorder then
                  Pen.Color := FDrawColors.Accent
                else
                  Break;
              end
            else
              Pen.Color := FORM_COMPOSITE_COLOR;
            RoundRect(ClipRect, I, I);
          end;
    end;
end;

procedure FXPopupItem.OpenItem(MenuIndex: integer);
var
  Item: FXPopupItem;
begin
  // Get Item
  Item := FXPopupItem(MenuItems[MenuIndex]);

  // Clone Settings
  Item.FEnableRadius := FEnableRadius;
  Item.FEnableBorder := FEnableBorder;

  // Can be ran
  if not Item.HasSubItems then
    Exit;

  // Update Theme
  Item.UpdateTheme(false);

  // Open
  Item.PopupAtPointS(Point(FForm.Left + FForm.Width - POPUP_ITEMS_OVERLAY_DISTANCE, FGlassBlur.ClientToScreen(Point(0, Item.FBounds.Top)).Y ));
end;

procedure FXPopupItem.PopupAtPointS(Point: TPoint);
begin
  FDropPoint := Point;

  // Create
  if FForm = nil then
    begin
      FForm := TForm.Create(Self);

      with FForm do
        begin
          // Parent
          if Self is FXPopupMenu then
            Parent := TControl(Self).Parent
          else
            Parent := TControl(FXPopupItem(Self).GetParentPopupMenu).Parent;

          // Prepare Form
          Position := poDesigned;
          AlphaBlend := true;
          Caption := POPUP_CAPTION_DEFAULT;

          DoubleBuffered := true;

          BorderStyle := bsNone;

          TransparentColor := true;
          TransparentColorValue := FORM_COMPOSITE_COLOR;

          FormStyle := fsStayOnTop;

          Font.Name := ThemeManager.FormFont;
          Font.Height := ThemeManager.FormFontHeight;

          OnShow := FormOnShow;
          OnDeactivate := FormLoseFocus;
          OnKeyDown := FormKeyPress;

          // Math
          NormalHeight := 0;
          NormalWidth := 0;

          Width := POPUP_MINIMUM_WIDTH;

          // Create Blur
          FGlassBlur := FXBlurMaterial.Create( FForm );
          with FGlassBlur do
            begin
              Parent := FForm;
              Align := alClient;

              FGlassBlur.Version := FXBlurVersion.Screenshot;
              if GetParentPopupMenu.FFlatMenu then
                FGlassBlur.Version := FXBlurVersion.None;

              FGlassBlur.CustomColors.Assign( GetParentPopupMenu.CustomColors );
              FGlassBlur.UpdateTheme(false);

              RefreshMode := FXGlassRefreshMode.Manual;
            end;

          // Form-Create
          with FGlassBlur do
            begin
              OnPaint := OnPaintControl;

              OnMouseUp := GlassUp;
              OnMouseDown := GlassDown;
              OnMouseMove := GlassMove;
              OnMouseEnter := GlassEnter;

              SyncroniseImage;
              OnPaint(FGlassBlur);
            end;
        end;
    end;

  // Show
  FForm.Show;
end;

procedure FXPopupItem.SetHover(Index: integer);
begin
  FHoverOver := Index;

  FGlassBlur.ReDraw;
end;

procedure FXPopupItem.UpdateTheme(const UpdateChildren: Boolean);
var
  I: integer;
begin
  // Inherit from parent
  if Self.Owner is FXPopupItem  then
    begin
      FAnimType := FXPopupItem(Self.Owner).FAnimType;
      FDrawColors := FXPopupItem(Self.Owner).FDrawColors;
    end
      else
        // Color
        if CustomColors.Enabled then
          begin
            FDrawColors := FXColorSet.Create( CustomColors, ThemeManager.DarkTheme );

            // Update Glass Blur
            if FGlassBlur <> nil then
              FGlassBlur.CustomColors.Assign( CustomColors );
          end
        else
          begin
            FDrawColors.BackGround := ThemeManager.SystemColor.BackGroundInterior;
            FDrawColors.ForeGround := ThemeManager.SystemColor.ForeGround;

            FDrawColors.Accent := ThemeManager.AccentColor;
          end;


  // Redraw
  if FGlassBlur <> nil then
    FGlassBlur.Repaint;

  // Update Children
  if IsOpen then
    if IsContainer and UpdateChildren then
      begin
        for i := 0 to ComponentCount - 1 do
          if Supports(MenuItems[i], FXControl) then
            (MenuItems[i] as FXControl).UpdateTheme(UpdateChildren);
      end;
end;

{ FXPopupItems }

procedure FXPopupItems.Add(AItem: FXPopupItem);
var
  Index: integer;
begin
  Index := Length(FItems);
  SetLength(FItems, Index + 1);

  FItems[Index] := AItem;
end;

procedure FXPopupItems.Clear(AndFree: boolean);
var
  I: Integer;
begin
  if AndFree then
    for I := 0 to High(FItems) do
      FItems[I].Free;

  SetLength(FItems, 0);
end;

function FXPopupItems.Count: integer;
begin
  Result := Length(FItems);
end;

constructor FXPopupItems.Create(AOwner: TPersistent);
begin
  inherited;
  SetLength(FItems, 0);
end;

procedure FXPopupItems.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Item', ReadData, WriteData, true);
end;

procedure FXPopupItems.Delete(Index: integer; AndFree: boolean = true);
var
  I: Integer;
begin
  if AndFree then
    FItems[Index].Free;

  for I := Index to High(FItems) - 1 do
    FItems[Index] := FItems[Index + 1];
end;

destructor FXPopupItems.Destroy;
begin

  inherited;
end;

function FXPopupItems.GetItem(AIndex: Integer): FXPopupItem;
begin
  Result := FItems[AIndex];
end;

function FXPopupItems.IndexOf(AText: string): integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FItems) do
    if Item[I].Text = AText then
      Exit(I);
end;

procedure FXPopupItems.ReadData(Stream: TStream);
var
  Count: Integer;
  I: Integer;
  AItem: FXPopupItem;
begin
  Stream.ReadBuffer(Count, SizeOf(Count));
  SetLength(FItems, Count);
  for I := 0 to Count - 1 do
  begin
    AItem := FXPopupItem.Create(TComponent(Owner));
    AItem.LoadFromStream(Stream);
    FItems[I] := AItem;
  end;
end;

procedure FXPopupItems.WriteData(Stream: TStream);
var
  Count: Integer;
  I: Integer;
begin
  Count := Length(FItems);

  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count - 1 do
    FItems[I].SaveToStream(Stream);
end;

initialization
  RegisterClass(FXPopupContainer);
end.
