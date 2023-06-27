unit CFX.Graphics;

interface

uses
  UITypes, Types, CFX.UIConsts, VCl.GraphUtil, Winapi.Windows,
  Classes, Vcl.Themes, Vcl.Controls, Vcl.Graphics,
  CFX.VarHelpers, CFX.Types, CFX.BlurFunctions, Math,
  CFX.StringUtils;

  type
    TPent = array[0..4] of TPoint;

  // Graphic Utilities
  procedure GetCenterPos(Width, Height: Integer; Rect: TRect; out X, Y: Integer);
  function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;

  // Text Draw Functions
  procedure DrawTextRect(Canvas: TCanvas; ARect: TRect; Text: string;
    Flags: FXTextFlags; AMargin: integer = 0);
  function GetMaxFontHeight(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;

  // Drawing Functions
  procedure DrawBorder(const Canvas: TCanvas; R: TRect; Color: TColor;
                       Thickness: Byte; Roundness: integer = 10);
  procedure CopyRoundRect(FromCanvas: TCanvas; FromRect: TRoundRect;
                          DestCanvas: TCanvas; DestRect: TRect;
                          shrinkborder: integer = 0);

  // Draw Rectangles
  function GetDrawModeRects(Rect: TRect; Image: TGraphic; DrawMode: FXDrawMode; ImageMargin:
                            integer = 0): TArray<TRect>;
  function GetDrawModeRect(Rect: TRect; Image: TGraphic; DrawMode: FXDrawMode;
                            ImageMargin: integer = 0): TRect;
  procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
                            DrawMode: FXDrawMode; ImageMargin: integer = 0);

  // Gradient
  procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
  procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);

  // Bitmap Manipulation
  procedure FastBlur(Bitmap: TBitmap; Radius: Real; BlurScale: Integer; HighQuality: Boolean = True);

const
  HAlignments: Array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
  VAlignments: Array[TVerticalAlignment] of Longint = (DT_TOP, DT_BOTTOM, DT_VCENTER);

implementation

procedure GetCenterPos(Width, Height: Integer; Rect: TRect; out X, Y: Integer);
begin
  X := Rect.Left + (Rect.Width - Width) div 2;
  Y := Rect.Top + (Rect.Height - Height) div 2;
end;

function GetDrawModeRects(Rect: TRect; Image: TGraphic; DrawMode: FXDrawMode; ImageMargin: integer): TArray<TRect>;
var
  A, B, C: real;
  TMPRect: TRect;
  I, W, H: Integer;
begin
  if Image.Empty then
    Exit;

  SetLength(Result, 1);
  if Image <> nil then
  case DrawMode of

    // Fill
    FXDrawMode.Fill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);
    end;

    // Fit
    FXDrawMode.Fit: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B > Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);
    end;

    // Stretch
    FXDrawMode.Stretch: begin
      Result[0] := Rect;
    end;

    // Center
    FXDrawMode.Center: begin
      Result[0].Left := Rect.CenterPoint.X - Image.Width div 2;
      Result[0].Right := Rect.CenterPoint.X + Image.Width div 2;

      Result[0].Top := Rect.CenterPoint.Y - Image.Height div 2;
      Result[0].Bottom := Rect.CenterPoint.Y + Image.Height div 2;
    end;

    // Center Fill
    FXDrawMode.CenterFill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left - (W - Rect.Width) div 2;
      Result[0].Right := Result[0].Right - (W - Rect.Width) div 2;
      Result[0].Top := Result[0].Top - (H - Rect.Height) div 2;
      Result[0].Bottom := Result[0].Bottom - (H - Rect.Height) div 2;
    end;

    // Center Fill
    FXDrawMode.Center3Fill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left - (W - Rect.Width) div 3;
      Result[0].Right := Result[0].Right - (W - Rect.Width) div 3;
      Result[0].Top := Result[0].Top - (H - Rect.Height) div 3;
      Result[0].Bottom := Result[0].Bottom - (H - Rect.Height) div 3;
    end;

    // Center Fit
    FXDrawMode.CenterFit: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B > Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left + (Rect.Width - W) div 2;
      Result[0].Right := Result[0].Right + (Rect.Width - W) div 2;
      Result[0].Top := Result[0].Top + (Rect.Height - H) div 2;
      Result[0].Bottom := Result[0].Bottom + (Rect.Height - H) div 2;
    end;

    // Normal
    FXDrawMode.Normal: begin
      Result[0].Left := Rect.Left;
      Result[0].Right := Result[0].Left + Image.Width;

      Result[0].Top := Rect.Top;
      Result[0].Bottom := Result[0].Bottom + Image.Height;
    end;

    // Tile
    FXDrawMode.Tile: begin
      SetLength(Result, 0);
      A := Rect.Top;
      repeat
        B := Rect.Left;
        repeat
          SetLength(Result, Length(Result) + 1);

          TMPRect.TopLeft := Point(trunc(B), trunc(A));
          TMPRect.Width := Image.Width;
          TMPRect.Height := Image.Height;

          Result[Length(Result) - 1] := TMPRect;

          B := B + Image.Width;
        until (B >= Rect.Width);

        A := A + Image.Height;
      until (A >= Rect.Height);
    end;
  end;

  if ImageMargin <> 0 then
    for I := 0 to High( Result ) do
      with Result[I] do
        begin
          Left := Left + ImageMargin;
          Top := Top + ImageMargin;
          Right := Right - ImageMargin;
          Bottom := Bottom - ImageMargin;
        end;
end;

function GetDrawModeRect(Rect: TRect; Image: TGraphic; DrawMode: FXDrawMode; ImageMargin: integer): TRect;
begin
  Result := GetDrawModeRects(Rect, Image, DrawMode, ImageMargin)[0];
end;

procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic; DrawMode: FXDrawMode; ImageMargin: integer);
var
  Rects: TArray<TRect>;
  I: integer;
begin
  Rects := GetDrawModeRects(Rect, Image, DrawMode, ImageMargin);

  for I := 0 to High( Rects ) do
    Canvas.StretchDraw( Rects[I], Image, 255 );
end;

procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
var
   X: integer;
   dr, dg, db:Extended;
   r1, r2, g1, g2, b1, b2:Byte;
   R, G, B:Byte;
   cnt, csize:integer;
begin
  //Unpack Colors
  tocolor := ColorToRGB(tocolor);
  fromcolor := ColorToRGB(fromcolor);

   R1 := GetRValue(FromColor) ;
   G1 := GetGValue(FromColor) ;
   B1 := GetBValue(FromColor) ;

   R2 := GetRValue(ToColor) ;
   G2 := GetGValue(ToColor) ;
   B2 := GetBValue(ToColor) ;

   // Calculate Width
   csize := Rect.Right-Rect.Left;
   if csize <= 0 then Exit;

   // Get Color mdi
   dr := (R2-R1) / csize;
   dg := (G2-G1) / csize;
   db := (B2-B1) / csize;

   // Start Draw
   cnt := 0;
   for X := Rect.Left to Rect.Right-1 do
   begin
     R := R1+Ceil(dr*cnt) ;
     G := G1+Ceil(dg*cnt) ;
     B := B1+Ceil(db*cnt) ;

     Canvas.Pen.Color := RGB(R,G,B) ;
     Canvas.MoveTo(X,Rect.Top) ;
     Canvas.LineTo(X,Rect.Bottom) ;
     inc(cnt) ;
   end;
end;

procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
var
   Y: integer;
   dr, dg, db:Extended;
   r1, r2, g1, g2, b1, b2:Byte;
   R, G, B:Byte;
   cnt, csize:integer;
begin
  //Unpack Colors
  tocolor := ColorToRGB(tocolor);
  fromcolor := ColorToRGB(fromcolor);

   R1 := GetRValue(FromColor) ;
   G1 := GetGValue(FromColor) ;
   B1 := GetBValue(FromColor) ;

   R2 := GetRValue(ToColor) ;
   G2 := GetGValue(ToColor) ;
   B2 := GetBValue(ToColor) ;

   // Calculate Width
   csize := Rect.Bottom-Rect.Top;
   if csize <= 0 then Exit;

   // Get Color mdi
   dr := (R2-R1) / csize;
   dg := (G2-G1) / csize;
   db := (B2-B1) / csize;

   // Start Draw
   cnt := 0;
   for Y := Rect.Top to Rect.Bottom-1 do
   begin
     R := R1+Ceil(dr*cnt) ;
     G := G1+Ceil(dg*cnt) ;
     B := B1+Ceil(db*cnt) ;

     Canvas.Pen.Color := RGB(R,G,B) ;
     Canvas.MoveTo(Rect.Left,Y) ;
     Canvas.LineTo(Rect.Right,Y) ;
     inc(cnt) ;
   end;
end;

procedure FastBlur(Bitmap: TBitmap; Radius: Real; BlurScale: Integer; HighQuality: Boolean = True);
begin
  CFX.BlurFunctions.FastBlur( Bitmap, Radius, BlurScale, HighQuality );
end;

function GetMaxFontHeight(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;
var
  Ext: TSize;
begin
  Result := 0;
  if Text = '' then
    Exit;

  Canvas.Font.Height := -10;
  repeat
    Canvas.Font.Height := Canvas.Font.Height - 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx >= MaxWidth) or (Ext.cy >= MaxHeight));
  repeat
    Canvas.Font.Height := Canvas.Font.Height + 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx <= MaxWidth) and (Ext.cy <= MaxHeight)) or (Canvas.Font.Height = 1);

  Result := Canvas.Font.Height;
end;

procedure DrawTextRect(Canvas: TCanvas; ARect: TRect; Text: string; Flags: FXTextFlags; AMargin: integer);
var
  TextFormat: TTextFormat;
  Words, Lines: TArray<string>;
  Moved, Line, Top, LineHeight, HasBreak, I: integer;
  NewStarted: boolean;
  Temp: string;
  R: TRect;
begin
  // Margin
  if AMargin <> 0 then
    ARect.Inflate(-AMargin, -AMargin);

  // Ignore
  if Text = '' then
    Exit;

  if FXTextFlag.Auto in Flags then
    begin
      if Canvas.TextWidth(Text) > ARect.Width then
        Flags := Flags + [FXTextFlag.WordWrap];
    end;

  if FXTextFlag.WordWrap in Flags then
    begin
      // Get Words
      Words := GetAllSeparatorItems(Text, [' ']);

      // Line Settings
      TextFormat := [];
      if FXTextFlag.Left in Flags then
        TextFormat := TextFormat + [tfLeft];
      if FXTextFlag.Center in Flags then
        TextFormat := TextFormat + [tfCenter];
      if FXTextFlag.Right in Flags then
        TextFormat := TextFormat + [tfRight];
      if FXTextFlag.NoClip in Flags then
        TextFormat := TextFormat + [tfNoClip];

      // Move words to Lines
      SetLength( Lines, 1);
      NewStarted := true;

      Moved := 0;
      Line := 0;
      repeat
        // Add Word
        Temp := Lines[Line];
        if not NewStarted then
          Temp := Temp + ' ';
        Temp := Temp + Words[Moved];

        // Break #13
        HasBreak := Pos(#13, Temp);
        if (HasBreak <> 0) and NewStarted then
          begin
            Temp := StrRemove(Temp, HasBreak, HasBreak);
            HasBreak := Pos(#13, Temp);

            if HasBreak <> 0 then
              Words[Moved] := StrRemove(Words[Moved], Pos(#13, Words[Moved]), Pos(#13, Words[Moved]));
          end;

        if ( NewStarted or (Canvas.TextWidth(Temp) <= ARect.Width) ) and (HasBreak = 0) then
          begin
            Lines[Line] := Temp;

            NewStarted := false;

            // Increase
            Inc( Moved );
          end
        else
        // Start New Line
          begin
            Inc( Line );
            SetLength( Lines, Line + 1);

            NewStarted := true;
          end;
      until Moved >= Length( Words );

      // Vertical Align
      Top := 0;
      if FXTextFlag.VerticalCenter in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + Canvas.TextHeight(Lines[I]);

          Top := round( ARect.Height / 2 - Top / 2 );
        end;
      if FXTextFlag.Bottom in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + Canvas.TextHeight(Lines[I]);

          Top := ARect.Height - Top;
        end;

      Top := Top + ARect.Top;

      // Draw
      for I := 0 to High(Lines) do
        begin
          LineHeight := Canvas.TextHeight(Lines[I]);
          if Lines[I] = '' then
            LineHeight := Canvas.TextHeight('I');

          R := Rect( ARect.Left, Top, ARect.Right, Top + LineHeight );

          Canvas.TextRect( R, Lines[I], TextFormat );

          Top := Top + LineHeight;
        end;
    end
  else
    begin
      TextFormat := [tfSingleLine];
      if FXTextFlag.Center in Flags then
        TextFormat := TextFormat + [tfCenter];
      if FXTextFlag.Right in Flags then
        TextFormat := TextFormat + [tfRight];
      if FXTextFlag.VerticalCenter in Flags then
        TextFormat := TextFormat + [tfVerticalCenter];
      if FXTextFlag.Bottom in Flags then
        TextFormat := TextFormat + [tfBottom];
      if FXTextFlag.NoClip in Flags then
        TextFormat := TextFormat + [tfNoClip];

      Canvas.TextRect(ARect, Text, TextFormat);
    end;
end;


function CreatePreMultipliedRGBQuad(Color: TColor; Alpha: Byte = $FF): TRGBQuad;
begin
  Color := ColorToRGB(Color);
  Result.rgbBlue := MulDiv(GetBValue(Color), Alpha, $FF);
  Result.rgbGreen := MulDiv(GetGValue(Color), Alpha, $FF);
  Result.rgbRed := MulDiv(GetRValue(Color), Alpha, $FF);
  Result.rgbReserved := Alpha;
end;

function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;
var
  Info: TBitmapInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  with Info.bmiHeader do
    begin
      biSize := SizeOf(Info.bmiHeader);
      biWidth := 1;
      biHeight := 1;
      biPlanes := 1;
      biBitCount := 32;
      biCompression := BI_RGB;
    end;
  Info.bmiColors[0] := CreatePreMultipliedRGBQuad(Color, Alpha);
  Result := CreateDIBPatternBrushPt(@Info, 0);
end;

procedure CopyRoundRect(FromCanvas: TCanvas; FromRect: TRoundRect; DestCanvas: TCanvas; DestRect: TRect; shrinkborder: integer);
var
  x, y, A, m: integer;
  Al: Real;
  HS, HD: TLine;
  S, D: TRect;
begin
  // Border Shrink
  if shrinkborder <> 0 then
  begin
    inc(FromRect.Rect.Left, shrinkborder);
    inc(FromRect.Rect.Top, shrinkborder);
    dec(FromRect.Rect.Right, shrinkborder);
    dec(FromRect.Rect.Bottom, shrinkborder);

    inc(DestRect.Left, shrinkborder);
    inc(DestRect.Top, shrinkborder);
    dec(DestRect.Right, shrinkborder);
    dec(DestRect.Bottom, shrinkborder);
  end;

  // Adjust Sizing
  if FromRect.GetRoundness > FromRect.Rect.Height then
    FromRect.SetRoundness( FromRect.Rect.Height );

  m := 0;
  if (FromRect.Rect.Height > m) then
    m := FromRect.Rect.Height;
  if (FromRect.Rect.Width > m) then
    m := FromRect.Rect.Width;
  if (DestRect.Width > m) then
    m := DestRect.Width;
  if (DestRect.Width > m) then
    m := DestRect.Width;

  if (m = 0) or (FromRect.Width = 0) or (FromRect.Height = 0) then
    Exit;

  if m > 90 then
    m := round(m/90) + 1
  else
    m := 1;


  // Start Copy
    for A := 90 * m to 180 * m do
      begin
        Al := A / m;
        X := round( FromRect.RoundX / 2 * cos(Al*pi/180) );
        Y := round( FromRect.RoundY / 2 * sin(Al*pi/180) );

        S.Left := FromRect.Rect.Left + FromRect.RoundX div 2 + X - 1;
        S.Top := FromRect.Rect.Top + FromRect.RoundY div 2 - Y - 1;

        if S.Bottom > FromRect.Bottom + 1 then
          S.Bottom := FromRect.Bottom + 1;

        S.Right := FromRect.Rect.Right - FromRect.RoundX div 2 - X + 1;
        S.Bottom := FromRect.Rect.Top + FromRect.RoundY div 2 - Y + 1;

        D.Left := DestRect.Left + round( (S.Left - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Right := DestRect.Left + round( (S.Right - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Top := DestRect.Top + round( (S.Top - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );
        D.Bottom := DestRect.Top + round( (S.Bottom - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );

        DestCanvas.CopyRect(D, FromCanvas, S);

        if A = 180 * m then
          begin
            HS.Point1 := S.TopLeft;
            HD.Point1 := D.TopLeft;
          end;
      end;
      for A := 180 * m to 270 * m do
      begin
        Al := A / m;
        X := round( FromRect.RoundX / 2 * cos(Al*pi/180) );
        Y := round( FromRect.RoundY / 2 * sin(Al*pi/180) );

        S.Left := FromRect.Rect.Left + FromRect.RoundX div 2 + X - 1;
        S.Top := FromRect.Rect.Bottom - FromRect.RoundY div 2 - Y - 1;

        S.Right := FromRect.Rect.Right - FromRect.RoundX div 2 - X + 1;
        S.Bottom := FromRect.Rect.Bottom - FromRect.RoundY div 2 - Y + 1;

        if S.Bottom > FromRect.Bottom + 1 then
          S.Bottom := FromRect.Bottom + 1;

        D.Left := DestRect.Left + round( (S.Left - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Right := DestRect.Left + round( (S.Right - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Top := DestRect.Top + round( (S.Top - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );
        D.Bottom := DestRect.Top + round( (S.Bottom - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );

        DestCanvas.CopyRect(D, FromCanvas, S);

        if A = 180 * m then
          begin
            HS.Point2 := S.BottomRight;
            HD.Point2 := D.BottomRight;
          end;
      end;

      // Copy Center Rext
      DestCanvas.CopyRect(TRect.Create(HD.Point1, HD.Point2),
                          FromCanvas, TRect.Create(HS.Point1, HS.Point2));
end;


procedure DrawBorder(const Canvas: TCanvas; R: TRect; Color: TColor; Thickness: Byte; Roundness: integer);
var
  TL, BR: Byte;
begin
  if Thickness <> 0 then
    begin
      TL := Thickness div 2;
      if Thickness mod 2 = 0 then
        BR := TL - 1
      else
        BR := TL;
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Color := Color;
      Canvas.Pen.Width := Thickness;
      if RoundNess <= 0 then
        Canvas.Rectangle(TL, TL, R.Width - BR, R.Height - BR)
      else
        Canvas.RoundRect(TL, TL, R.Width - BR, R.Height - BR, RoundNess, RoundNess);
    end;
end;

end.
