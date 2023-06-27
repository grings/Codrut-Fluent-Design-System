﻿unit CFX.Button;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Messaging,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Styles,
  Vcl.Themes,
  CFX.Utilities,
  CFX.VarHelpers,
  CFX.ThemeManager,
  CFX.Colors,
  CFX.UIConsts,
  CFX.Graphics,
  CFX.Classes,
  CFX.Controls,
  CFX.Linker,
  System.UITypes;

type
  FXButton = class;

  CPosition = (cpLeft, cpRight, cpTop, cpBottom);
  FXButtonState = (mbsLeave, mbsEnter, mbsDown);
  FXButtonAnimateEngine = (cbneComponent, cbneAtDraw);
  //FXButtonIconAlign = (cbiaLeft, cbiaRight, cbiaTop, cbiaBottom);
  FXButtonStateChange = procedure(Sender: FXButton; State: FXButtonState) of object;
  FXButtonIcon = (cicNone, cicSegoeFluent, cicYes, cicNo, cicTrueYes,
                  cicNoAllow, cicQuestion, cicWarning, cicStart, cicNext,
                  cicBack, cicUp, cicDown, cicArrow, cicEnter, cicRetry,
                  cicDownload, cicUpload, cicSearch, cicSearchL);


  FXButtonUnderLine = class(TMPersistent)
    private
      FUnderThick: integer;
      FUnderLn, FUnderLnRound: boolean;
      procedure SetUline(const Value: boolean);
      procedure SetULRound(const Value: boolean);
      procedure SetUlThick(const Value: integer);
    published
      property Enable : boolean read FUnderLn write SetUline;
      property UnderLineRound : boolean read FUnderLnRound write SetULRound;
      property UnderLineThicknes : integer read FUnderThick write SetUlThick;
  end;

  FXButtonColors = class(TMPersistent)
    private
      FEnter, FLeave, FDown: TColor;
      FLine: TColor;
      function Paint : Boolean;
    published
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
      property BLine : TColor read FLine write FLine stored Paint;
  end;

  FXButtonGradientSet = class(TMPersistent)
    private
      FEnter, FLeave, FDown: TColor;
      FEnabled: boolean;
      function Paint : Boolean;
    published
      property Enabled : boolean read FEnabled write FEnabled stored Paint;
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
  end;

  FXButtonFontAutoSize = class(TMPersistent)
    private
      FEnabled: boolean;
      FMax, FMin: integer;
      function Paint : Boolean;
    published
      property Enabled : boolean read FEnabled write FEnabled stored Paint;
      property Max : integer read FMax write FMax stored Paint;
      property Min : integer read FMin write FMin stored Paint;
  end;

  FXButtonAnimations = class(TMPersistent)
    private
      FPAn, FFadeAnimation: boolean;
      FAnimdelay, FAnimshq, TimeProg, FFadeSpeed: integer;
      FAnimateEngine: FXButtonAnimateEngine;
    published
      property PressAnimation : boolean read FPAn write FPAn;
      property PADelay : integer read FAnimdelay write FAnimdelay;
      property PAShrinkAmount : integer read FAnimshq write FAnimshq;
      property PAAnimateEngine : FXButtonAnimateEngine read FAnimateEngine write FAnimateEngine;

      property FadeAnimation: boolean read FFadeAnimation write FFadeAnimation;
      property FASpeed: integer read FFadeSpeed write FFadeSpeed;
  end;

  FXButtonPen = class(TMPersistent)
    private
      FColor : TColor;
      FWidth : integer;
      FEnablePenAlt: boolean;
      FCPenDown: TColor;
      FCPenHover: TColor;
      FUseThemeManager: boolean;
      function Paint : Boolean;
    published
      property Color : TColor read FColor write FColor stored Paint;
      property Width : integer read FWidth write FWidth stored Paint;
      property UseThemeManager: boolean read FUseThemeManager write FUseThemeManager stored Paint default true;
      property EnableAlternativeColors : boolean read FEnablePenAlt write FEnablePenAlt stored Paint default false;
      property AltHoverColor : TColor read FCPenHover write FCPenHover stored Paint;
      property AltPressColor : TColor read FCPenDown write FCPenDown stored Paint;
  end;

  FXButton = class(FXWindowsControl, FXControl)
  private
    FAuthor, FSite, FVersion: string;
    FonStateChange: FXButtonStateChange;

    FColors: FXButtonColors;
    FPen: FXButtonPen;
    FTextColors: FXButtonColors;
    FAnimations: FXButtonAnimations;
    FTransparent,
    FFlatBT,
    FFlatComplete,
    FEnableCaption,
    FCancel,
    FDefault: Boolean;
    w, h, fs: integer;
    FUseManualColor: boolean;
    FGradientSet: FXButtonGradientSet;
    FFontAutoSize: FXButtonFontAutoSize;
    FUnderLine: FXButtonUnderLine;
    FModalResult: TModalResult;
    FRoundAmount: integer;
    FText: string;
    FActionText: string;
    FSubText: string;
    FEnableSubText: boolean;
    FState, FPreviousState: FXButtonState;
    FFont: TFont;
    FSubTextFont: TFont;
    FAlign: TAlignment;
    FControlStyle: TControlStyle;
    ShX, ShY: integer;
    FImageLayout: CPosition;
    FTxtWSpace: integer;
    FCustomColors: FXColorSets;
    FImage: FXIconSelect;
    FActionImage: FXIconSelect;
    FActionToggle: boolean;
    //FTrueTransparency: boolean;

    FadeAnim: TTimer;

    function FadeBrushColor(from, towhich: FXButtonState; progress: integer; isflat: boolean = false; gradientcolor: boolean = false): TColor;
    function FadeFontColor(from, towhich: FXButtonState; progress: integer): TColor;

    procedure StTimer;
    procedure FTimerAct(Sender: TObject);
    procedure SetText(cOnst Value: string);
    procedure SetState(const Value: FXButtonState);
    procedure SetFont(const Value: TFont);
    procedure SetTransparent(const Value: boolean);
    procedure SetRoundVal(const Value: integer);
    procedure SetFlatnes(const Value: boolean);
    function ClrGray(clr: TColor): TColor;
    procedure SetAlign(const Value: TAlignment);
    procedure SetDefault(const Value: boolean);
    procedure SetCancel(const Value: boolean);
    procedure SetFlatComplete(const Value: boolean);
    procedure SetShowCaption(const Value: boolean);
    procedure SetFontAutoSize(const Value: FXButtonFontAutoSize);
    procedure SetGradient(const Value: FXButtonGradientSet);
    procedure SetImageLayour(const Value: CPosition);
    procedure SetManualColor(const Value: boolean);
    procedure SetEnableSubText(const Value: boolean);
    procedure SetSubFont(const Value: TFont);
    procedure SetSubText(const Value: string);
    procedure SetTextWall(const Value: integer);
    procedure SetImage(const Value: FXIconSelect);
    procedure SetActionToggle(const Value: boolean);
    procedure SetActionText(const Value: string);

    { Private declarations }
  protected
    procedure PaintBuffer; override;

    procedure Animation(undo: boolean);
    procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
    procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
    procedure KeyPress(var Key: Char); override;
    procedure Click; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure ApplyAccentColor;

  published
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnEnter;
    property OnExit;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property OnKeyPress;
    property OnKeyDown;
    property OnKeyUp;
    property OnClick;
    property OnStateChange : FXButtonStateChange read FOnStateChange write FOnStateChange;

    property PopupMenu;

    property Allignment: TAlignment read FAlign write SetAlign;

    property Default: boolean read FDefault write SetDefault;
    property Cancel: boolean read FCancel write SetCancel;

    property Action;
    property ShowHint;
    property TabStop;
    property TabOrder;
    property Align;
    property Anchors;
    property Constraints;
    property Cursor;
    property Visible;
    property Enabled;
    property DoubleBuffered;

    property Color;
    property ParentColor;

    property UseManualColor: boolean read FUseManualColor write SetManualColor;

    property Image: FXIconSelect read FImage write SetImage;
    property ImageLayout: CPosition Read FImageLayout write SetImageLayour;

    property ActionText: string read FActionText write SetActionText;
    property ActionImage: FXIconSelect read FActionImage write FActionImage;
    property ActionToggle: boolean read FActionToggle write SetActionToggle;

    property ShowCaption: boolean read FEnableCaption write SetShowCaption;

    property CustomColors: FXColorSets read FCustomColors write FCustomColors stored true;

    property GradientOptions : FXButtonGradientSet read FGradientSet write SetGradient;
    property ControlStyle : TControlStyle read FControlStyle write FControlStyle;

    property Font : TFont read FFont write SetFont stored True;
    property FontAutoSize : FXButtonFontAutoSize read FFontAutoSize write SetFontAutoSize;
    property SubTextFont : TFont read FSubTextFont write SetSubFont stored True;
    property Text : string read FText write SetText;
    property SubText : string read FSubText write SetSubText;
    property SubTextEnabled : boolean read FEnableSubText write SetEnableSubText default false;
    property TextWallSpacing : integer read FTxtWSpace write SetTextWall default 10;

    property RoundTransparent : boolean read FTransparent write SetTransparent;
    property RoundAmount : integer read FRoundAmount write SetRoundVal;
    property State : FXButtonState read FState write SetState;
    property FlatButton : boolean read FFlatBT write SetFlatnes;
    property FlatComplete : boolean read FFlatComplete write SetFlatComplete;
    property Colors : FXButtonColors read FColors write FColors;
    property UnderLine: FXButtonUnderLine read FUnderLine write FUnderLine;
    property TextColors : FXButtonColors read FTextColors write FTextColors;
    property Pen : FXButtonPen read FPen write FPen;
    property Animations: FXButtonAnimations read FAnimations write FAnimations;

    property &&&Author: string Read FAuthor;
    property &&&Site: string Read FSite;
    property &&&Version: string Read FVersion;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure SetFocus(); override;
    procedure Invalidate; override;

    // Interface
    function IsContainer: Boolean;
    procedure UpdateTheme(const UpdateChildren: Boolean);

    function Background: TColor;
  end;

const
  defaultunderln = 6;
  AnimSizeDvz = 50;

implementation

{ FXButtonColors }
functiOn FXButtonColors.Paint: Boolean;
begin
  if Self.Owner is FXButton then begin
    FXButton(Self.Owner).PaintBuffer;
    Result := True;
  end else Result := False;
end;

{ FXButtonPen }
functiOn FXButtonPen.Paint: Boolean;
begin
  if Self.Owner is FXButton then begin
    FXButton(Self.Owner).PaintBuffer;
    Result := True;
  end else Result := False;
end;

{ FXButton }

procedure FXButton.Animation(undo: boolean);
var
  i, x, y: integer;
begin
  if not FAnimations.FPAn then Exit;

  if FAnimations.PAAnimateEngine = cbneAtDraw then begin

    for i := 1 to FAnimations.FAnimshq do begin
      Sleep(FAnimations.FAnimdelay);

      x := round(width / AnimSizeDvz);
      Y := round(height / AnimSizeDvz);

      if x < 1 then x := 1;
      if y < 1 then y := 1;


      if undo then begin
        dec(shX, x);
        dec(shY, y);
      end else begin
        inc(shX, x);
        inc(shY, y);
      end;

      FTimerAct(nil);

      PaintBuffer;
    end;
  end else
  begin
      if undo then begin
      w := w * -1;
      h := h * -1;
      fs := fs * -1;
    end else begin
      w := trunc(Width / 40);
      h := trunc(Height / 40);
      fs := trunc(FFont.Size / 40);
      if fs = 0 then fs := 1;
      if w = 0 then w := 1;
      if h = 0 then h := 1;
    end;
    //Experiment
    for i := 1 to FAnimations.FAnimshq do begin
      Sleep(FAnimations.FAnimdelay);
      FFont.Size := FFont.Size -fs;
      Width := Width + (w * -1);
      Height := Height + (h * -1);
      Left := Left + round(w / 2);
      Top := Top + round(h / 2);

      PaintBuffer;
    end;
  end;
end;

function FXButton.ClrGray(clr: TColor): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div 3;
  G:= R; B:=R;

  Result := RGB(r,g,b);
end;

procedure FXButton.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FUseManualColor then
    Exit;

  if FCustomColors.Enabled then
    AccColor := FCustomColors.Accent
  else
    AccColor := ThemeManager.AccentColor;

  FColors.FLeave := ChangeColorLight(AccColor, -15);
  FColors.FEnter := ChangeColorLight(FColors.FLeave, 15);
  FColors.FDown := ChangeColorLight(FColors.FLeave, -25);
  FColors.FLine := ChangeColorLight(FColors.FLeave, -40);
end;

function FXButton.Background: TColor;
begin
  Result := Color;
end;

procedure FXButton.Click;
var
  Form: TCustomForm;
begin
  inherited;

  Form := GetParentForm(Self);
  if Form <> nil then
    Form.ModalResult := ModalResult;
end;

procedure FXButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FDefault) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;

procedure FXButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  SetState(mbsEnter);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
end;

procedure FXButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  SetState(mbsLeave);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
end;

constructor FXButton.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.3';

  FCustomColors := FXColorSets.Create(Self, false);

  BufferedComponent := true;
  AutoFocusLine := true;
  FAlign := taCenter;

  TabStop := true;

  FEnableCaption := true;

  FGradientSet := FXButtonGradientSet.Create(Self);
  with FGradientSet do begin
    FEnabled := false;
    FDown := clMaroon;
    FEnter := clFuchsia;
    FLeave := clRed;
  end;

  FFontAutoSize := FXButtonFontAutoSize.Create(Self);
  with FFontAutoSize do begin
    FEnabled := false;
    FMax := -1;
    FMin := -1;
  end;

  FColors := FXButtonColors.Create(Self);
  with FColors do begin
    Enter := $00D7821A;
    Leave := $00C57517;
    Down := $008E5611;
    BLine := $008E5611;;
  end;

  FadeAnim := TTimer.Create(Self);
  with FadeAnim do begin
    Interval := 1;
    Enabled := false;
    FadeAnim.OnTimer := FTimerAct;
  end;

  FAnimations := FXButtonAnimations.Create;
  with FAnimations do begin
    FAnimations.FPAn := false;
    PAAnimateEngine := cbneAtDraw;
    FAnimdelay := 2;
    FFadeSpeed := 10;
    FAnimshq := 6;
  end;

  FTextColors := FXButtonColors.Create(Self);
  with FTextColors do begin
    Enter := clWhite;
    Leave := clWhite;
    Down := clWhite;
  end;

  FUnderLine := FXButtonUnderLine.Create(Self);
  with FUnderLine do begin
    FUnderLnRound := true;
    FUnderThick := defaultunderln;
    FUnderLn := true;
  end;

  FPen := FXButtonPen.Create(self);
  With FPen do begin
    Width := 2;
    Color := clWindow;
    FEnablePenAlt := false;
    UseThemeManager := true;
  end;

  FFont := TFont.Create;
  with FFont do begin
    Name := 'Segoe UI Semibold';
    Size := 12;
    Color := $00D7821A;
  end;

  FSubText := 'Hello World!';
  FEnableSubText := false;

  FSubTextFont := TFont.Create;
  with FSubTextFont do begin
    Name := 'Segoe UI';
    Size := 10;
    Color := $00D7821A;
  end;

  FTxtWSpace := 10;

  FImage := FXIconSelect.Create(Self);
  FActionImage := FXIconSelect.Create(Self);

  ApplyAccentColor;

  Width := 110;
  Height := 40;

  FText := 'Click me';
  FState := mbsLeave;

  FActionText := 'Working';

  FImageLayout := cpLeft;

  FAnimations.FFadeAnimation := true;

  Pen.Width := 0;
  FTransparent := true;
  FRoundAmount := 10;
end;

destructor FXButton.Destroy;
begin
  FreeAndNil( FCustomColors );
  FreeAndNil( FPen );
  FreeAndNil( FColors );
  FreeAndNil( FImage );
  FreeAndNil( FActionImage );
  FreeAndNil( FAnimations );
  FadeAnim.Enabled := false;
  FreeAndNil( FadeAnim );
  FreeAndNil( FUnderLine );
  FreeAndNil( FTextColors );
  FreeAndNil( FFont );
  inherited;
end;

procedure FXButton.DoEnter;
begin
  inherited;
  SetState(mbsEnter);
end;

procedure FXButton.DoExit;
begin
  inherited;
  SetState(mbsLeave);

  if FDefault then
    //Self.SetFocus;
end;

function FXButton.FadeBrushColor(from, towhich: FXButtonState;
  progress: integer; isflat: boolean; gradientcolor: boolean): TColor;
var
  c1, c2: TColor;
  flatmt: integer;
begin
  c1 := clWhite;
  c2 := clWhite;

  if FFlatComplete then
    flatmt := 0
  else
    flatmt := 1;

  if NOT gradientcolor then
  begin
    case from of
      mbsDown: if isflat then c1 := ChangeColorLight(FPen.Color,-15 * flatmt) else
        c1 := FColors.Down;
      mbsLeave: if isflat then c1 := ChangeColorLight(FPen.Color,-3 * flatmt) else
         c1 := FColors.Leave;
      mbsEnter: if isflat then c1 := ChangeColorLight(FPen.Color,-5 * flatmt) else
         c1 := FColors.Enter;
    end;
    case towhich of
      mbsDown: if isflat then c2 := ChangeColorLight(FPen.Color,-15 * flatmt) else
         c2 := FColors.Down;
      mbsLeave: if isflat then c2 := ChangeColorLight(FPen.Color,-3 * flatmt) else
         c2 := FColors.Leave;
      mbsEnter: if isflat then c2 := ChangeColorLight(FPen.Color,-5 * flatmt) else
         c2 := FColors.Enter;
    end;
  end
  else begin
    case from of
      mbsDown: c1 := FGradientSet.Down;
      mbsLeave: c1 := FGradientSet.Leave;
      mbsEnter: c1 := FGradientSet.Enter;
    end;
    case towhich of
      mbsDown: c2 := FGradientSet.Down;
      mbsLeave: c2 := FGradientSet.Leave;
      mbsEnter: c2 := FGradientSet.Enter;
    end;
  end;

  if FAnimations.FFadeAnimation then
    Result := ColorBlend(c1, c2, progress * (255 div FAnimations.FASpeed))
  else
    Result := c2;
end;

function FXButton.FadeFontColor(from, towhich: FXButtonState;
  progress: integer): TColor;
var
  c1, c2: TColor;
begin
  c1 := clWhite;
  c2 := clWhite;

  case from of
    mbsDown: c1 := FTextColors.Down;
    mbsLeave: c1 := FTextColors.Leave;
    mbsEnter: c1 := FTextColors.Enter;
  end;
  case towhich of
    mbsDown: c2 := FTextColors.Down;
    mbsLeave: c2 := FTextColors.Leave;
    mbsEnter: c2 := FTextColors.Enter;
  end;

  if FAnimations.FFadeAnimation then
    Result := ColorBlend(c1, c2, progress * (255 div FAnimations.FASpeed))
  else
    Result := c2;
end;

procedure FXButton.FTimerAct(Sender: TObject);
begin
  if NOT (FAnimations.TimeProg >= FAnimations.FASpeed) then
  begin
    inc(FAnimations.TimeProg);
     PaintBuffer;
  end else
  FadeAnim.Enabled := false;
end;

procedure FXButton.Invalidate;
begin
  inherited;
  PaintBuffer;

  ApplyAccentColor;
end;

function FXButton.IsContainer: Boolean;
begin
  Result := false;
end;

procedure FXButton.KeyPress(var Key: Char);
begin
  inherited;
  if (key = #13) or (key = #32) then begin
    SetState(mbsDown);
    if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
    //if Assigned(OnClick) then OnClick(Self);
    SetState(mbsEnter);
    Click;
  end;
end;

procedure FXButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  SetState(mbsDown);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  Animation(false);
end;

procedure FXButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  if Self.Parent = nil then
    Exit;

  SetState(mbsEnter);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  PaintBuffer;
  Animation(true);
end;

procedure FXButton.PaintBuffer;
var
  I, TLeft, TTop, ILeft, ITop, SLeft, STop, SHeight, SWidth, IWidth, IHeight,
    TWidth, THeight, SC: Integer;
  cl2: TColor;
  TText: string;
  drawcanv, lastcanv: TBitMap;
  CRect, DRect, IconRect: TRect;
  TmpFont: TFont;
  ImagePointer: FXIconSelect;
begin
  if (Parent = nil) then
    Exit;

  ApplyAccentColor;

  // Select Color
  if not Self.ParentColor then
    FPen.Color := GetParentBackgroundColor(Color)
      else
        if not FPen.FUseThemeManager then
          FPen.Color := ThemeManager.SystemColor.BackGround;

  drawcanv := TBitMap.Create;
  drawcanv.Height := height;
  drawcanv.Width := width;

  with drawcanv.Canvas do begin
    //Drawing ( + Transparency )
    Brush.Color := FPen.Color;
    if FPen.FEnablePenAlt then begin
      if FState = mbsDown then Brush.Color := FPen.FCPenDown
        else
      if FState = mbsEnter then Brush.Color := FPen.FCPenHover;
    end;
    //bgcolor := Brush.Color;
    FillRect( ClipRect );

    Font.Assign( FFont );
    case FState of
      mbsLeave: begin
        Brush.Color := FColors.Leave;
        Font.Color := FTextColors.Leave;
      end;
      mbsEnter: begin
        Brush.Color := FColors.Enter;
        Font.Color := FTextColors.Enter;
      end;
      mbsDown: begin
        Brush.Color := FColors.Down;
        Font.Color := FTextColors.Down;
      end;
    end;

    { Animate }
    Brush.Color := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg);
    Font.Color := FadeFontColor( FPreviousState, FState, FAnimations.TimeProg);
    if FFlatBt then
      begin
        Font.Color := Brush.Color;
        Brush.Color := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg, true);
      end;

    //Brush.Color := clRed;
    // Normal Draw
    DRect := Rect( FPen.Width, FPen.Width, Width - FPen.Width, Height - FPen.Width );
    if NOT Self.Enabled then
      begin
        if FFlatBt then
          Font.Color := FTextColors.FLine
        else
          Brush.Color := ClrGray(Brush.Color);
      end;

    // Gradient Mode
    if FGradientSet.FEnabled then
    begin
      cl2 := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg, false, true);

      // Draw Gradient
      GradHorizontal(drawcanv.Canvas, DRect, Brush.Color, cl2);
    end
      else
    FillRect( DRect );

    // Text and Icon
    // Font Auto Size
    if FFontAutoSize.FEnabled then
    begin
      Font.Size := trunc((Self.Width - Pen.Width) / (TextWidth(FText)) * 7);

      if FFontAutoSize.FMax <> -1 then
      if Font.Size > FFontAutoSize.FMax then
        Font.Size   := FFontAutoSize.FMax;

      if FFontAutoSize.FMin <> -1 then
      if Font.Size < FFontAutoSize.FMin then
        Font.Size   := FFontAutoSize.FMin;
    end;

    // Action Mode
    if ActionToggle then
      begin
        ImagePointer := FActionImage;
        TText := FActionText;
      end
    else
      begin
        ImagePointer := FImage;
        TText := FText;
      end;
    SC := 5;

    // Caption
    if NOT FEnableCaption then
      begin
        TText := '';
        SC := 0;
      end;

    // Height and positioning
    TLeft := 0;
    TTop := 0;
    ILeft := 0;
    ITop := 0;

    TWidth := TextWidth(TText);
    THeight := TextHeight(TText);

    IHeight := THeight;

    // Sub Text Sizing
    SLeft := 0;
    STop := 0;
    SWidth := 0;
    SHeight := 0;
    if FEnableSubText then
      begin
        FSubTextFont.Color := Font.Color;

        TmpFont := TFont.Create;
        TmpFont.Assign(Font);

        SHeight := TextHeight(FSubText);
        SWidth := TextWidth(FSubText);

        Font.Assign(TmpFont);
        TmpFont.Free;
      end;

    // Clear brush and begin
    Brush.Style := bsClear;
    if NOT Self.Enabled then Font.Color := ClrGray(Font.Color);
      { Bitmap Mode }
      try
        if IHeight = 0 then
          IHeight := round(height / 1.2);

        IWidth := IHeight;

        { Image Layouts }
        if not ImagePointer.Enabled then
          begin
            IWidth := 0;
            IHeight := 0;
            SC := 0;
          end;

        { Layout coordinate set }
        case FImageLayout of
          cpLeft: begin
            TTop := Height div 2 - THeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2 + IWidth div 2;
                ILeft := TLeft - IWidth - SC;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC * 2 + IWidth;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := TLeft - IWidth - SC;
              end;
            end;
          end;
          cpRight: begin
            TTop := Height div 2 - THeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2 - IWidth div 2;
                ILeft := TLeft + TWidth + SC;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := TLeft + TWidth + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC * 2 - TWidth - IWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
          cpTop: begin
            TTop := Height div 2 - THeight div 2 + IHeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop - SC - IHeight;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2;
                ILeft := Width div 2 - IWidth div 2;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
          cpBottom: begin
            TTop := Height div 2 - THeight div 2 - IHeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop + SC + IHeight + SHeight;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2;
                ILeft := Width div 2 - IWidth div 2;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
        end;

        { SubText Left }
        case FAlign of
          taLeftJustify: SLeft := TLeft;
          taRightJustify: SLeft := TLeft + TWidth - SWidth;
          taCenter: SLeft := Width div 2 - SWidth div 2;
        end;

        { Check empty text for bitmap only }
        if TText = '' then
        begin
          ILeft := Width div 2- IWidth div 2;
          //ITop := trunc(Height * 0.1);
          ITop := Height div 2 - IHeight div 2;
        end;

        { Draw Bitmap }
        if ImagePointer.Enabled then begin
          IconRect := Rect(
          {x1} ILeft,
          {y1} ITop,
          {x2} ILeft + IWidth,
          {y2} ITop + IHeight);

          ImagePointer.DrawIcon(drawcanv.Canvas, IconRect);
        end;
      except
        TText := '🚫' + TText;
      end;

    // Draw Text
    TextOut(  TLeft, TTop, TText);

    // Sub Text
    if FEnableSubText then
      begin
        Font.Assign(FSubTextFont);
        TextOut(  SLeft, STop, FSubText);
      end;


    // Underline
    if FUnderLine.FUnderLn then begin
      Brush.Style := bsSolid;
      Brush.Color := FColors.BLine;
      if FUnderLine.FUnderLnRound then begin
        Pen.Color := FColors.BLine;
        Pen.Width := FUnderLine.FUnderThick;
        Brush.Style := bsClear;
        Pen.Style := psSolid;
        if NOT Self.Enabled then Pen.Color := ClrGray(Pen.Color);
        RoundRect( Rect( -Pen.Width div 2, -Pen.Width, Width + Pen.Width div 2, Height - FPen.Width), FRoundAmount, FRoundAmount * 3);
      end else begin
        FillRect( Rect( FPen.Width, Height - trunc( Height / 50 * FUnderLine.FUnderThick ), Width - FPen.Width, Height - FPen.Width) );
      end;
    end;

    // Round Amount
    if FTransparent then begin
      Brush.Style := bsClear;
      if FPen.FEnablePenAlt then
        case State of
          mbsLeave: Pen.Color := FPen.FColor;
          mbsEnter: Pen.Color := FPen.FCPenHover;
          mbsDown: Pen.Color := FPen.FCPenDown;
        end
      else
        Pen.Color := FPen.FColor;

      Pen.Width := 1;
      for I := 0 to FRoundAmount do
        RoundRect(0, 0, Width, Height, I, I);
      end;
  end;

  CRect := Rect(ShX div 2, ShY div 2, Width - round(ShX / 2), Height - round(ShY / 2));

  // Final Preparations to avoid flicker
  lastcanv := TBitMap.Create;
  lastcanv.Width := Width;
  lastcanv.Height := Height;

  with lastcanv do begin
    Buffer.Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);
    Buffer.FillRect( Buffer.ClipRect );

    Buffer.DrawHighQuality(CRect, drawcanv);
  end;

  // Complete draw cycle
  Buffer.CopyRect( drawcanv.Canvas.ClipRect,drawcanv.Canvas,drawcanv.Canvas.ClipRect );

  lastcanv.Free;
  drawcanv.Free;
  inherited;
end;

procedure FXButton.SetActionText(const Value: string);
begin
  FActionText := Value;

  PaintBuffer;
end;

procedure FXButton.SetActionToggle(const Value: boolean);
begin
  FActionToggle := Value;

  PaintBuffer;
end;

procedure FXButton.SetAlign(const Value: TAlignment);
begin
  FAlign := Value;
  PaintBuffer;
end;

procedure FXButton.SetCancel(const Value: boolean);
begin
  FCancel := Value;
end;

procedure FXButton.SetDefault(const Value: boolean);
begin
  FDefault := Value;
end;

procedure FXButton.SetEnabled(Value: Boolean);
begin
  inherited;
  PaintBuffer;
end;

procedure FXButton.SetEnableSubText(const Value: boolean);
begin
  FEnableSubText := Value;

  PaintBuffer;
end;

procedure FXButton.SetFlatComplete(const Value: boolean);
begin
  FFlatComplete := Value;

  if Value then
    FUnderline.Enable := false;

  PaintBuffer;
end;

procedure FXButton.SetFlatnes(const Value: boolean);
begin
  FFlatBT := Value;
  PaintBuffer;
end;

procedure FXButton.SetFocus;
begin
  inherited;
  {//OutDated execution
  FState := mbsEnter;
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  Paint;   }
end;

procedure FXButton.SetFont(const Value: TFont);
begin
  FFont.Assign( Value );
  PaintBuffer;
end;

procedure FXButton.SetFontAutoSize(const Value: FXButtonFontAutoSize);
begin
  FFontAutoSize := Value;
end;

procedure FXButton.SetGradient(const Value: FXButtonGradientSet);
begin
  FGradientSet := Value;
  PaintBuffer;
end;

procedure FXButton.SetImage(const Value: FXIconSelect);
begin
  FImage := Value;

  PaintBuffer;
end;

procedure FXButton.SetImageLayour(const Value: CPosition);
begin
  FImageLayout := Value;
end;

procedure FXButton.SetManualColor(const Value: boolean);
begin
  FUseManualColor := Value;

  if not Value then
    ApplyAccentColor;

  PaintBuffer;
end;

procedure FXButton.SetRoundVal(const Value: integer);
begin
  FRoundAmount := Value;

  PaintBuffer;
end;

procedure FXButton.SetShowCaption(const Value: boolean);
begin
  FEnableCaption := Value;
  PaintBuffer;
end;

procedure FXButton.SetState(const Value: FXButtonState);
begin
  StTimer;
  FPreviousState := FState;
  FState := Value;
  PaintBuffer;
end;

procedure FXButton.SetSubFont(const Value: TFont);
begin
  FSubTextFont := Value;

  PaintBuffer;
end;

procedure FXButton.SetSubText(const Value: string);
begin
  FSubText := Value;

  PaintBuffer;
end;

procedure FXButton.SetText(const Value: string);
begin
  FText := Value;
  PaintBuffer;
end;

procedure FXButton.SetTextWall(const Value: integer);
begin
  FTxtWSpace := Value;

  PaintBuffer;
end;

procedure FXButton.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;
  PaintBuffer;
end;

procedure FXButton.StTimer;
begin
  if Parent <> nil then
  if (Parent.Visible) and (Visible)
    and (Application.Active) and (FAnimations.FFadeAnimation)
    then begin
    FAnimations.TimeProg := 0;
    FadeAnim.Enabled := true;
  end;
end;

procedure FXButton.UpdateTheme(const UpdateChildren: Boolean);
begin
  ApplyAccentColor;
  PaintBuffer;
end;

{ FXButtonUnderLine }

procedure FXButtonUnderLine.SetUline(const Value: boolean);
begin
  FUnderLn := Value;
  FXButton(Self.Owner).PaintBuffer;
end;

procedure FXButtonUnderLine.SetULRound(const Value: boolean);
begin
  FUnderLnRound := Value;
  FXButton(Self.Owner).PaintBuffer;
end;

procedure FXButtonUnderLine.SetUlThick(const Value: integer);
begin
  FUnderThick := Value;
  FXButton(Self.Owner).PaintBuffer;
end;

{ FXButtonFontAutoSize }

function FXButtonFontAutoSize.Paint: Boolean;
begin
  if Self.Owner is FXButton then begin
    FXButton(Self.Owner).PaintBuffer;
    Result := True;
  end else Result := False;
end;

{ FXButtonGradientSet }

function FXButtonGradientSet.Paint: Boolean;
begin
  if Self.Owner is FXButton then begin
    FXButton(Self.Owner).PaintBuffer;
    Result := True;
  end else Result := False;
end;

end.
