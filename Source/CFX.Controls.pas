unit CFX.Controls;

interface
  uses
    Winapi.Windows, Vcl.Graphics, Classes, Types, Winapi.Messages, CFX.Types,
    CFX.UIConsts, SysUtils, CFX.Graphics, CFX.VarHelpers, CFX.ThemeManager,
    Vcl.Controls, CFX.PopupMenu, CFX.Linker;

  type
    // Control
    FXWindowsControl = class(TCustomControl)
    private
      FPopupMenu: FXPopupMenu;
      FBuffer: TBitMap;
      FBufferedComponent: boolean;
      FFocusRect: TRect;
      FAutoFocusLine: boolean;
      FHasEnteredTab: boolean;
      FInteraction: FXControlState;
      FAutoFocus: boolean;

      // Events
      procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;

      // Data
      procedure ResizeBuffer;
      function GetBuffer: TCanvas;
      function CanDrawFocusLine: boolean;
      procedure SetState(const Value: FXControlState);

    protected
      // Paint
      procedure WMSize(var Message: TWMSize); message WM_SIZE;

      procedure Resize; override;

      procedure SolidifyBuffer;

      procedure Paint; override;
      procedure PaintBuffer; virtual;

      // Focus Line and Events
      procedure DoEnter; override;
      procedure DoExit; override;

      property FocusRect: TRect read FFocusRect write FFocusRect;
      property AutoFocusLine: boolean read FAutoFocusLine write FAutoFocusLine;
      property AutoFocus: boolean read FAutoFocus write FAutoFocus;

      // Mouse Events
      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;

      // Key Events
      procedure DialogKey(var Msg: TWMKey); message CM_DIALOGKEY;

      // Interaction
      procedure InteractionStateChanged(AState: FXControlState); virtual;

      // Utilities
      function IsReading: boolean;
      function IsDesigning: boolean;

      // Interact State
      property InteractionState: FXControlState read FInteraction write SetState;

      // Draw Buffer
      property Buffer: TCanvas read GetBuffer;
      property BufferedComponent: boolean read FBufferedComponent write FBufferedComponent;

    published
      // Popup Menu
      property PopupMenu: FXPopupMenu read FPopupMenu write FPopupMenu;

      property Enabled;

    public
      // Constructors
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Parent Utilities
      function GetParentBackgroundColor(Default: TColor): TColor;

      // Invalidate
      procedure Invalidate; override;

    end;

    FXGraphicControl = class(TGraphicControl)
    private
      FPopupMenu: FXPopupMenu;
      FInteraction: FXControlState;
      FTransparent: boolean;

      procedure SetState(const Value: FXControlState);
      procedure SetTransparent(const Value: boolean);

    protected
      // Mouse Events
      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;

      // Interaction
      procedure InteractionStateChanged(AState: FXControlState); virtual;

      // Utilities
      function IsReading: boolean;

      // Interact State
      property InteractionState: FXControlState read FInteraction write SetState;

      // Transparent
      property Transparent: boolean read FTransparent write SetTransparent default true;

    published
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Popup Menu
      property PopupMenu: FXPopupMenu read FPopupMenu write FPopupMenu;

    public
      // Parent Utilities
      function GetParentBackgroundColor(Default: TColor): TColor;

    end;

implementation

{ FXTransparentControl }

function FXWindowsControl.CanDrawFocusLine: boolean;
begin
  Result := AutoFocusLine and Focused and FHasEnteredTab and not IsDesigning;
end;

procedure FXWindowsControl.CMMouseEnter(var Message: TMessage);
begin
  InteractionState := FXControlState.Hover;

  if Assigned(OnMouseEnter) then
    OnMouseenter(Self);
end;

procedure FXWindowsControl.CMMouseLeave(var Message: TMessage);
begin
  InteractionState := FXControlState.None;

  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

constructor FXWindowsControl.Create(AOwner: TComponent);
begin
  inherited;
  //InterceptMouse := true;
  FBufferedComponent := true;
  FAutoFocusLine := false;
  FAutoFocus := true;
  ParentColor := false;

  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse];
  Brush.Style := bsClear;

  FBuffer := TBitMap.Create;
  ResizeBuffer;
end;

destructor FXWindowsControl.Destroy;
begin
  FreeAndNil(FBuffer);
  inherited;
end;

procedure FXWindowsControl.DialogKey(var Msg: TWMKey);
begin
  if not (Msg.CharCode in [VK_DOWN, VK_UP, VK_RIGHT, VK_LEFT]) then
    inherited;
end;

procedure FXWindowsControl.DoEnter;
begin
  inherited;
  if AutoFocusLine and (InteractionState <> FXControlState.Press) then
    begin
      FHasEnteredTab := true;
      Paint;
    end;
end;

procedure FXWindowsControl.DoExit;
begin
  inherited;
  if AutoFocusLine then
    begin
      FHasEnteredTab := false;
      Paint;
    end;
end;

function FXWindowsControl.GetBuffer: TCanvas;
begin
  Result := FBuffer.Canvas;
end;

function FXWindowsControl.GetParentBackgroundColor(Default: TColor): TColor;
begin
  if (Parent <> nil) and Supports(Parent, FXControl) then
    Result := (Parent as FXControl).Background
      else
        Result := Default;
end;

procedure FXWindowsControl.InteractionStateChanged(AState: FXControlState);
begin
  Paint;
end;

procedure FXWindowsControl.Invalidate;
begin
  inherited;
  if BufferedComponent then
    with Buffer do
      begin
        ResizeBuffer;
        SolidifyBuffer;
        PaintBuffer;
      end;
end;

function FXWindowsControl.IsDesigning: boolean;
begin
  Result := csDesigning in ComponentState;
end;

function FXWindowsControl.IsReading: boolean;
begin
  Result := csReading in ComponentState;
end;

procedure FXWindowsControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited;
  // State
  if (InteractionState = FXControlState.Hover) and (Button = mbLeft) then
    InteractionState := FXControlState.Press;

  // Focus
  if (InteractionState = FXControlState.Press) and not Focused then
    SetFocus;

  // Entered
  if FHasEnteredTab then
    begin
      FHasEnteredTab := false;
      if AutoFocusLine then
        Paint;
    end;
end;

procedure FXWindowsControl.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited;
  InteractionState := FXControlState.Hover;

  // Popup Menu
  if (Button = mbRight) and Assigned(PopupMenu) then
    FPopupMenu.PopupAtPoint( ClientToScreen(Point(X,Y)) );
end;

procedure FXWindowsControl.Paint;
begin
  inherited;
  if BufferedComponent then
    begin
      // Reset Color
      Buffer.Brush.Color := Color;

      // Draw Buffer
      Canvas.Draw(0, 0, FBuffer);
    end;

  // Focus Line
  if CanDrawFocusLine then
    begin
      FocusRect := Self.ClientRect;

      FFocusRect.Right := FocusRect.Right - FOCUS_LINE_SIZE;
      FFocusRect.Bottom := FocusRect.Bottom - FOCUS_LINE_SIZE;

      Canvas.GDIRoundRect(MakeRoundRect(FocusRect, FOCUS_LINE_ROUND, FOCUS_LINE_ROUND),
        nil,
        GetRGB(ThemeManager.SystemColor.ForeGround).MakeGDIPen(FOCUS_LINE_SIZE))
    end;
end;

procedure FXWindowsControl.PaintBuffer;
begin
  // Paint
  Paint;
end;

procedure FXWindowsControl.Resize;
begin
  inherited;
  PaintBuffer;
end;

procedure FXWindowsControl.ResizeBuffer;
begin
  if BufferedComponent then
    begin
      if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
        FBuffer.SetSize(Width, Height);
    end;
end;

procedure FXWindowsControl.SetState(const Value: FXControlState);
begin
  if Value <> FInteraction then
    begin
      FInteraction := Value;

      InteractionStateChanged(Value);
    end;
end;

procedure FXWindowsControl.SolidifyBuffer;
begin
  with Buffer do
    begin
      // Reset Color
      Brush.Color := Color;

      // Clear
      FillRect(ClipRect);
    end;
end;

procedure FXWindowsControl.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := 0;
  inherited;
end;

procedure FXWindowsControl.WMSize(var Message: TWMSize);
begin
  ResizeBuffer;
  SolidifyBuffer;
  PaintBuffer;
end;

{ FXGraphicControl }

procedure FXGraphicControl.CMMouseEnter(var Message: TMessage);
begin
  InteractionState := FXControlState.Hover;

  if Assigned(OnMouseEnter) then
    OnMouseenter(Self);
end;

procedure FXGraphicControl.CMMouseLeave(var Message: TMessage);
begin
  InteractionState := FXControlState.None;

  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

constructor FXGraphicControl.Create(AOwner: TComponent);
begin
  inherited;
  FTransparent := true;
end;

destructor FXGraphicControl.Destroy;
begin
  inherited;
end;

function FXGraphicControl.GetParentBackgroundColor(Default: TColor): TColor;
begin
  if (Parent <> nil) and Supports(Parent, FXControl) then
    Result := (Parent as FXControl).Background
      else
        Result := Default;
end;

procedure FXGraphicControl.InteractionStateChanged(AState: FXControlState);
begin
  Paint;
end;

function FXGraphicControl.IsReading: boolean;
begin
  Result := csReading in ComponentState;
end;

procedure FXGraphicControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
begin
  inherited;
  // State
  if (InteractionState = FXControlState.Hover) and (Button = mbLeft) then
    InteractionState := FXControlState.Press;
end;

procedure FXGraphicControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  InteractionState := FXControlState.Hover;

  // Popup Menu
  if (Button = mbRight) and Assigned(PopupMenu) then
    FPopupMenu.PopupAtPoint( ClientToScreen(Point(X,Y)) );
end;

procedure FXGraphicControl.SetState(const Value: FXControlState);
begin
  if Value <> FInteraction then
    begin
      FInteraction := Value;

      InteractionStateChanged(Value);
    end;
end;

procedure FXGraphicControl.SetTransparent(const Value: boolean);
begin
  if FTransparent <> Value then
    begin
      FTransparent := Value;

      if not IsReading then
        RePaint;
    end;
end;

end.
