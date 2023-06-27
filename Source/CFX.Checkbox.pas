unit CFX.Checkbox;

interface

uses
  Classes,
  Messages,
  Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Types,
  CFX.Colors,
  CFX.ThemeManager,
  CFX.Graphics,
  CFX.UIConsts,
  SysUtils,
  CFX.Classes,
  CFX.Types,
  CFX.VarHelpers,
  CFX.Linker,
  CFX.Controls;

type
  FXCheckBox = class(FXWindowsControl, FXControl)
    private
      var IconRect, TextRect: TRect;
      FTextFont, FIconFont: TFont;
      FAllowGrayed: Boolean;
      FState: FXCheckBoxState;
      FTextSpacing: Integer;
      FOnChange: TNotifyEvent;
      FCustomColors: FXColorSets;
      FIconAccentColors: FXSingleColorStateSet;
      FText: string;
      FAutomaticMouseCursor: boolean;
      FDrawColors: FXCompleteColorSet;
      FWordWrap: boolean;
      FAnimationEnabled: boolean;
      FAnimationStatus: integer;
      FAnimateTimer: TTimer;

      //  Internal
      procedure UpdateColors;
      procedure UpdateRects;

      // Set properties
      procedure SetText(const Value: string);
      procedure SetWordWrap(const Value: boolean);
      procedure SetAllowGrayed(const Value: Boolean);
      procedure SetState(const Value: FXCheckBoxState);
      procedure SetTextSpacing(const Value: Integer);
      procedure SetChecked(const Value: Boolean);

      // State
      procedure ProgressState;

      // Get properties
      function GetChecked: Boolean;

      // Handle Messages
      procedure WM_LButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
      procedure WMSize(var Message: TWMSize); message WM_SIZE;

      // Animation
      procedure AnimationProgress(Sender: TObject);

    protected
      procedure PaintBuffer; override;
      procedure Resize; override;
      procedure ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$ENDIF}); override;

      // State
      procedure InteractionStateChanged(AState: FXControlState); override;

      // Key Presses
      procedure KeyPress(var Key: Char); override;

      // Inherited Mouse Detection
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    published
      property CustomColors: FXColorSets read FCustomColors write FCustomColors stored true;
      property IconFont: TFont read FIconFont write FIconFont;
      property AllowGrayed: Boolean read FAllowGrayed write SetAllowGrayed default false;
      property State: FXCheckBoxState read FState write SetState default FXCheckBoxState.Unchecked;
      property TextSpacing: Integer read FTextSpacing write SetTextSpacing default 6;
      property Checked: Boolean read GetChecked write SetChecked default false;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property AutomaticCursorPointer: boolean read FAutomaticMouseCursor write FAutomaticMouseCursor default true;

      property Text: string read FText write SetText;
      property Font: TFont read FTextFont write FTextFont;
      property WordWrap: boolean read FWordWrap write SetWordWrap default true;

      property AnimationEnabled: boolean read FAnimationEnabled write FAnimationEnabled;

      property Align;
      property TabStop;
      property TabOrder;
      property Hint;
      property ShowHint;
      property OnEnter;
      property OnExit;
      property OnClick;
      property OnKeyDown;
      property OnKeyUp;
      property OnKeyPress;
      property OnMouseUp;
      property OnMouseDown;
      property OnMouseEnter;
      property OnMouseLeave;

      //  Modify default props
      property ParentColor default true;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      // Interface
      function IsContainer: Boolean;
      procedure UpdateTheme(const UpdateChildren: Boolean);

      function Background: TColor;
  end;

implementation

procedure FXCheckBox.InteractionStateChanged(AState: FXControlState);
begin
  inherited;
  PaintBuffer;
end;

function FXCheckBox.IsContainer: Boolean;
begin
  Result := false;
end;

procedure FXCheckBox.KeyPress(var Key: Char);
begin
  inherited;
  if (Key = #13) or (Key = #32) then
    ProgressState;
end;

procedure FXCheckBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Self.FAutomaticMouseCursor then
    if PtInRect(IconRect, Point(X, Y)) then
      Self.Cursor := crHandPoint
    else
      Self.Cursor := crDefault;
end;

procedure FXCheckBox.UpdateTheme(const UpdateChildren: Boolean);
begin
  UpdateColors;
  UpdateRects;
  Invalidate;
end;

procedure FXCheckBox.UpdateColors;
var
  AccentColor: TColor;
begin
  FDrawColors.Assign( ThemeManager.SystemColor );

  if not Enabled then
    begin
      FIconAccentColors := FXSingleColorStateSet.Create($808080,
                                ChangeColorLight($808080, ACCENT_DIFFERENTIATE_CONST),
                                ChangeColorLight($808080, -ACCENT_DIFFERENTIATE_CONST));
      FDrawColors.Foreground := $808080;
    end
  else
    begin
      // Access theme manager
      if FCustomColors.Enabled then
        begin
          // Custom Colors
          AccentColor := FCustomColors.Accent;
          FDrawColors.Foreground := ExtractColor(FCustomColors, FXColorType.Foreground);
          FDrawColors.BackGround := ExtractColor(FCustomColors, FXColorType.BackGround);
        end
      else
        begin
          // Global Colors
          AccentColor := ThemeManager.AccentColor;
          FDrawColors.ForeGround := ThemeManager.SystemColor.ForeGround;

          FDrawColors.BackGround := GetParentBackgroundColor(FDrawColors.BackGround);
        end;

      FIconAccentColors := FXSingleColorStateSet.Create(AccentColor,
                              ChangeColorLight(AccentColor, ACCENT_DIFFERENTIATE_CONST),
                              ChangeColorLight(AccentColor, -ACCENT_DIFFERENTIATE_CONST));
    end;
end;

procedure FXCheckBox.UpdateRects;
var
  AWidth: integer;
begin
  Buffer.Font.Assign(Self.Font);
  AWidth := Buffer.TextWidth(CHECKBOX_OUTLINE);

  IconRect := Rect(0, 0, AWidth + TextSpacing * 2, Height);   //  Left square
  TextRect := Rect(IconRect.Right + TextSpacing, 0, Width, Height);
end;

procedure FXCheckBox.SetAllowGrayed(const Value: Boolean);
begin
  if Value <> FAllowGrayed then
    begin
      FAllowGrayed := Value;
      if (not Value) and (FState = FXCheckBoxState.Grayed) then
        begin
          FState := FXCheckBoxState.Unchecked;
          Invalidate;
        end;
    end;
end;

procedure FXCheckBox.SetState(const Value: FXCheckBoxState);
begin
  if Value <> FState then
    begin
      // Animation
      if FAnimationEnabled
        and (Value = FXCheckBoxState.Checked) and (FState = FXCheckBoxState.Unchecked)
        and not ThemeManager.Designing and not IsReading then
          begin
            FAnimationStatus := 0;
            FAnimateTimer.Enabled := true;
          end
            else
              FAnimationStatus := 100;

      // Set
      FState := Value;
      if Assigned(FOnChange) then
        FOnChange(Self);
      Invalidate;
    end;
end;

procedure FXCheckBox.SetText(const Value: string);
begin
  if FText <> Value then
    begin
      FText := Value;

      Invalidate;
    end;
end;

procedure FXCheckBox.SetTextSpacing(const Value: Integer);
begin
  if Value <> FTextSpacing then
    begin
      FTextSpacing := Value;
      UpdateRects;
      Invalidate;
    end;
end;

procedure FXCheckBox.SetWordWrap(const Value: boolean);
begin
  if FWordWrap <> Value then
    begin
      FWordWrap := Value;

      Invalidate;
    end;
end;

procedure FXCheckBox.SetChecked(const Value: Boolean);
begin
  if Value then
    State := FXCheckBoxState.Checked
  else
    State := FXCheckBoxState.Unchecked;
end;

function FXCheckBox.GetChecked;
begin
  Result := State <> FXCheckBoxState.Unchecked;
end;

constructor FXCheckBox.Create(aOwner: TComponent);
begin
  inherited;
  FIconFont := TFont.Create;
  FIconFont.Name := ThemeManager.IconFont;
  FIconFont.Size := 14;
  FAnimationEnabled := true;

  FTextFont := TFont.Create;
  FTextFont.Name := FORM_FONT_NAME;
  FTextFont.Size := 12;

  FAnimateTimer := TTimer.Create(nil);
  with FAnimateTimer do
    begin
      Enabled := false;
      Interval := 1;
      OnTimer := AnimationProgress;
    end;

  FAllowGrayed := false;
  FState := FXCheckBoxState.Unchecked;
  FTextSpacing := 6;
  ParentColor := false;
  FAutomaticMouseCursor := false;
  TabStop := true;
  AutoFocusLine := true;
  BufferedComponent := true;
  FWordWrap := true;

  // Custom Color
  FCustomColors := FXColorSets.Create(Self);
  FIconAccentColors := FXSingleColorStateSet.Create;

  FDrawColors := FXCompleteColorSet.Create;

  FText := 'Fluent Checkbox';

  // Sizing
  Height := 30;
  Width := 180;

  // Update
  UpdateRects;
  UpdateColors;
end;

destructor FXCheckBox.Destroy;
begin
  FIconFont.Free;
  FTextFont.Free;
  FreeAndNil( FCustomColors );
  FreeAndNil( FDrawColors );
  FreeAndNil( FIconAccentColors );
  inherited;
end;

procedure FXCheckBox.AnimationProgress(Sender: TObject);
begin
  // Self
  Inc(FAnimationStatus, 5);

  Invalidate;

  if FAnimationStatus >= 100 then
    begin
      FAnimationStatus := 100;
      FAnimateTimer.Enabled := false;
    end;
end;

function FXCheckBox.Background: TColor;
begin
  Result := FDrawColors.Background;
end;

procedure FXCheckBox.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$ENDIF});
begin
  inherited;
  FIconFont.Height := MulDiv(FIconFont.Height, M, D);
  FTextSpacing := MulDiv(FTextSpacing, M, D);
  UpdateRects;
end;

procedure FXCheckBox.PaintBuffer;
var
  AText: string;
  IconFormat: TTextFormat;
  DrawFlags: FXTextFlags;
  P1, P2: TPoint;
  ALine: TLine;
begin
  if not ParentColor then
    Color := FDrawColors.Background;
  with Buffer do
    begin
      //  Paint background
      Pen.Style := psClear;
      Brush.Style := bsSolid;
      Brush.Handle := CreateSolidBrushWithAlpha(Color, 255);
      RoundRect(Rect(0, 0, Width, Height), CHECKBOX_BOX_ROUND, CHECKBOX_BOX_ROUND);

      //  Draw text
      Brush.Style := bsClear;
      Font.Assign(Self.Font);
      Font.Color := FDrawColors.Foreground;
      DrawFlags := [FXTextFlag.VerticalCenter];
      if WordWrap then
        DrawFlags := DrawFlags + [FXTextFlag.WordWrap];
      DrawTextRect(Buffer, Self.TextRect, FText, DrawFlags);

      //  Set Brush Accent Color
      Font.Assign(IconFont);
      Font.Color := FIconAccentColors.GetColor(InteractionState);

      //  Draw icon
      IconFormat := [tfVerticalCenter, tfCenter, tfSingleLine];
      case State of
        FXCheckBoxState.Checked:
          begin
            // Animate
            if FAnimationEnabled then
              begin
                AText := CHECKBOX_FILL;
                TextRect(IconRect, AText, IconFormat);

                P1 := Point(IconRect.CenterPoint.X - round(IconRect.Width / 6), IconRect.CenterPoint.Y - trunc(IconRect.Height / 18));
                P2 := Point(IconRect.CenterPoint.X - round(IconRect.Width / 12), IconRect.CenterPoint.Y + trunc(IconRect.Height / 10));

                ALine := Line(P1, P2);

                if FAnimationStatus <= 50 then
                  ALine.SetPercentage(FAnimationStatus/50*100);

                GDILine(ALine, GetRGB(FDrawColors.BackGround).MakeGDIPen(1.8));

                if FAnimationStatus > 50 then
                  begin
                    P1 := Point(IconRect.CenterPoint.X + round(IconRect.Width / 6), IconRect.CenterPoint.Y - trunc(IconRect.Height / 6));
                    ALine := Line(P2, P1);
                    ALine.SetPercentage((FAnimationStatus-50)/50 * 100);

                    GDILine(ALine, GetRGB(FDrawColors.BackGround).MakeGDIPen(1.8));
                  end;

                //TextOut(0, 0, FAnimationStatus.ToString);
              end
            else
              begin
                AText := CHECKBOX_CHECKED;
                TextRect(IconRect, AText, IconFormat);
              end;
          end;

        FXCheckBoxState.Unchecked:
          begin
            Font.Color := FDrawColors.ForeGround;
            AText := CHECKBOX_OUTLINE;
            TextRect(IconRect, AText, IconFormat);
          end;

        FXCheckBoxState.Grayed:
          begin
            AText := CHECKBOX_FILL;
            TextRect(IconRect, AText, IconFormat);

            if FAnimationEnabled then
              begin
                P1 := Point(IconRect.Left + round(3/10*IconRect.Width), IconRect.CenterPoint.Y);
                P2 := Point(IconRect.Right - round(3/10*IconRect.Width)-1, IconRect.CenterPoint.Y);
                ALine := Line(P1, P2);

                GDILine(ALine, GetRGB(FDrawColors.BackGround).MakeGDIPen(1.8));
              end
            else
              begin
                Font.Color := FDrawColors.BackGround;
                AText := CHECKBOX_GRAYED;
                TextRect(IconRect, AText, IconFormat);
              end;
          end;
      end;
    end;

  inherited;
end;

procedure FXCheckBox.ProgressState;
begin
  if AllowGrayed then
    case State of
      FXCheckBoxState.Unchecked:
        State := FXCheckBoxState.Checked;
      FXCheckBoxState.Checked:
        State := FXCheckBoxState.Grayed;
      FXCheckBoxState.Grayed:
        State := FXCheckBoxState.Unchecked;
    end
  else
    case State of
      FXCheckBoxState.Unchecked:
        State := FXCheckBoxState.Checked;
      FXCheckBoxState.Checked:
        State := FXCheckBoxState.Unchecked;
      FXCheckBoxState.Grayed:
        State := FXCheckBoxState.Unchecked;
    end;
end;

procedure FXCheckBox.Resize;
begin
  inherited;
  UpdateRects;
end;

procedure FXCheckBox.WMSize(var Message: TWMSize);
begin
  UpdateRects;
  Invalidate;
end;

procedure FXCheckBox.WM_LButtonUp(var Msg: TWMLButtonUp);
begin
  if not Enabled then exit;

  ProgressState;
  inherited;
end;

end.
