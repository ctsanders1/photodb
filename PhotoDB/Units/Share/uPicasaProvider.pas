unit uPicasaProvider;

interface

uses
  uMemory,
  uMemoryEx,
  Generics.Collections,
  Classes,
  SysUtils,
  SyncObjs,
  Graphics,
  MSXML2_TLB,
  uXMLUtils,
  JPEG,
  pngimage,
  uInternetUtils,
  uInternetProxy,
  uGoogleOAuth,
  uPhotoShareInterfaces,
  uResources,
  uTranslate,
  uSettings,
  Forms;

const
  GOOGLE_APP_CLIENT_ID = '958093310635.apps.googleusercontent.com';
  GOOGLE_APP_CLIENT_SECRET = 'oMLliTwu4VM1u3WzJBrGbNsz';
  GOOGLE_PICASAWEB_ACCESS_POINT = 'https://picasaweb.google.com/data/';

  PICASA_CREATE_ALBUM_XML = //POST https://picasaweb.google.com/data/feed/api/user/default
  '  <entry xmlns="http://www.w3.org/2005/Atom"                                            ' +
  '      xmlns:media="http://search.yahoo.com/mrss/"                                       ' +
  '      xmlns:gphoto="http://schemas.google.com/photos/2007">                             ' +
  '    <title type="text">{title}</title>                                                  ' +
  '    <summary type="text">{summary}</summary>                                            ' +
  '    <gphoto:location>{location}</gphoto:location>                                       ' +
  '    <gphoto:access>{access}</gphoto:access>                                             ' +
  '    <gphoto:timestamp>{date}</gphoto:timestamp>                                         ' +
  '    <media:group>                                                                       ' +
  '      <media:keywords>{keywords}</media:keywords>                                       ' +
  '    </media:group>                                                                      ' +
  '    <category scheme="http://schemas.google.com/g/2005#kind"                            ' +
  '      term="http://schemas.google.com/photos/2007#album"></category>                    ' +
  '  </entry>                                                                              ';

  PICASA_UPLOAD_ITEM = //https://picasaweb.google.com/data/feed/api/user/default/albumid/AlbumID
  '  <entry xmlns="http://www.w3.org/2005/Atom">                    ' +
  '    <title>{title}</title>                                       ' +
  '    <summary>{summary}</summary>                                 ' +
  '    <category scheme="http://schemas.google.com/g/2005#kind"     ' +
  '      term="http://schemas.google.com/photos/2007#photo"/>       ' +
  '  </entry>                                                       ';

type
  TGoogleAlbumsInfo = class(TObject)
  private
    FAlbumXML: string;
    FAuthorName: string;
    FUrl: string;
    FAvatarUrl: string;
    FAvailableSpace: Int64;
    FUserID: string;
  public
    constructor Create(AlbumXML: string);
    property AuthorName: string read FAuthorName;
    property Url: string read FUrl;
    property AvatarUrl: string read FAvatarUrl;
    property AvailableSpace: Int64 read FAvailableSpace;
    property UserID: string read FUserID;
  end;

  TPicasaUserAlbumsInfo = class(TInterfacedObject, IPhotoServiceUserInfo)
  private
    FAlbumsInfo: TGoogleAlbumsInfo;
  public
    constructor Create(AlbumXML: string);
    destructor Destroy; override;
    function GetUserAvatar(Bitmap: TBitmap): Boolean;
    function GetUserDisplayName: string;
    function GetHomeUrl: string;
    function GetAvailableSpace: Int64;
    property UserDisplayName: string read GetUserDisplayName;
    property HomeUrl: string read GetHomeUrl;
  end;

  TPicasaUserAlbumPhoto = class(TInterfacedObject, IPhotoServiceItem)
  private
    FXmlInfo: string;
    FName: string;
    FDescription: string;
    FDateTime: TDateTime;
    FPreviewUrl: string;
    FUrl: string;
    FSize: Int64;
    FWidth: Integer;
    FHeight: Integer;
  public
    constructor Create(XmlInfo: string);
    function GetName: string;
    function GetDescription: string;
    function GetDate: TDateTime;
    function GetUrl: string;
    function GetSize: Int64;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function ExtractPreview(Image: TBitmap): Boolean;
    function Delete: Boolean;
  end;

  TPicasaProvider = class;

  TPicasaUserAlbum = class(TInterfacedObject, IPhotoServiceAlbum)
  private
    FXML: string;
    FAlbumID: string;
    FName: string;
    FDescription: string;
    FAlbumPreviewUrl: string;
    FAlbumUrl: string;
    FDateTime: TDateTime;
    FAccess: Integer;
    FProvider: TPicasaProvider;
    FIProvider: IPhotoShareProvider;
  public
    constructor Create(Provider: TPicasaProvider; XML: string);
    destructor Destroy; override;
    function UploadItem(FileName, Name, Description: string; Date: TDateTime; ContentType: string; Stream: TStream; Progress: IUploadProgress; out Item: IPhotoServiceItem): Boolean;
    function GetAlbumID: string;
    function GetName: string;
    function GetDescription: string;
    function GetDate: TDateTime;
    function GetUrl: string;
    function GetAccess: Integer;
    function GetPreview(Bitmap: TBitmap; HttpContainer: THTTPRequestContainer = nil): Boolean;
  end;

  TPicasaProvider = class(TInterfacedObject, IPhotoShareProvider)
  private
    FOAuth: TOAuth2;
    FSync: TCriticalSection;
    FTmpProgress: IUploadProgress;
    function GetAccessUrl: string;
    function CheckToken(Force: Boolean): Boolean;
    procedure DoOperationProgress(Sender: TObject; Max, Position: Int64; var Cancel: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ResetAuth;
    function IsFeatureSupported(Feature: string): Boolean;
    function InitializeService: Boolean;
    function GetProviderName: string;
    function ChangeUser: Boolean;
    function GetUserInfo(out Info: IPhotoServiceUserInfo): Boolean;
    function GetAlbumList(Albums: TList<IPhotoServiceAlbum>): Boolean;
    function CreateAlbum(Name, Description: string; Date: TDateTime; Access: Integer; out Album: IPhotoServiceAlbum): Boolean;
    function UploadPhoto(AlbumID, FileName, Name, Description: string; Date: TDateTime; ContentType: string;
      Stream: TStream; Progress: IUploadProgress; out Photo: IPhotoServiceItem): Boolean;
    function GetProviderImage(Bitmap: TBitmap): Boolean;
    property AccessURL: string read GetAccessUrl;
  end;

{$R SharePictures.res}

function ReadFile(FileName: string): string;

implementation

uses
  uPicasaOAuth2;

type
  TFindNodeCallBack = reference to procedure(Node: IXMLDOMNode);

function ReadFile(FileName: string): string;
var
  FS: TFileStream;
  SR: TStreamReader;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    SR := TStreamReader.Create(FS);
    try
      Result := SR.ReadToEnd;
    finally
      F(SR);
    end;
  finally
    F(FS);
  end;
end;

function DateTimeTimeStamp(Date: TDateTime): Int64;
var
  StartDate: TDateTime;
begin
  Result := 0;
  StartDate := EncodeDate(1970, 1, 1);
  if StartDate < Date then
    Result := Round((Date - StartDate) * MSecsPerDay);
end;

function TimeStampToDateTime(TimeStamp: Int64): TDateTime;
begin
  Result:= EncodeDate(1970, 1, 1) + TimeStamp / MSecsPerDay;
end;

function FindNode(ParentNode: IXMLDOMNode; Name: string): IXMLDOMNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ParentNode.childNodes.length - 1 do
  begin
    if ParentNode.childNodes[I].nodeName = Name then
    begin
      Result := ParentNode.childNodes.item[I];
      Exit;
    end;
  end;
end;

procedure FindNodes(ParentNode: IXMLDOMNode; Name: string; CallBack: TFindNodeCallBack);
var
  I: Integer;
begin
  for I := 0 to ParentNode.childNodes.length - 1 do
  begin
    if ParentNode.childNodes[I].nodeName = Name then
      CallBack(ParentNode.childNodes.item[I]);
  end;
end;

{ TPicasaProvider }

function TPicasaProvider.ChangeUser: Boolean;
begin
  Result := False;
  FSync.Enter;
  try
    if CheckToken(True) then
      Result := True;
  finally
    FSync.Leave;
  end;
end;

function TPicasaProvider.CheckToken(Force: Boolean): Boolean;
var
  ApplicationCode, LocalAccessUrl: string;
begin
  if InitializeService then
  begin
    if (FOAuth.Access_token = '') or Force then
    begin
      if (FOAuth.Refresh_token = '') or Force then
      begin
        LocalAccessUrl := Self.AccessUrl;
        TThread.Synchronize(nil,
          procedure
          var
            Form: TFormPicasaOAuth;
          begin
            Form := TFormPicasaOAuth.Create(Screen.ActiveForm, LocalAccessUrl);
            try
              Form.ShowModal;
              ApplicationCode := Form.ApplicationCode;
            finally
              R(Form);
            end;
          end
        );
        if ApplicationCode <> '' then
        begin
          FOAuth.ResponseCode := ApplicationCode;
          FOAuth.GetAccessToken;
        end;
      end else
        FOAuth.RefreshToken;
    end;
  end;
  Result := FOAuth.Access_token <> '';
  if Result then
    AppSettings.WriteString('PhotoShare', 'RefreshToken', FOAuth.Refresh_token);
end;

constructor TPicasaProvider.Create;
begin
  FSync := TCriticalSection.Create;
  FOAuth := nil;
  FTmpProgress := nil;
end;

function TPicasaProvider.CreateAlbum(Name, Description: string; Date: TDateTime; Access: Integer; out Album: IPhotoServiceAlbum): Boolean;
var
  AlbumInfo, AlbumXML: string;
  Data: TStringStream;
begin
  Result := False;
  FSync.Enter;
  try
    if CheckToken(False) then
    begin
      AlbumInfo := PICASA_CREATE_ALBUM_XML;
      AlbumInfo := StringReplace(AlbumInfo, '{title}', Name, []);
      AlbumInfo := StringReplace(AlbumInfo, '{summary}', Description, []);
      AlbumInfo := StringReplace(AlbumInfo, '{location}', '', []);
      AlbumInfo := StringReplace(AlbumInfo, '{date}', IntToStr(DateTimeTimeStamp(Date)), []);
      AlbumInfo := StringReplace(AlbumInfo, '{keywords}', '', []);

      case Access of
        PHOTO_PROVIDER_ALBUM_PROTECTED:
          AlbumInfo := StringReplace(AlbumInfo, '{access}', 'private', []);
        PHOTO_PROVIDER_ALBUM_PRIVATE:
          AlbumInfo := StringReplace(AlbumInfo, '{access}', 'protected', []);
        else
          AlbumInfo := StringReplace(AlbumInfo, '{access}', 'public', []);
      end;

      Data := TStringStream.Create(AlbumInfo, TEncoding.UTF8);
      try
        Data.Seek(0, soFromBeginning);

        AlbumXML := FOAuth.POSTCommand('https://picasaweb.google.com/data/feed/api/user/default', nil, Data, 'application/atom+xml');
        AlbumXML := Utf8ToUnicodeString(RawByteString(AlbumXML));
        if AlbumXML <> '' then
        begin
          Album := TPicasaUserAlbum.Create(Self, AlbumXML);
          Result := True;
        end;
      finally
        F(Data);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

{
    * image/bmp
    * image/gif
    * image/jpeg
    * image/png

----------------------

    * video/3gpp
    * video/avi
    * video/quicktime
    * video/mp4
    * video/mpeg
    * video/mpeg4
    * video/msvideo
    * video/x-ms-asf
    * video/x-ms-wmv
    * video/x-msvideo
}

function TPicasaProvider.UploadPhoto(AlbumID, FileName, Name, Description: string; Date: TDateTime;
  ContentType: string; Stream: TStream; Progress: IUploadProgress; out Photo: IPhotoServiceItem): Boolean;
const
  CR = #$0D;
  LF = #$0A;
  CRLF = CR + LF;
var
  RequestXML, ResponseXML: string;
  MS: TMemoryStream;
  SW: TStreamWriter;
  S: AnsiString;
begin
  //Note: If you want to post a photo, but don't want the hassle of requiring the user of your app to choose an album,
  //you can post the photo to the "Drop Box." This special album will automatically be created the first time
  //it is used to store a photo. To post to the Drop Box,
  //use an albumID value of default: https://picasaweb.google.com/data/feed/api/user/default/albumid/default.
  if AlbumID = '' then
    AlbumID := 'default';

  Result := False;
  Photo := nil;
  FSync.Enter;
  try
    if CheckToken(False) then
    begin
      RequestXML := PICASA_UPLOAD_ITEM;
      RequestXML := StringReplace(RequestXML, '{title}', Name, []);
      RequestXML := StringReplace(RequestXML, '{summary}', Description, []);
      FOAuth.Slug := EncodeURLElement(ExtractFileName(FileName));

      MS := TMemoryStream.Create;
      try
        SW := TStreamWriter.Create(MS, TEncoding.UTF8);
        try
          S := 'Content-Type: multipart/related; boundary="END_OF_PART"' + CRLF;
          S := 'Content-Length: ' + AnsiString(IntToStr(MS.Size)) + CRLF;
          S := S + 'MIME-version: 1.0' + CRLF+ CRLF;
          S := S + 'Media multipart posting' + CRLF;
          MS.Write(PAnsiChar(S)^, length(S));

          { Create request body }
          S := '--END_OF_PART' + CRLF;
          // MIME-type of first part of the document
          S := S + 'Content-Type: application/atom+xml' + CRLF + CRLF;
          MS.Write(PAnsiChar(S)^, length(S));
          //write to document XML content

          SW.Write(RequestXML);
          S := CRLF + CRLF + '--END_OF_PART' + CRLF;//end of the first part
          { the second part - file *.doc }
          S := S + 'Content-Type: ' + AnsiString(ContentType) + CRLF + CRLF;
          MS.Write(PAnsiChar(S)^, Length(S));

          {write file}
          MS.CopyFrom(Stream, Stream.Size);

          {end of request body}
          s := CRLF + '--END_OF_PART--' + CRLF;
          MS.Write(PAnsiChar(S)^, Length(S));

          FTmpProgress := Progress;
          try
            ResponseXML := FOAuth.POSTCommand('https://picasaweb.google.com/data/feed/api/user/default/albumid/' + AlbumID, nil, MS, 'multipart/related; boundary=END_OF_PART');
            ResponseXML := Utf8ToUnicodeString(RawByteString(ResponseXML));
            if ResponseXML <> '' then
            begin
              Photo := TPicasaUserAlbumPhoto.Create(ResponseXML);
              Result := True;
            end;
          finally
            FTmpProgress := nil;
          end;
        finally
          F(SW);
        end;
      finally
        F(MS);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

destructor TPicasaProvider.Destroy;
begin
  F(FOAuth);
  F(FSync);
  inherited;
end;

procedure TPicasaProvider.DoOperationProgress(Sender: TObject; Max,
  Position: Int64; var Cancel: Boolean);
begin
  if (FTmpProgress <> nil) and (Max <> 0) then
    FTmpProgress.OnProgress(Self, Max, Position, Cancel);
end;

function TPicasaProvider.GetAccessUrl: string;
begin
  FSync.Enter;
  try
    if InitializeService then
      Result := FOAuth.AccessURL;
  finally
    FSync.Leave;
  end;
end;

function TPicasaProvider.GetAlbumList(Albums: TList<IPhotoServiceAlbum>): Boolean;
var
  Doc: IXMLDOMDocument;
  DocumentNode: IXMLDOMElement;
  AlbumsXML, AlbumXML: string;
  I: Integer;
begin
  Result := False;
  FSync.Enter;
  try
    if CheckToken(False) then
    begin
      AlbumsXML := FOAuth.GETCommand('https://picasaweb.google.com:443/data/feed/api/user/default', nil);
      AlbumsXML := Utf8ToUnicodeString(RawByteString(AlbumsXML));
      if AlbumsXML <> '' then
      begin
        Doc := CreateXMLDocument;
        if (Doc <> nil) and Doc.loadXML(AlbumsXML) then
        begin
          DocumentNode := Doc.documentElement;
          if (DocumentNode <> nil) and (DocumentNode.nodeName = 'feed') then
          begin
            for I := 0 to DocumentNode.childNodes.length - 1 do
            begin
              if DocumentNode.childNodes.item[I].nodeName = 'entry' then
              begin
                AlbumXML := DocumentNode.childNodes.item[I].xml;
                Albums.Add(TPicasaUserAlbum.Create(Self, AlbumXML))
              end;
            end;
          end;
        end;
        Result := True;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPicasaProvider.GetProviderImage(Bitmap: TBitmap): Boolean;
var
  Png: TPngImage;
begin
  Png := TResourceUtils.LoadGraphicFromRES<TPngImage>('PICASA_LOGO');
  try
    Bitmap.Assign(Png);
    Result := True;
  finally
    F(Png);
  end;
end;

function TPicasaProvider.GetProviderName: string;
begin
  Result := TA('Picasa web albums', 'Picasa');
end;

function TPicasaProvider.GetUserInfo(out Info: IPhotoServiceUserInfo): Boolean;
var
  AlbumsXML: string;
begin
  Result := False;
  Info := nil;
  FSync.Enter;
  try
    if CheckToken(False) then
    begin
      AlbumsXML := FOAuth.GETCommand('https://picasaweb.google.com:443/data/feed/api/user/default', nil);
      AlbumsXML := Utf8ToUnicodeString(RawByteString(AlbumsXML));
      if AlbumsXML <> '' then
      begin
        Info := TPicasaUserAlbumsInfo.Create(AlbumsXML);
        Result := True;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPicasaProvider.InitializeService: Boolean;
begin
  FSync.Enter;
  try
    if FOAuth = nil then
    begin
      FOAuth := TOAuth2.Create;
      FOAuth.OnProgress := DoOperationProgress;
      FOAuth.ClientID := GOOGLE_APP_CLIENT_ID;
      FOAuth.ClientSecret := GOOGLE_APP_CLIENT_SECRET;
      FOAuth.Scope := GOOGLE_PICASAWEB_ACCESS_POINT;
      FOAuth.Refresh_token := AppSettings.ReadString('PhotoShare', 'RefreshToken', '');
    end;
    Result := True;
  finally
    FSync.Leave;
  end;
end;

function TPicasaProvider.IsFeatureSupported(Feature: string): Boolean;
begin
  Result := Feature = PHOTO_PROVIDER_FEATURE_ALBUMS;
  Result := Result or (Feature = PHOTO_PROVIDER_FEATURE_DELETE);
  Result := Result or (Feature = PHOTO_PROVIDER_FEATURE_PRIVATE_ITEMS);
end;

procedure TPicasaProvider.ResetAuth;
begin
  if InitializeService then
  begin
    AppSettings.WriteString('PhotoShare', 'RefreshToken', '');
    FOAuth.Refresh_token := '';
    FOAuth.Access_token := '';
  end;
end;

{ TPicasaUserAlbumsInfo }

constructor TPicasaUserAlbumsInfo.Create(AlbumXML: string);
begin
  FAlbumsInfo := TGoogleAlbumsInfo.Create(AlbumXML);
end;

destructor TPicasaUserAlbumsInfo.Destroy;
begin
  F(FAlbumsInfo);
  inherited;
end;

function TPicasaUserAlbumsInfo.GetAvailableSpace: Int64;
begin
  Result := FAlbumsInfo.AvailableSpace;
end;

function TPicasaUserAlbumsInfo.GetHomeUrl: string;
begin
  Result := FAlbumsInfo.Url;
end;

function TPicasaUserAlbumsInfo.GetUserAvatar(Bitmap: TBitmap): Boolean;
begin
  Result := LoadBitmapFromUrl(FAlbumsInfo.FAvatarUrl, Bitmap, nil, GoogleBaseProxyURL);
end;

function TPicasaUserAlbumsInfo.GetUserDisplayName: string;
begin
  Result := FAlbumsInfo.AuthorName;
end;

{ TGoogleAlbumsInfo }

constructor TGoogleAlbumsInfo.Create(AlbumXML: string);
var
  Doc: IXMLDOMDocument;
  DocumentNode: IXMLDOMElement;
  AuthorNode,
  NameNode,
  UrlNode,
  AvatarNode,
  QuotaLimitNode,
  QuotaCurrentNode: IXMLDOMNode;
begin
  FAuthorName := '';
  FUrl := '';
  FAvatarUrl := '';
  FAvailableSpace := 0;

  FAlbumXML := AlbumXML;
  Doc := CreateXMLDocument;
  if (Doc <> nil) and Doc.loadXML(AlbumXML) then
  begin
    DocumentNode := Doc.documentElement;
    if (DocumentNode <> nil) and (DocumentNode.nodeName = 'feed') then
    begin
      AuthorNode := FindNode(DocumentNode, 'author');
      if AuthorNode <> nil then
      begin
        NameNode := FindNode(AuthorNode, 'name');
        UrlNode := FindNode(AuthorNode, 'uri');
      end;
      QuotaLimitNode := FindNode(DocumentNode, 'gphoto:quotalimit');
      QuotaCurrentNode := FindNode(DocumentNode, 'gphoto:quotacurrent');
      AvatarNode := FindNode(DocumentNode, 'icon');

      if NameNode <> nil then
        FAuthorName := NameNode.text;
      if UrlNode <> nil then
        FUrl := UrlNode.text;
      if AvatarNode <> nil then
        FAvatarUrl := AvatarNode.text;

      if (QuotaLimitNode <> nil) and (QuotaCurrentNode <> nil) then
        FAvailableSpace := StrToInt64Def(QuotaLimitNode.text, 0) - StrToInt64Def(QuotaCurrentNode.text, 0);
    end;
  end;
end;

{ TPicasaUserAlbum }

constructor TPicasaUserAlbum.Create(Provider: TPicasaProvider; XML: string);
var
  Doc: IXMLDOMDocument;
  DocumentNode: IXMLDOMElement;
  AlbumIDNode,
  TitleNode,
  SummaryNode,
  DateTimeNode,
  MediaGroup,
  PreviewNode,
  UrlAttr,
  AlbumNameNode,
  AuthorNode,
  UserUrlNode,
  AccessNode: IXMLDOMNode;
  TimeStamp: Int64;
begin
  FXML := XML;
  FProvider := Provider;
  //add new reference
  FIProvider := Provider;
  FAlbumUrl := '';

  PreviewNode := nil;
  Doc := CreateXMLDocument;
  if (Doc <> nil) and Doc.loadXML(XML) then
  begin
    DocumentNode := Doc.documentElement;
    if (DocumentNode <> nil) and (DocumentNode.nodeName = 'entry') then
    begin
      AlbumIDNode := FindNode(DocumentNode, 'gphoto:id');
      TitleNode := FindNode(DocumentNode, 'title');
      SummaryNode := FindNode(DocumentNode, 'summary');
      DateTimeNode := FindNode(DocumentNode, 'gphoto:timestamp');
      MediaGroup := FindNode(DocumentNode, 'media:group');
      AccessNode := FindNode(DocumentNode, 'media:access');
      if MediaGroup <> nil then
        PreviewNode := FindNode(MediaGroup, 'media:thumbnail');

      AuthorNode := FindNode(DocumentNode, 'author');
      if AuthorNode <> nil then
      begin
        UserUrlNode := FindNode(AuthorNode, 'uri');
        AlbumNameNode := FindNode(DocumentNode, 'gphoto:name');
        if (UserUrlNode <> nil) and (AlbumNameNode <> nil) then
          FAlbumUrl := UserUrlNode.text + '/' + AlbumNameNode.text;
      end;

      if AlbumIDNode <> nil then
        FAlbumID := AlbumIDNode.text;
      if TitleNode <> nil then
        FName := TitleNode.text;
      if SummaryNode <> nil then
        FDescription := SummaryNode.text;
      if DateTimeNode <> nil then
      begin
        TimeStamp := StrToInt64Def(DateTimeNode.text, DateTimeTimeStamp(Now));
        FDateTime := TimeStampToDateTime(TimeStamp);
      end;
      if PreviewNode <> nil then
      begin
        UrlAttr := PreviewNode.attributes.getNamedItem('url');
        if UrlAttr <> nil then
          FAlbumPreviewUrl := UrlAttr.nodeValue;
      end;
      FAccess := PHOTO_PROVIDER_ALBUM_PUBLIC;
      if AccessNode <> nil then
      begin
        if AccessNode.text = 'private' then
          FAccess := PHOTO_PROVIDER_ALBUM_PROTECTED;
        if AccessNode.text = 'protected' then
          FAccess := PHOTO_PROVIDER_ALBUM_PRIVATE;
      end;
    end;
  end;
end;

destructor TPicasaUserAlbum.Destroy;
begin
  FProvider := nil;
  //remove reference
  FIProvider := nil;
  inherited;
end;

function TPicasaUserAlbum.GetAccess: Integer;
begin
  Result := FAccess;
end;

function TPicasaUserAlbum.GetAlbumID: string;
begin
  Result := FAlbumID;
end;

function TPicasaUserAlbum.GetDate: TDateTime;
begin
  Result := FDateTime;
end;

function TPicasaUserAlbum.GetDescription: string;
begin
  Result := FDescription;
end;

function TPicasaUserAlbum.GetName: string;
begin
  Result := FName;
end;

function TPicasaUserAlbum.GetPreview(Bitmap: TBitmap; HttpContainer: THTTPRequestContainer = nil): Boolean;
begin
  if IsProxyServerUsed(GoogleBaseProxyURL) then
    HttpContainer := nil;

  Result := LoadBitmapFromUrl(FAlbumPreviewUrl, Bitmap, HttpContainer, GoogleBaseProxyURL);
end;

function TPicasaUserAlbum.GetUrl: string;
begin
  Result := FAlbumUrl;
end;

function TPicasaUserAlbum.UploadItem(FileName, Name, Description: string; Date: TDateTime; ContentType: string; Stream: TStream; Progress: IUploadProgress; out Item: IPhotoServiceItem): Boolean;
begin
  Result := FProvider.UploadPhoto(GetAlbumID, FileName, Name, Description, Date, ContentType, Stream, Progress, Item);
end;

{ TPicasaUserAlbumPhoto }

constructor TPicasaUserAlbumPhoto.Create(XmlInfo: string);
var
  Doc: IXMLDOMDocument;
  DocumentNode: IXMLDOMElement;
  TitleNode,
  SummaryNode,
  DateTimeNode,
  MediaGroup,
  PreviewNode,
  SizeNode,
  WidthNode,
  HeightNode,
  UrlAttr,
  HrefAttr: IXMLDOMNode;
  TimeStamp: Int64;

  function FindLink(LinkType: string): string;
  var
    Res: string;
  begin
    Res := '';
    FindNodes(DocumentNode, 'link',
      procedure(Node: IXMLDOMNode)
      var
        TypeAttr: IXMLDOMNode;
      begin
        TypeAttr := Node.attributes.getNamedItem('rel');
        HrefAttr := Node.attributes.getNamedItem('href');
        if (TypeAttr <> nil) and (HrefAttr <> nil) and (TypeAttr.nodeValue = LinkType) then
          Res :=  HrefAttr.nodeValue;
      end
    );
    Result := Res;
  end;

begin
  FXmlInfo := XmlInfo;

  PreviewNode := nil;
  Doc := CreateXMLDocument;
  if (Doc <> nil) and Doc.loadXML(XmlInfo) then
  begin
    DocumentNode := Doc.documentElement;
    if (DocumentNode <> nil) and (DocumentNode.nodeName = 'entry') then
    begin
      TitleNode := FindNode(DocumentNode, 'title');
      SummaryNode := FindNode(DocumentNode, 'summary');
      DateTimeNode := FindNode(DocumentNode, 'gphoto:timestamp');
      SizeNode := FindNode(DocumentNode, 'gphoto:size');
      WidthNode := FindNode(DocumentNode, 'gphoto:width');
      HeightNode := FindNode(DocumentNode, 'gphoto:height');

      MediaGroup := FindNode(DocumentNode, 'media:group');
      if MediaGroup <> nil then
      begin
        PreviewNode := FindNode(MediaGroup, 'media:thumbnail');
      end;

      if TitleNode <> nil then
        FName := TitleNode.text;
      if SummaryNode <> nil then
        FDescription := SummaryNode.text;
      if DateTimeNode <> nil then
      begin
        TimeStamp := StrToInt64Def(DateTimeNode.text, DateTimeTimeStamp(Now));
        FDateTime := TimeStampToDateTime(TimeStamp);
      end;
      if PreviewNode <> nil then
      begin
        UrlAttr := PreviewNode.attributes.getNamedItem('url');
        if UrlAttr <> nil then
          FPreviewUrl := UrlAttr.nodeValue;
      end;

      if SizeNode <> nil then
        FSize := StrToInt64Def(SizeNode.text, 0);
      if WidthNode <> nil then
        FWidth := StrToIntDef(WidthNode.text, 0);
      if HeightNode <> nil then
        FHeight := StrToIntDef(HeightNode.text, 0);

      FUrl := FindLink('http://schemas.google.com/photos/2007#canonical');
      if FUrl = '' then
        FUrl := FindLink('alternate');

    end;
  end;
end;

function TPicasaUserAlbumPhoto.Delete: Boolean;
begin
  //currently isn't supported
  Result := False;
end;

function TPicasaUserAlbumPhoto.ExtractPreview(Image: TBitmap): Boolean;
begin
  Result := LoadBitmapFromUrl(FUrl, Image, nil, GoogleBaseProxyURL);
end;

function TPicasaUserAlbumPhoto.GetDate: TDateTime;
begin
  Result := FDateTime;
end;

function TPicasaUserAlbumPhoto.GetDescription: string;
begin
  Result := FDescription;
end;

function TPicasaUserAlbumPhoto.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TPicasaUserAlbumPhoto.GetName: string;
begin
  Result := FName;
end;

function TPicasaUserAlbumPhoto.GetSize: Int64;
begin
  Result := FSize;
end;

function TPicasaUserAlbumPhoto.GetUrl: string;
begin
  Result := FUrl;
end;

function TPicasaUserAlbumPhoto.GetWidth: Integer;
begin
  Result := FWidth;
end;

initialization
  PhotoShareManager.RegisterProvider(TPicasaProvider.Create);

end.
