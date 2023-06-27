unit CFX.BlurMaterial;

interface

uses
  SysUtils,
  Winapi.Windows,
  Classes,
  Types,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  CFX.Graphics,
  CFX.VarHelpers,
  Vcl.Forms,
  Messaging,
  DateUtils,
  System.Threading,
  System.Win.Registry,
  IOUtils,
  CFX.Utilities,
  CFX.ThemeManager,
  CFX.Classes,
  CFX.Math,
  CFX.GDI,
  CFX.Colors,
  CFX.Types,
  CFX.Linker,
  Vcl.Imaging.GIFImg,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg;

type
  FXBlurMaterial = class(TGraphicControl, FXControl)
  private
    FPicture: TPicture;
    FIncrementalDisplay: Boolean;
    FRefreshMode: FXGlassRefreshMode;
    Tick: TTimer;
    FDrawing: Boolean;
    FInvalidateAbove: boolean;
    FVersion: FXBlurVersion;
    FOnPaint: FXControlOnPaint;

    FDarkTintOpacity,
    FWhiteTintOpacity: integer;

    FCustomColors: FXColorSets;
    FDrawColors: FXColorSet;

    FEnableTinting: boolean;

    procedure TimerExecute(Sender: TObject);
    procedure SetRefreshMode(const Value: FXGlassRefreshMode);
    procedure PictureChanged(Sender: TObject);
    procedure SetPicture(const Value: TPicture);
    procedure SetVersion(const Value: FXBlurVersion);

    function ImageTypeExists(ImgType: FXBlurVersion): boolean;
    procedure SetTinting(const Value: boolean);
    procedure SetDarkTint(const Value: integer);
    procedure SetWhiteTint(const Value: integer);
    procedure SetCustomColor(const Value: FXColorSets);

    procedure CustomColorGet;

  protected
    function DestRect: TRect;
    procedure Paint; override;

    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
    procedure FindGraphicClass(Sender: TObject; const Context: TFindGraphicClassContext;
      var GraphicClass: TGraphicClass); dynamic;


    procedure OnVisibleChange(var Message : TMessage); message CM_VISIBLECHANGED;

  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Picture: TPicture read FPicture write SetPicture;
    property Version: FXBlurVersion read FVersion write SetVersion;
    property RefreshMode: FXGlassRefreshMode read FRefreshMode write SetRefreshMode;
    property InvalidateAbove: boolean read FInvalidateAbove write FInvalidateAbove;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Touch;
    property Visible;
    property OnClick;

    property EnableTinting: boolean read FEnableTinting write SetTinting;
    property DarkTintOpacity: integer read FDarkTintOpacity write SetDarkTint;
    property WhiteTintOpacity: integer read FWhiteTintOpacity write SetWhiteTint;

    property CustomColors: FXColorSets read FCustomColors write SetCustomColor;
    property OnPaint: FXControlOnPaint read FOnPaint write FOnPaint;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateControl;
    procedure Inflate(up,right,down,lft: integer);

    procedure FormMoveSync;

    procedure SyncroniseImage;
    procedure RebuildImage;
    procedure ReDraw;

    function GetCanvas: TCanvas;

    // Interface
    function IsContainer: Boolean;
    procedure UpdateTheme(const UpdateChildren: Boolean);

    function Background: TColor;
  end;

  procedure GetWallpaper;
  procedure GetBlurredScreen(darkmode: boolean);
  function GetWallpaperName(ScreenIndex: integer; TranscodedDefault: boolean = false): string;
  function GetWallpaperSize: integer;
  function GetWallpaperSetting: TWallpaperSetting;
  function GetCurrentExtension: string;
  procedure CreateBySignature(var Wallpaper: TGraphic; Sign: TFileType);
  procedure CreateByExtension(var Wallpaper: TGraphic; Extension: string);

var
  WorkingAP: boolean;
  Wallpaper: TBitMap;
  WallpaperBMP: TBitMap;
  WallpaperBlurred: TBitMap;
  ScreenshotBlurred: TBitMap;


  LastDetectedFileSize: integer;
  LastSyncTime: TDateTime;

implementation

function GetWallpaperSize: integer;
begin
  Result := GetFileSize( GetWallpaperName(999) );
end;

function GetWallpaperSetting: TWallpaperSetting;
var
  R: TRegistry;
  Value: integer;
  TileWallpaper: boolean;
begin
  // Create registry
  R := TRegistry.Create(KEY_READ);
  Result := TWallpaperSetting.Stretch;
  R.RootKey := HKEY_CURRENT_USER;
  try
    if R.OpenKeyReadOnly('Control Panel\Desktop') then
      begin
        Value := R.ReadString('WallpaperStyle').ToInteger;
        TileWallpaper := R.ReadString('TileWallpaper').ToBoolean;

        // Clear String
        case Value of
          0: if TileWallpaper then
              Result := TWallpaperSetting.Tile
                else
                  Result := TWallpaperSetting.Center;
          2: Result := TWallpaperSetting.Stretch;
          6: Result := TWallpaperSetting.Fit;
          10: Result := TWallpaperSetting.Fill;
          22: Result := TWallpaperSetting.Span;
          else Result := TWallpaperSetting.Stretch;
        end;
      end;
  finally
    // Free Memory
    R.Free;
  end;
end;

function GetWallpaperName(ScreenIndex: integer; TranscodedDefault: boolean): string;
begin
  if GetNTKernelVersion <= 6.1 then
    Result := GetUserShellLocation(FXUserShell.AppData) + '\Microsoft\Windows\Themes\TranscodedWallpaper.jpg'
  else
    begin
      Result := GetUserShellLocation(FXUserShell.AppData) + '\Microsoft\Windows\Themes\Transcoded_' +
        IntToStrIncludePrefixZeros(ScreenIndex, 3);

      if TranscodedDefault or not TFile.Exists(Result) then
        Result := GetUserShellLocation(FXUserShell.AppData) + '\Microsoft\Windows\Themes\TranscodedWallpaper';
    end;
end;

procedure GetWallpaper;
var
  Filename: string;

  DestRect: TRect;

  DRects: TArray<TRect>;

  DeskRect,
  MonitorRect: TRect;

  I, J, OffsetX, OffsetY: integer;

  Extension: string;

  TranscodedDefault: boolean;

  WallpaperSetting: TWallpaperSetting;
  DrawMode: FXDrawMode;

  BitMap: TBitMap;
begin
  if WorkingAP then
    Exit;

  // Windows Xp and below compatability
  if GetNTKernelVersion <= 5.2 then
    Exit;

  // Working
  WorkingAP := true;

  // Get Rects
  DeskRect := Screen.DesktopRect;

  OffsetX := abs(Screen.DesktopRect.Left);
  OffsetY := abs(Screen.DesktopRect.Top);

  // Create Images
  WallpaperBlurred := TBitMap.Create(DeskRect.Width, DeskRect.Height);

  WallpaperBlurred.Canvas.Brush.Color := clBlack;
  WallpaperBlurred.Canvas.FillRect(WallpaperBlurred.Canvas.ClipRect);

  // Prepare
  WallpaperSetting := GetWallpaperSetting;

  TranscodedDefault := Screen.MonitorCount = 1;

  // Rects Draw Mode
  case WallpaperSetting of
    TWallpaperSetting.Fill: DrawMode := FXDrawMode.Center3Fill;
    TWallpaperSetting.Fit: DrawMode := FXDrawMode.CenterFit;
    TWallpaperSetting.Stretch: DrawMode := FXDrawMode.Stretch;
    TWallpaperSetting.Tile: DrawMode := FXDrawMode.Tile;
    TWallpaperSetting.Center: DrawMode := FXDrawMode.Center;
    TWallpaperSetting.Span: DrawMode := FXDrawMode.CenterFill;
    else DrawMode := FXDrawMode.Stretch;
  end;

  if WallpaperSetting = TWallpaperSetting.Span then
    // Fill Image with Wallpaper
    begin
      // Single-File Extension
      Extension := GetCurrentExtension;

      // Get Transcoded
      CreateByExtension( TGraphic(Wallpaper), Extension );
      FileName := GetWallpaperName(0);

      if not fileexists(FileName) then
        Exit;

      Wallpaper.LoadFromFile(FileName);
      DrawImageInRect(WallpaperBlurred.Canvas, WallpaperBlurred.Canvas.ClipRect, Wallpaper, FXDrawMode.CenterFill);
    end
  else
    // Complete Desktop Puzzle
    for I := 0 to Screen.MonitorCount - 1 do
      begin
        // Get Transcoded
		FileName := GetWallpaperName(Screen.Monitors[I].MonitorNum, TranscodedDefault); 

        if not fileexists(FileName) then
          Break;

		// Create Extension
        CreateBySignature( TGraphic(Wallpaper), ReadFileSignature(FileName) );

        // Load
        try
          Wallpaper.LoadFromFile(FileName);
        except
          Break;
        end;

        // Draw Monitor
        MonitorRect := Screen.Monitors[I].BoundsRect;

        DestRect := MonitorRect;
        DestRect.Offset(OffsetX, OffsetY);

        DRects := GetDrawModeRects(DestRect, Wallpaper, DrawMode);

        // Draw
        if WallpaperSetting in [TWallpaperSetting.Fit, TWallpaperSetting.Stretch] then
          for J := 0 to High(DRects) do
            WallpaperBlurred.Canvas.StretchDraw(DRects[J], Wallpaper, 255)
          else
            begin
              Bitmap := TBitMap.Create(DestRect.Width, DestRect.Height);
              for J := 0 to High(DRects) do
                begin
                  DRects[J].Offset(-DestRect.Left, -DestRect.Top);

                  Bitmap.Canvas.StretchDraw(DRects[J], Wallpaper, 255)
                end;

              WallpaperBlurred.Canvas.StretchDraw(DestRect, Bitmap, 255)
            end;
      end;

  WallpaperBMP := TBitMap.Create(DeskRect.Width, DeskRect.Height);
  WallpaperBMP.Assign( WallpaperBlurred );

  // Blur
  FastBlur(WallpaperBlurred, 8, 10, false); // 8 16

  // Get Size
  LastDetectedFileSize := GetWallpaperSize;
  LastSyncTime := Now;

  // Finish Work
  WorkingAP := false;
end;

procedure GetBlurredScreen(darkmode: boolean);
begin
  // Working
  WorkingAP := true;

  // Get Screenshot
  ScreenshotBlurred := TBitMap.Create;
  QuickScreenShot( ScreenshotBlurred );

  // Effects
  FastBlur(ScreenshotBlurred, 3, 8, false);

  // Time
  LastSyncTime := Now;

  // Finish
  WorkingAP := false;
end;

function GetCurrentExtension: string;
var
  R: TRegistry;
  Bytes: TBytes;
begin
  // Windows7
  if GetNTKernelVersion <= 6.1 then
    Exit('.jpeg');

  // Create registry
  R := TRegistry.Create(KEY_READ);

  R.RootKey := HKEY_CURRENT_USER;
  try
    if R.OpenKeyReadOnly('Control Panel\Desktop') then
      begin
        SetLength(Bytes, R.GetDataSize('TranscodedImageCache'));
        R.ReadBinaryData('TranscodedImageCache', Pointer(Bytes)^, Length(Bytes));

        // Clear String
        Result := ExtractFileName( TEncoding.ASCII.GetString(Bytes) );
        Result := AnsiLowerCase( Trim( ExtractFileExt( Result ) ).Replace(#0, '') );
      end;
  finally
    // Free Memory
    R.Free;
  end;
end;

procedure CreateBySignature(var Wallpaper: TGraphic; Sign: TFileType);
begin
  case Sign of
    { Png }
    TFileType.PNG: Wallpaper := TPngImage.Create;

    { Jpeg }
    TFileType.JPEG: Wallpaper := TJpegImage.Create;

    { Gif }
    TFileType.GIF: Wallpaper := TGifImage.Create;

    { Heif? }
    //dftHEIF: ;

    { Default }
    else Wallpaper := TBitMap.Create;
  end;
end;

procedure CreateByExtension(var Wallpaper: TGraphic; Extension: string);
begin
  { Jpeg }
  if (Extension = '.jpg') or (Extension = '.jpeg') then
    Wallpaper := TJpegImage.Create
      else
        { Png }
        if Extension = '.png' then
          Wallpaper := TPngImage.Create
          else
            { Gif }
            if Extension = '.gif' then
              Wallpaper := TGifImage.Create
                else
                  { Bitmap }
                  if Extension = '.bmp' then
                    Wallpaper := TBitMap.Create
                      else
                        { Default }
                        Wallpaper := TJpegImage.Create;
end;


{ FXBlurMaterial }

function FXBlurMaterial.Background: TColor;
begin
  Result := FDrawColors.Background;
end;

constructor FXBlurMaterial.Create(AOwner: TComponent);
begin
  inherited;
  //interceptmouse:=True;

  FCustomColors := FXColorSets.Create(false);
  with FCustomColors do
    begin
      DarkBackground := clBlack;
      LightBackground := clWhite;
      Accent := ThemeManager.AccentColor;
    end;

  FDrawColors := FXColorSet.Create;

  // Picture
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FPicture.OnProgress := Progress;
  FPicture.OnFindGraphicClass := FindGraphicClass;

  ControlStyle := ControlStyle + [csReplicatable, csPannable];

  // Timer
  Tick := TTimer.Create(Self);
  with Tick do
    begin
      Interval := 1;
      Enabled := false;
      OnTimer := TimerExecute;
    end;

  // Settings
  FInvalidateAbove := false;

  FVersion := FXBlurVersion.WallpaperBlurred;

  CustomColorGet;

  // Size
  Width := 150;
  Height := 200;

  // Tintin
  FEnableTinting := true;

  FWhiteTintOpacity := 200;
  FDarkTintOpacity := 75;
end;

procedure FXBlurMaterial.CustomColorGet;
begin
  if CustomColors.Enabled then
    begin
      FDrawColors := FXColorSet.Create(CustomColors, ThemeManager.DarkTheme);
    end
  else
    begin
      FDrawColors.Accent := ThemeManager.AccentColor;

      if ThemeManager.DarkTheme then
        FDrawColors.BackGround := clBlack
      else
        FDrawColors.BackGround := clWhite;
    end;
end;

function FXBlurMaterial.DestRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
end;

destructor FXBlurMaterial.Destroy;
begin
  FPicture.Free;

  Tick.Enabled := false;
  FreeAndNil(Tick);
  FreeAndNil(FCustomColors);
  inherited;
end;


procedure FXBlurMaterial.FindGraphicClass(Sender: TObject;
  const Context: TFindGraphicClassContext; var GraphicClass: TGraphicClass);
begin

end;

procedure FXBlurMaterial.FormMoveSync;
begin
  SyncroniseImage;
end;

function FXBlurMaterial.GetCanvas: TCanvas;
begin
  Result := Self.Canvas;
end;

function FXBlurMaterial.ImageTypeExists(ImgType: FXBlurVersion): boolean;
begin
  Result := false;
  case ImgType of
    FXBlurVersion.WallpaperBlurred: Result := (WallpaperBlurred  <> nil) and (not WallpaperBlurred.Empty);
    FXBlurVersion.Wallpaper: Result := (WallpaperBMP  <> nil) and (not WallpaperBMP.Empty);
    FXBlurVersion.Screenshot: Result := (ScreenshotBlurred  <> nil) and (not ScreenshotBlurred.Empty);
  end;
end;

procedure FXBlurMaterial.Inflate(up, right, down, lft: integer);
begin
  //UP
  Top := Top - Up;
  Height := Height + Up;
//RIGHT
  Width := Width + right;
//DOWN
  Height := Height + down;
//LEFT
  Left := Left - lft;
  Width := Width + lft;
end;

procedure FXBlurMaterial.InvalidateControl;
begin
  Self.Invalidate;

  Paint;
end;

function FXBlurMaterial.IsContainer: Boolean;
begin
  Result := false;
end;

procedure FXBlurMaterial.OnVisibleChange(var Message: TMessage);
begin
  if Self.Visible then
    SyncroniseImage;
end;

procedure FXBlurMaterial.Paint;
var
  Save: Boolean;
  Pict: TBitMap;
  DrawRect, ImageRect: Trect;
begin
  // Disable Timer After Successfull Draw
  if (not ImageTypeExists(Version)) and (not (csDesigning in ComponentState)) then
    Tick.Enabled := RefreshMode = FXGlassRefreshMode.Timer;

  // Draw
  if csDesigning in ComponentState then
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;

  Save := FDrawing;
  FDrawing := True;
  try
      with inherited Canvas do
        begin
          // Draw Canvas
          { Image Draw }

          if (WorkingAP) or not ImageTypeExists(Version) then
            begin
              Brush.Color := FDrawColors.BackGround;
              FillRect(ClipRect);

              Exit;
            end;

          DrawRect := Rect(0, 0, Width, Height);

          ImageRect := ClientToScreen( ClientRect );
          ImageRect.Offset(Screen.DesktopRect.Left * -1, Screen.DesktopRect.Top * -1);

          // Calc Rect
          {PictureRect.Top := trunc((ImageRect.Top * WallpaperBlurred.Height) / Screen.Height);
          PictureRect.Left := trunc((ImageRect.Left * WallpaperBlurred.Width) / Screen.Width);
          PictureRect.Bottom := trunc((ImageRect.Bottom * WallpaperBlurred.Height) / Screen.Height);
          PictureRect.Right := trunc((ImageRect.Right * WallpaperBlurred.Width) / Screen.Width);    }

          // Create Picture
          Pict := TBitMap.Create(Width, Height);

          // Copy Rect
          case Version of
            FXBlurVersion.WallpaperBlurred: Pict.Canvas.CopyRect(DrawRect, WallpaperBlurred.Canvas, ImageRect);
            FXBlurVersion.Wallpaper: Pict.Canvas.CopyRect(DrawRect, WallpaperBMP.Canvas, ImageRect);
            FXBlurVersion.Screenshot: Pict.Canvas.CopyRect(DrawRect, ScreenshotBlurred.Canvas, ImageRect);
          end;

          // Draw
          FPicture.Bitmap.Assign(Pict);

          DrawHighQuality(DestRect, FPicture.Graphic, 255, false);

          Pict.Free;

          // Tint Item
          if EnableTinting then
            if ThemeManager.DarkTheme then
              GDITint( ClipRect, FDrawColors.BackGround, FDarkTintOpacity )
            else
              GDITint( ClipRect, FDrawColors.BackGround, FWhiteTintOpacity );
        end;
  finally
    FDrawing := Save;

    // Notify
    if Assigned(FOnPaint) then
      FOnPaint( Self );
  end;
end;

procedure FXBlurMaterial.PictureChanged(Sender: TObject);
var
  G: TGraphic;
  D : TRect;
begin
  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if TLinkObservers.EditLinkEdit(Observers) then
      TLinkObservers.EditLinkModified(Observers);

  if AutoSize and (Picture.Width > 0) and (Picture.Height > 0) then
	SetBounds(Left, Top, Picture.Width, Picture.Height);
  G := Picture.Graphic;
  if G <> nil then
  begin
    if Assigned(Picture.Graphic) and not ((Picture.Graphic is TMetaFile) or (Picture.Graphic is TIcon)) then
      G.Transparent := false;
    D := DestRect;
    if (not G.Transparent) and (D.Left <= 0) and (D.Top <= 0) and
       (D.Right >= Width) and (D.Bottom >= Height) then
      ControlStyle := ControlStyle + [csOpaque]
    else  // picture might not cover entire clientrect
      ControlStyle := ControlStyle - [csOpaque];

  end
  else ControlStyle := ControlStyle - [csOpaque];
  if not FDrawing then Invalidate;

  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if TLinkObservers.EditLinkIsEditing(Observers) then
      TLinkObservers.EditLinkUpdate(Observers);
end;

procedure FXBlurMaterial.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
if FIncrementalDisplay and RedrawNow then
  begin
    Paint;
  end;
end;

procedure FXBlurMaterial.RebuildImage;
begin
  case Version of
    FXBlurVersion.WallpaperBlurred, FXBlurVersion.Wallpaper: GetWallpaper;
    FXBlurVersion.Screenshot: GetBlurredScreen( ThemeManager.DarkTheme );
  end;
end;

procedure FXBlurMaterial.ReDraw;
begin
  PictureChanged(Self);
end;

procedure FXBlurMaterial.SetCustomColor(const Value: FXColorSets);
begin
  FCustomColors := Value;

  UpdateTheme(false);
end;

procedure FXBlurMaterial.SetDarkTint(const Value: integer);
begin
  FDarkTintOpacity := Value;

  Paint;
end;

procedure FXBlurMaterial.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure FXBlurMaterial.SetRefreshMode(const Value: FXGlassRefreshMode);
begin
  FRefreshMode := Value;

  if not (csDesigning in ComponentState) then
    Tick.Enabled := Value = FXGlassRefreshMode.Timer;
end;

procedure FXBlurMaterial.SetTinting(const Value: boolean);
begin
  FEnableTinting := Value;

  Paint;
end;

procedure FXBlurMaterial.SetVersion(const Value: FXBlurVersion);
begin
  FVersion := Value;

  Paint;
end;

procedure FXBlurMaterial.SetWhiteTint(const Value: integer);
begin
  FWhiteTintOpacity := Value;

  Paint;
end;

procedure FXBlurMaterial.SyncroniseImage;
begin
  // Paint
  ReDraw;

  // Check for different wallpaper
  case Version of
    FXBlurVersion.WallpaperBlurred, FXBlurVersion.Wallpaper: if (GetWallpaperSize <> LastDetectedFileSize) then
      RebuildImage;
    FXBlurVersion.Screenshot: if (ScreenshotBlurred = nil) or (SecondsBetween(LastSyncTime, Now) > 1) then
      RebuildImage;
  end;

  // Full Redraw
  if FInvalidateAbove then
    Invalidate;
end;

procedure FXBlurMaterial.TimerExecute(Sender: TObject);
begin
  if not IsDesigning then
    SyncroniseImage;
end;

procedure FXBlurMaterial.UpdateTheme(const UpdateChildren: Boolean);
begin
  CustomColorGet;

  if not (csReadingState in ControlState) then
    RebuildImage;
end;

end.
