unit CFX.Classes;

interface
  uses
    Vcl.Graphics, Classes, Types, CFX.Types, CFX.UIConsts, SysUtils,
    CFX.Graphics, CFX.VarHelpers, CFX.ThemeManager, Vcl.Controls,
    TypInfo;

  type
    // Base Clases
    FXComponent = class(TComponent)

    end;

    // Persistent
    TMPersistent = class(TPersistent)
      Owner : TPersistent;
      constructor Create(AOwner : TPersistent); overload; virtual;
    end;

    TAssignPersistent = class(TMPersistent)
    public
      procedure Assign(Source: TPersistent); override;
    end;

    // Icon
    FXIconSelect = class(TMPersistent)
    private
      FEnabled: boolean;

      FType: FXIconType;
      FPicture: TPicture;
      FBitMap: TBitMap;
      FSegoeText: string;
      FImageIndex: integer;

      procedure SetBitMap(const Value: TBitMap);
      procedure SetPicture(const Value: TPicture);

    published
      property Enabled: boolean read FEnabled write FEnabled default False;
      property IconType: FXIconType read FType write FType default FXIconType.SegoeIcon;

      property SelectPicture: TPicture read FPicture write SetPicture;
      property SelectBitmap: TBitMap read FBitMap write SetBitMap;
      property SelectSegoe: string read FSegoeText write FSegoeText;
      property SelectImageIndex: integer read FImageIndex write FImageIndex default -1;

    public
      constructor Create(AOwner : TPersistent); override;
      destructor Destroy; override;

      procedure Assign(Source: TPersistent); override;

      procedure DrawIcon(Canvas: TCanvas; ARectangle: TRect);

      procedure FreeUnusedAssets;
    end;

implementation

{ FXIconSelect }

procedure FXIconSelect.Assign(Source: TPersistent);
begin
  with FXIconSelect(Source) do
    begin
      Self.FEnabled := FEnabled;

      Self.FType := FType;

      Self.FPicture.Assign(FPicture);
      Self.FBitMap.Assign(FBitMap);
      Self.FSegoeText := FSegoeText;
      Self.FImageIndex := FImageIndex;
    end;
end;

constructor FXIconSelect.Create(AOwner : TPersistent);
begin
  inherited;
  Enabled := false;

  FPicture := TPicture.Create;
  FBitMap := TBitMap.Create;

  IconType := FXIconType.SegoeIcon;
  FSegoeText := SEGOE_UI_STAR;
end;

destructor FXIconSelect.Destroy;
begin
  FreeAndNil(FPicture);
  FreeAndNil(FBitMap);

  inherited;
end;

procedure FXIconSelect.DrawIcon(Canvas: TCanvas; ARectangle: TRect);
var
  TextDraw: string;
  FontPrevious: TFont;
begin
  case IconType of
    FXIconType.Image: DrawImageInRect( Canvas, ARectangle, SelectPicture.Graphic, FXDrawMode.CenterFit );
    FXIconType.BitMap: DrawImageInRect( Canvas, ARectangle, SelectBitmap, FXDrawMode.CenterFit );
    FXIconType.ImageList: (* Work In Progress;*);
    FXIconType.SegoeIcon: begin
      TextDraw := SelectSegoe;

      with Canvas do
        begin
          FontPrevious := TFont.Create;
          try
            FontPrevious.Assign(Font);

            // Draw
            Font.Name := ThemeManager.IconFont;
            Font.Height := GetMaxFontHeight(Canvas, TextDraw, ARectangle.Width, ARectangle.Height);
            TextRect( ARectangle, TextDraw, [tfSingleLine, tfCenter, tfVerticalCenter] );

            Font.Assign(FontPrevious);
          finally
            FontPrevious.Free;
          end;
        end;
    end;
  end;
end;

procedure FXIconSelect.FreeUnusedAssets;
begin
  if (IconType <> FXIconType.Image) and (FPicture <> nil) and (not FPicture.Graphic.Empty) then
    FPicture.Free;

  if (IconType <> FXIconType.BitMap) and (FBitMap <> nil) and (not FBitMap.Empty) then
    FBitMap.Free;
end;

procedure FXIconSelect.SetBitMap(const Value: TBitMap);
begin
  if FBitmap = nil then
    FBitmap := TBitMap.Create;

  FBitmap.Assign(value);
end;

procedure FXIconSelect.SetPicture(const Value: TPicture);
begin
  if FPicture = nil then
    FPicture := TPicture.Create;

  FPicture.Assign(Value);
end;

{ TMPersistent }

constructor TMPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  Owner := AOwner;
end;


{ TAssignPersistent }

procedure TAssignPersistent.Assign(Source: TPersistent);
var
  PropList: PPropList;
  PropCount, i: Integer;
begin
  if Source is TAssignPersistent then
  begin
    PropCount := GetPropList(Source.ClassInfo, tkProperties, nil);
    if PropCount > 0 then
    begin
      GetMem(PropList, PropCount * SizeOf(PPropInfo));
      try
        GetPropList(Source.ClassInfo, tkProperties, PropList);
        for i := 0 to PropCount - 1 do
          SetPropValue(Self, string(PropList^[i]^.Name), GetPropValue(Source, string(PropList^[i]^.Name)));
      finally
        FreeMem(PropList);
      end;
    end;
  end
  else
    inherited Assign(Source);
end;

end.
