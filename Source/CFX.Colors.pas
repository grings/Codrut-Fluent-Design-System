{$M+}

unit CFX.Colors;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows,
  Vcl.Graphics,
  Types,
  UITypes,
  Classes,
  SysUtils,
  Vcl.Forms,
  Math,
  CFX.Types,
  TypInfo,
  CFX.TypeInfo,
  CFX.Linker;

type
  { Color }
  FXColor = CFX.Types.FXColor;

  { Persistent Color Class }
  FXPersistentColor = class(TPersistent)
  private
    Owner : TPersistent;
    FEnable: boolean;

    procedure Updated;
    procedure SetEnabled(const Value: boolean);

  protected
    property Enabled: boolean read FEnable write SetEnabled;

  public
    constructor CreateOwner(AOwner : TPersistent); overload; virtual;

    procedure Assign(Source: TPersistent); override;
  end;

  { Complete Color State Set }
  FXColorStateSets = class(FXPersistentColor)
    private
      FAccent,
      FLightBackGroundNone,
      FLightBackGroundHover,
      FLightBackGroundPress,
      FLightForeGroundNone,
      FLightForeGroundHover,
      FLightForeGroundPress,
      FDarkBackGroundNone,
      FDarkBackGroundHover,
      FDarkBackGroundPress,
      FDarkForeGroundNone,
      FDarkForeGroundHover,
      FDarkForeGroundPress: TColor;

      procedure SetStateColor(const Index: Integer; const Value: TColor);

    public
      constructor Create; overload;
      constructor Create(AOwner : TPersistent); overload;

      function GetColor(const DarkTheme, Foreground: boolean; State: FXControlState): TColor;

    published
      property Enabled;

      property Accent: TColor read FAccent write FAccent;
      property LightBackgroundNone: TColor index 0 read FLightBackGroundNone write SetStateColor;
      property LightBackgroundHover: TColor index 1 read FLightBackGroundHover write SetStateColor;
      property LightBackgroundPress: TColor index 2 read FLightBackGroundPress write SetStateColor;
      property LightForeGroundNone: TColor index 3 read FLightForeGroundNone write SetStateColor;
      property LightForeGroundHover: TColor index 4 read FLightForeGroundHover write SetStateColor;
      property LightForeGroundPress: TColor index 5 read FLightForeGroundPress write SetStateColor;
      property DarkBackGroundNone: TColor index 6 read FDarkBackGroundNone write SetStateColor;
      property DarkBackGroundHover: TColor index 7 read FDarkBackGroundHover write SetStateColor;
      property DarkBackGroundPress: TColor index 8 read FDarkBackGroundPress write SetStateColor;
      property DarkForeGroundNone: TColor index 9 read FDarkForeGroundNone write SetStateColor;
      property DarkForeGroundHover: TColor index 10 read FDarkForeGroundHover write SetStateColor;
      property DarkForeGroundPress: TColor index 11 read FDarkForeGroundPress write SetStateColor;
  end;

  // Color State Set
  FXColorStateSet = class(FXPersistentColor)
    private
      FAccent,
      FBackGroundNone,
      FBackGroundHover,
      FBackGroundPress,
      FForeGroundNone,
      FForeGroundHover,
      FForeGroundPress: TColor;

    public
      constructor Create; overload;
      constructor Create(AFrom: FXColorStateSets; const DarkColor: boolean); overload;

      procedure LoadFrom(AFrom: FXColorStateSets; const DarkColor: boolean);

      function GetColor(const Foreground: boolean; State: FXControlState): TColor;

    published
      property Enabled;

      property Accent: TColor read FAccent write FAccent;
      property BackgroundNone: TColor index 0 read FBackGroundNone write FBackGroundNone;
      property BackgroundHover: TColor index 1 read FBackGroundHover write FBackGroundHover;
      property BackgroundPress: TColor index 2 read FBackGroundPress write FBackGroundPress;
      property ForeGroundNone: TColor index 3 read FForeGroundNone write FForeGroundNone;
      property ForeGroundHover: TColor index 4 read FForeGroundHover write FForeGroundHover;
      property ForeGroundPress: TColor index 5 read FForeGroundPress write FForeGroundPress;
  end;

  { Color State Sets }
  FXSingleColorStateSets = class(FXPersistentColor)
    private
      FAccent,
      FLightNone,
      FLightHover,
      FLightPress,
      FDarkNone,
      FDarkHover,
      FDarkPress: TColor;

      procedure SetStateColor(const Index: Integer; const Value: TColor);
    public
      constructor Create; overload;
      constructor Create(AOwner: TPersistent); overload;

      procedure SetLightColor(None, Hover, Press: TColor);
      procedure SetDarkColor(None, Hover, Press: TColor);
      function GetColor(const DarkTheme: boolean; State: FXControlState): TColor;

    published
      property Enabled;

      property Accent: TColor read FAccent write FAccent;
      property LightNone: TColor index 0 read FLightNone write SetStateColor;
      property LightHover: TColor index 1 read FLightHover write SetStateColor;
      property LightPress: TColor index 2 read FLightPress write SetStateColor;
      property DarkNone: TColor index 3 read FDarkNone write SetStateColor;
      property DarkHover: TColor index 4 read FDarkHover write SetStateColor;
      property DarkPress: TColor index 5 read FDarkPress write SetStateColor;
  end;

  { Color State Set }
  FXSingleColorStateSet = class(FXPersistentColor)
    private
      FAccent,
      FNone,
      FHover,
      FPress: TColor;

    public
      constructor Create(ANone, AHover, APress: TColor); overload;
      constructor Create(Colors: FXSingleColorStateSets; const DarkTheme: boolean = false); overload;

      procedure LoadColors(ANone, AHover, APress: TColor); overload;
      procedure LoadColors(Colors: FXSingleColorStateSets; const DarkTheme: boolean = false); overload;

      procedure SetStateColor(const Index: Integer; const Value: TColor);
      function GetColor(const AState: FXControlState): TColor;

      procedure CopyFrom(FromSet: FXSingleColorStateSet);

    published
      property Enabled;

      property Accent: TColor read FAccent write FAccent;
      property None: TColor read FNone write FNone;
      property Hover: TColor read FHover write FHover;
      property Press: TColor read FPress write FPress;
  end;

  { Complete color sets with both Dark and Light theme }
  FXColorSets = class(FXPersistentColor)
    private
      FAccent,
      FLightBackGround,
      FLightForeground,
      FDarkBackGround,
      FDarkForeground: TColor;

      procedure WriteColorValue(const Index: Integer; const Value: TColor);

    public
      constructor Create(FocusControl: boolean = false); overload;
      constructor Create(AOwner: TPersistent; FocusControl: boolean = false); overload;

    published
      property Enabled;

      property Accent: TColor index 0 read FAccent write WriteColorValue;
      property LightBackGround: TColor index 1 read FLightBackGround write WriteColorValue;
      property LightForeGround: TColor index 2 read FLightForeGround write WriteColorValue;
      property DarkBackGround: TColor index 3 read FDarkBackGround write WriteColorValue;
      property DarkForeGround: TColor index 4 read FDarkForeground write WriteColorValue;
  end;

  // Interited from Basic Color Sets
  FXCompleteColorSets = class(FXColorSets)
    private
      FLightBackGroundInterior,
      FDarkBackGroundInterior: TColor;
      procedure SetDarkBackGroundInterior(const Value: TColor);
      procedure SetLightBackGroundInterior(const Value: TColor);

    public
      constructor Create; overload;
      constructor Create(AOwner: TPersistent); overload;

    published
      property LightBackGroundInterior: TColor read FLightBackGroundInterior write SetLightBackGroundInterior;
      //
      property DarkBackGroundInterior: TColor read FDarkBackGroundInterior write SetDarkBackGroundInterior;
  end;

  { Single Color Set with one option }
  FXColorSet = class(FXPersistentColor)
    private
      FAccent,
      FBackGround,
      FForeground: TColor;

    public
      constructor Create; overload;
      constructor Create(AOwner: TPersistent); overload;
      constructor Create(Colors: FXColorSets; const DarkColor: boolean = false); overload;
      constructor Create(AOwner: TPersistent; Colors: FXColorSets; const DarkColor: boolean = false); overload;

      procedure UpdateSource;
      procedure LoadFrom(Colors: FXColorSets; const DarkColor: boolean = false);

    published
      property Accent: TColor read FAccent write FAccent;
      property BackGround: TColor read FBackGround write FBackGround;
      property ForeGround: TColor read FForeGround write FForeGround;
  end;

  // Inherited from basic color set
  FXCompleteColorSet = class(FXColorSet)
    private
      FBackGroundInterior: TColor;

    public
      constructor Create(Colors: FXCompleteColorSets; DarkColor: boolean = false); overload;

      procedure UpdateSource;
      procedure LoadFrom(Colors: FXCompleteColorSets; const DarkColor: boolean = false); overload;

    published
      property BackGroundInterior: TColor read FBackGroundInterior write FBackGroundInterior;
  end;

// Color Manipulation
function ChangeColorLight( clr: TColor; changeby: integer ): TColor;
function GetColorLight( clr: TColor ): integer;
function GetColorGrayScale( clr: TColor ): TColor;
function GetTextColorFromBackground(BackGround: TColor): TColor;
function ColorBlend(Color1, Color2: TColor; A: Byte): TColor;
function GetMaxFontSize(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;
procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);

const
  DEFAULT_ACCENT_COLOR = 13924352;

  DEFAULT_DARK_BACKGROUND_COLOR = 2105376;
  DEFAULT_DARK_BACKGROUNDCONTROL_COLOR = 2829099;
  DEFAULT_DARK_GRAY_CONTROL_COLOR = 10657693;
  DEFAULT_DARK_GRAY_CONTROL_HOVER_COLOR = 12039603;
  DEFAULT_DARK_GRAY_CONTROL_PRESS_COLOR = 9275783;
  DEFAULT_DARK_GRAY_CONTROL_FONT_COLOR = 16777215;
  DEFAULT_DARK_GRAY_CONTROL_HOVER_FONT_COLOR = 16777215;
  DEFAULT_DARK_GRAY_CONTROL_PRESS_FONT_COLOR = 13553358;
  DEFAULT_DARK_FOREGROUND_COLOR = 16777215;

  DEFAULT_LIGHT_BACKGROUND_COLOR = 15987699;
  DEFAULT_LIGHT_BACKGROUNDCONTROL_COLOR = 16514043;
  DEFAULT_LIGHT_GRAY_CONTROL_COLOR = 9145227;
  DEFAULT_LIGHT_GRAY_CONTROL_HOVER_COLOR = 10461087;
  DEFAULT_LIGHT_GRAY_CONTROL_PRESS_COLOR = 7697781;
  DEFAULT_LIGHT_GRAY_CONTROL_FONT_COLOR = 1776411;
  DEFAULT_LIGHT_GRAY_CONTROL_HOVER_FONT_COLOR = 1776411;
  DEFAULT_LIGHT_GRAY_CONTROL_PRESS_FONT_COLOR = 8882055;
  DEFAULT_LIGHT_FOREGROUND_COLOR = 1776410;

  GENERIC_DARK_FONT_COLOR = 15987699;
  GENERIC_LIGHT_FONT_COLOR = 2105376;

  GRAYSCALE_DIV_CONST = 3;

type
  ColorRepository = record
    const
    AccentDefault = DEFAULT_ACCENT_COLOR;

    DarkBackground = DEFAULT_DARK_BACKGROUND_COLOR;
    DarkBackgroundControl = DEFAULT_DARK_BACKGROUNDCONTROL_COLOR;
    DarkFontColor = GENERIC_DARK_FONT_COLOR;
    DarkPausedColor = $0000E1FC;
    DarkErrorColor = $00A499FF;

    LightBackground = DEFAULT_LIGHT_BACKGROUND_COLOR;
    LightBackgroundControl = DEFAULT_LIGHT_BACKGROUNDCONTROL_COLOR;
    LightFontColor = GENERIC_LIGHT_FONT_COLOR;
    LightPausedColor = $00005D9D;
    LightErrorColor = $001C2BC4;
  end;

implementation

function ChangeColorLight( clr: TColor; changeby: integer ): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R := R + changeby;
  G := G + changeby;
  B := B + changeby;

  if R < 0 then R := 0;
  if G < 0 then G := 0;
  if B < 0 then B := 0;

  if R > 255 then R := 255;
  if G > 255 then G := 255;
  if B > 255 then B := 255;

  Result := RGB(r,g,b);
end;

function GetColorLight( clr: TColor ): integer;
var
  l1, l2, l3: real;
begin
  l1 := GetRValue(clr);
  l2 := GetGValue(clr);
  l3 := GetBValue(clr);

  Result := trunc((l1 + l2 + l3)/3);
end;

function GetColorGrayScale( clr: TColor ): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div GRAYSCALE_DIV_CONST;
  G:= R; B:=R;

  Result := RGB(r,g,b);
end;

function GetTextColorFromBackground(BackGround: TColor): TColor;
begin
  if GetColorLight( BackGround ) > 150 then
    Result := GENERIC_LIGHT_FONT_COLOR
  else
    Result := GENERIC_DARK_FONT_COLOR;
end;

function ColorBlend(Color1, Color2: TColor; A: Byte): TColor;
var
  RGB1, RGB2: FXColor;
  R, G, B: integer;
begin
  RGB1 := FXColor.Create(Color1);
  RGB2 := FXColor.Create(Color2);

  R := RGB1.GetR + (RGB2.GetR - RGB1.GetR) * A div 255;
  G := RGB1.GetG + (RGB2.GetG - RGB1.GetG) * A div 255;
  B := RGB1.GetB + (RGB2.GetB - RGB1.GetB) * A div 255;

  R := EnsureRange(R, 0, 255);
  G := EnsureRange(G, 0, 255);
  B := EnsureRange(B, 0, 255);

  Result := RGB(R, G, B);
end;

function GetMaxFontSize(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;
// Font should be set up with desired Name/Style/etc.
var
  Ext: TSize;
begin
  Result := 0;
  if Text = '' then
    Exit;

  Canvas.Font.Size := 10;
  repeat
    Canvas.Font.Size := Canvas.Font.Size + 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx >= MaxWidth) or (Ext.cy >= MaxHeight));
  repeat
    Canvas.Font.Size := Canvas.Font.Size - 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx <= MaxWidth) and (Ext.cy <= MaxHeight)) or (Canvas.Font.Size = 1);

  Result := Canvas.Font.Size;
end;

procedure PrepareCustomTitleBar(var TitleBar: TForm; const Background: TColor; Foreground: TColor);
var
  CB, CF, SCB, SCF: integer;
begin
  if GetColorLight(BackGround) < 100 then
    CB := 30
  else
    CB := -30;

  if GetColorLight(Foreground) < 100 then
    CF := 30
  else
    CF := -30;

  SCF := CF div 2;
  SCB := CF div 2;

  with TitleBar.CustomTitleBar do
    begin
      BackgroundColor := BackGround;
      InactiveBackgroundColor := BackGround;
      ButtonBackgroundColor := BackGround;
      ButtonHoverBackgroundColor := ChangeColorLight(BackGround, SCB);
      ButtonInactiveBackgroundColor := BackGround;
      ButtonPressedBackgroundColor := ChangeColorLight(BackGround, CB);

      ForegroundColor := Foreground;
      ButtonForegroundColor := Foreground;
      ButtonHoverForegroundColor := ChangeColorLight(ForeGround, SCF);
      InactiveForegroundColor := ChangeColorLight(Foreground, CF);
      ButtonInactiveForegroundColor := ChangeColorLight(Foreground, CF);
      ButtonPressedForegroundColor := ChangeColorLight(Foreground, CF);
    end;
end;

{ FXColorSet }

constructor FXColorSets.Create(FocusControl: boolean);
begin
  inherited Create;

  FAccent := DEFAULT_ACCENT_COLOR;

  FDarkForeGround := DEFAULT_DARK_FOREGROUND_COLOR;
  FLightForeGround := DEFAULT_LIGHT_FOREGROUND_COLOR;

  if FocusControl then
    begin
      FDarkBackGround := DEFAULT_DARK_BACKGROUNDCONTROL_COLOR;
      FLightBackGround := DEFAULT_LIGHT_BACKGROUNDCONTROL_COLOR;
    end
      else
    begin
      FDarkBackGround := DEFAULT_DARK_BACKGROUND_COLOR;
      FLightBackGround := DEFAULT_LIGHT_BACKGROUND_COLOR;
    end;
end;

constructor FXColorSets.Create(AOwner: TPersistent; FocusControl: boolean);
begin
  CreateOwner(AOwner);
  Create(FocusControl);
end;

procedure FXColorSets.WriteColorValue(const Index: Integer;
  const Value: TColor);
begin
  case Index of
    0: FAccent := Value;
    1: FLightBackGround := Value;
    2: FLightForeGround := Value;
    3: FDarkBackGround := Value;
    4: FDarkForeGround := Value;
  end;

  Updated;
end;

constructor FXColorSet.Create;
begin
  inherited Create;

  Accent := DEFAULT_ACCENT_COLOR;
end;

constructor FXColorSet.Create(Colors: FXColorSets; const DarkColor: boolean);
begin
  inherited Create;

  // Load Colors from a complete color set
  LoadFrom(Colors, DarkColor);
end;

constructor FXColorSet.Create(AOwner: TPersistent; Colors: FXColorSets;
  const DarkColor: boolean);
begin
  Create(Colors, DarkColor);
  CreateOwner(AOwner);
end;

procedure FXColorSet.LoadFrom(Colors: FXColorSets; const DarkColor: boolean);
begin
  Accent := Colors.Accent;

  if DarkColor then
    begin
      BackGround := Colors.DarkBackGround;
      ForeGround := Colors.DarkForeGround;
    end
      else
    begin
      BackGround := Colors.LightBackGround;
      ForeGround := Colors.LightForeGround;
    end;
end;

constructor FXColorSet.Create(AOwner: TPersistent);
begin
  Create;
  CreateOwner(AOwner);
end;

procedure FXColorSet.UpdateSource;
begin

end;

{ FXCompleteColorSets }

constructor FXCompleteColorSets.Create;
begin
  inherited Create;

  Accent := DEFAULT_ACCENT_COLOR;

  LightForeGround := DEFAULT_LIGHT_FOREGROUND_COLOR;
  LightBackGround := DEFAULT_LIGHT_BACKGROUND_COLOR;
  LightBackGroundInterior := DEFAULT_LIGHT_BACKGROUNDCONTROL_COLOR;

  DarkForeGround := DEFAULT_DARK_FOREGROUND_COLOR;
  DarkBackGround := DEFAULT_DARK_BACKGROUND_COLOR;
  DarkBackGroundInterior := DEFAULT_DARK_BACKGROUNDCONTROL_COLOR;
end;

constructor FXCompleteColorSets.Create(AOwner: TPersistent);
begin
  Create;
  CreateOwner(AOwner);
end;

procedure FXCompleteColorSets.SetDarkBackGroundInterior(const Value: TColor);
begin
  FDarkBackGroundInterior := Value;
  Updated;
end;

procedure FXCompleteColorSets.SetLightBackGroundInterior(const Value: TColor);
begin
  FLightBackGroundInterior := Value;
  Updated;
end;

{ FXPersistentColor }

procedure FXPersistentColor.Assign(Source: TPersistent);
var
  APropName: string;
  PropList: PPropList;
  PropCount, i: Integer;
begin
  if Source is FXPersistentColor then
  begin
    PropCount := GetPropList(Source.ClassInfo, tkProperties, nil);
    if PropCount > 0 then
    begin
      GetMem(PropList, PropCount * SizeOf(PPropInfo));
      try
        GetPropList(Source.ClassInfo, tkProperties, PropList);
        for i := 0 to PropCount - 1 do
          begin
            APropName := string(PropList^[i]^.Name);
            if PropertyExists(Self, APropName) then
              SetPropValue(Self, APropName, GetPropValue(Source, string(PropList^[i]^.Name)));
          end;
      finally
        FreeMem(PropList);
      end;
    end;
  end
  else
    inherited Assign(Source);
end;

constructor FXPersistentColor.CreateOwner(AOwner: TPersistent);
begin
  inherited Create;
  Owner := AOwner;
end;

procedure FXPersistentColor.SetEnabled(const Value: boolean);
begin
  if FEnable <> Value then
    begin
      FEnable := Value;
      Updated;
    end;
end;

procedure FXPersistentColor.Updated;
begin
  if (Owner <> nil) and Supports(Owner, IFXComponent) and not (csReading in TComponent(Owner).ComponentState) then
    (TComponent(Owner) as IFXComponent).UpdateTheme(true);
end;

{ FXColorStateSet }

constructor FXSingleColorStateSets.Create;
begin
  inherited Create;

  FAccent := DEFAULT_ACCENT_COLOR;

  FLightNone := DEFAULT_LIGHT_GRAY_CONTROL_COLOR;
  FLightHover := DEFAULT_LIGHT_GRAY_CONTROL_HOVER_COLOR;
  FLightPress := DEFAULT_LIGHT_GRAY_CONTROL_PRESS_COLOR;
  //
  FDarkNone := DEFAULT_DARK_GRAY_CONTROL_COLOR;
  FDarkHover := DEFAULT_DARK_GRAY_CONTROL_HOVER_COLOR;
  FDarkPress := DEFAULT_DARK_GRAY_CONTROL_PRESS_COLOR;
end;

constructor FXSingleColorStateSets.Create(AOwner: TPersistent);
begin
  CreateOwner(AOwner);
end;

function FXSingleColorStateSets.GetColor(const DarkTheme: boolean;
  State: FXControlState): TColor;
var
  ResultCode: Byte;
begin
  ResultCode := 0;
  //  Calculating color index
  if DarkTheme then
    inc(ResultCode, 3);   //  Skip 6 light color

  inc(ResultCode, Ord(State));
  //  Get color by index
  case ResultCode of
    0:
      Result := LightNone;
    1:
      Result := LightHover;
    2:
      Result := LightPress;
    3:
      Result := DarkNone;
    4:
      Result := DarkHover;
    5:
      Result := DarkPress;
    else
      Result := 0;
  end;
end;

procedure FXSingleColorStateSets.SetDarkColor(None, Hover, Press: TColor);
begin
  Updated;
end;

procedure FXSingleColorStateSets.SetLightColor(None, Hover, Press: TColor);
begin
  Updated;
end;

procedure FXSingleColorStateSets.SetStateColor(const Index: Integer; const Value: TColor);
begin
  case Index of
    0:
      if Value <> FLightNone then
        FLightNone := Value;
    1:
      if Value <> FLightHover then
        FLightHover := Value;
    2:
      if Value <> FLightPress then
        FLightPress := Value;
    3:
      if Value <> FDarkNone then
        FDarkNone := Value;
    4:
      if Value <> FDarkHover then
        FDarkHover := Value;
    5:
      if Value <> FDarkPress then
        FDarkPress := Value;
  end;
  Updated;
end;

{ FXColorStateSet }

constructor FXSingleColorStateSet.Create(ANone, AHover, APress: TColor);
begin
  inherited Create;

  LoadColors(ANone, AHover, APress);
end;

procedure FXSingleColorStateSet.CopyFrom(FromSet: FXSingleColorStateSet);
begin
  Accent := FromSet.Accent;

  None := FromSet.None;
  Hover := FromSet.Hover;
  Press := FromSet.Press;
end;

constructor FXSingleColorStateSet.Create(Colors: FXSingleColorStateSets;
  const DarkTheme: boolean);
begin
  inherited Create;

  LoadColors(Colors, DarkTheme);
end;

function FXSingleColorStateSet.GetColor(const AState: FXControlState): TColor;
begin
  Result := 0;
  case AState of
    FXControlState.None: Result := None;
    FXControlState.Hover: Result := Hover;
    FXControlState.Press: Result := Press;
  end;
end;

procedure FXSingleColorStateSet.LoadColors(Colors: FXSingleColorStateSets;
  const DarkTheme: boolean);
begin
  None := Colors.GetColor(DarkTheme, FXControlState.None);
  Hover := Colors.GetColor(DarkTheme, FXControlState.Hover);
  Press := Colors.GetColor(DarkTheme, FXControlState.Press);
end;

procedure FXSingleColorStateSet.LoadColors(ANone, AHover, APress: TColor);
begin
    None := ANone;
  Hover := AHover;
  Press := APress;
end;

procedure FXSingleColorStateSet.SetStateColor(const Index: Integer;
  const Value: TColor);
begin

end;

{ FXColorStateSet }

constructor FXColorStateSet.Create(AFrom: FXColorStateSets; const DarkColor: boolean);
begin
  LoadFrom(AFrom, DarkColor);
  inherited Create;
end;

constructor FXColorStateSet.Create;
begin
  inherited Create;
end;

function FXColorStateSet.GetColor(const Foreground: boolean;
  State: FXControlState): TColor;
var
  ResultCode: integer;
begin
  ResultCode := 0;
  //  Calculating color index
  if Foreground then
    inc(ResultCode, 3);   // Skip background color

  inc(ResultCode, Ord(State));
  //  Get color by index
  case ResultCode of
    0:
      Result := BackGroundNone;
    1:
      Result := BackGroundHover;
    2:
      Result := BackGroundPress;
    3:
      Result := ForeGroundNone;
    4:
      Result := ForeGroundHover;
    5:
      Result := ForeGroundPress;
    else
      Result := 0;
  end;
end;

procedure FXColorStateSet.LoadFrom(AFrom: FXColorStateSets;
  const DarkColor: boolean);
begin
  Accent := AFrom.Accent;
  if DarkColor then
    begin
      FBackGroundNone := AFrom.DarkBackGroundNone;
      FBackGroundHover := AFrom.DarkBackGroundHover;
      FBackGroundPress := AFrom.DarkBackGroundPress;
    end
  else
    begin
      FBackGroundNone := AFrom.LightBackGroundNone;
      FBackGroundHover := AFrom.LightBackGroundHover;
      FBackGroundPress := AFrom.LightBackGroundPress;
    end;
end;

{ FXCompleteColorSet }

constructor FXCompleteColorSet.Create(Colors: FXCompleteColorSets;
  DarkColor: boolean);
begin
  inherited Create;
  LoadFrom(Colors, DarkColor);
end;

procedure FXCompleteColorSet.LoadFrom(Colors: FXCompleteColorSets;
  const DarkColor: boolean);
begin
  // Inherited function for basic color
  LoadFrom(Colors as FXColorSets, DarkColor);

  // Get by theme for Interior
  if DarkColor then
    FBackGroundInterior := Colors.FDarkBackGroundInterior
  else
    FBackGroundInterior := Colors.LightBackGroundInterior;
end;

procedure FXCompleteColorSet.UpdateSource;
begin

end;

{ FXColorStateSets }

constructor FXColorStateSets.Create;
begin
  Accent := DEFAULT_ACCENT_COLOR;

  FDarkBackGroundNone := DEFAULT_DARK_GRAY_CONTROL_COLOR;
  FDarkBackGroundHover := DEFAULT_DARK_GRAY_CONTROL_HOVER_COLOR;
  FDarkBackGroundPress := DEFAULT_DARK_GRAY_CONTROL_PRESS_COLOR;
  FDarkForeGroundNone := DEFAULT_DARK_GRAY_CONTROL_FONT_COLOR;
  FDarkForeGroundHover := DEFAULT_DARK_GRAY_CONTROL_HOVER_FONT_COLOR;
  FDarkForeGroundPress := DEFAULT_DARK_GRAY_CONTROL_PRESS_FONT_COLOR;

  FLightBackGroundNone := DEFAULT_LIGHT_GRAY_CONTROL_COLOR;
  FLightBackGroundHover := DEFAULT_LIGHT_GRAY_CONTROL_HOVER_COLOR;
  FLightBackGroundPress := DEFAULT_LIGHT_GRAY_CONTROL_PRESS_COLOR;
  FLightForeGroundNone := DEFAULT_LIGHT_GRAY_CONTROL_FONT_COLOR;
  FLightForeGroundHover := DEFAULT_LIGHT_GRAY_CONTROL_HOVER_FONT_COLOR;
  FLightForeGroundPress := DEFAULT_LIGHT_GRAY_CONTROL_PRESS_FONT_COLOR;
end;

constructor FXColorStateSets.Create(AOwner: TPersistent);
begin
  CreateOwner(AOwner);
end;

function FXColorStateSets.GetColor(const DarkTheme, Foreground: boolean;
  State: FXControlState): TColor;
var
  ResultCode: integer;
begin
  ResultCode := 0;
  //  Calculating color index
  if Foreground then
    inc(ResultCode, 3);   // Skip background color

  if DarkTheme then
    inc(ResultCode, 6);   //  Skip light color

  inc(ResultCode, Ord(State));
  //  Get color by index
  case ResultCode of
    0:
      Result := LightBackGroundNone;
    1:
      Result := LightBackGroundHover;
    2:
      Result := LightBackGroundPress;
    3:
      Result := LightForeGroundNone;
    4:
      Result := LightForeGroundHover;
    5:
      Result := LightForeGroundPress;
    6:
      Result := DarkBackGroundNone;
    7:
      Result := DarkBackGroundHover;
    8:
      Result := DarkBackGroundPress;
    9:
      Result := DarkForeGroundNone;
    10:
      Result := DarkForeGroundHover;
    11:
      Result := DarkForeGroundPress;
    else
      Result := 0;
  end;
end;

procedure FXColorStateSets.SetStateColor(const Index: Integer;
  const Value: TColor);
begin
    case Index of
    0:
      if Value <> FLightBackGroundNone then
        FLightBackGroundNone := Value;
    1:
      if Value <> FLightBackGroundHover then
        FLightBackGroundHover := Value;
    2:
      if Value <> FLightBackGroundPress then
        FLightBackGroundPress := Value;
    3:
      if Value <> FLightForeGroundNone then
        FLightForeGroundNone := Value;
    4:
      if Value <> FLightForeGroundHover then
        FLightForeGroundHover := Value;
    5:
      if Value <> FLightForeGroundPress then
        FLightForeGroundPress := Value;
    6:
      if Value <> FDarkBackGroundNone then
        FDarkBackGroundNone := Value;
    7:
      if Value <> FDarkBackGroundHover then
        FDarkBackGroundHover := Value;
    8:
      if Value <> FDarkBackGroundPress then
        FDarkBackGroundPress := Value;
    9:
      if Value <> FDarkForeGroundNone then
        FDarkForeGroundNone := Value;
    10:
      if Value <> FDarkForeGroundHover then
        FDarkForeGroundHover := Value;
    11:
      if Value <> FDarkForeGroundPress then
        FDarkForeGroundPress := Value;
  end;

  Updated;
end;

end.

