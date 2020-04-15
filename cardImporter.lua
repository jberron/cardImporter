--By Amuzet
mod_name = 'Card Importer'
version = 1.694
self.setName(mod_name..' '..version)
author = '76561198045776458'
WorkshopID = 'https://steamcommunity.com/sharedfiles/filedetails/?id=1838051922'

--[[Classes]]
local TBL = {
  __call  = function(t,k) if k then return t[k] end return t.___ end,
  __index = function(t,k)
    if type(t.___) == 'table' then rawset(t,k,t.___())
    else rawset(t,k,t.___) end return t[k] end}
function TBL.new(d,t) t.___ = d return setmetatable(t,TBL) end
--[[Variables]]
local Tick, Test, Quality, Back = 0.2, true, TBL.new('normal',{}), TBL.new('https://i.stack.imgur.com/787gj.png',
  { --Amuzet
    [author] = 'https://orig00.deviantart.net/f7ea/f/2016/040/2/f/playing_cards_template___wooden_back_by_toomanypenguins-d9r55w3.png',
    --Bonez510
    ['76561198000043097'] = 'https://i.imgur.com/rfQsgTL.png',
    --DrOktoberfest
    ['76561198045241564'] = 'http://i.imgur.com/P7qYTcI.png',
    --King Crimson
    ['76561198079063165'] = 'https://external-preview.redd.it/QPaqxNBqLVUmR6OZTPpsdGd4MNuCMv91wky1SZdxqUc.png?s=006bfa2facd944596ff35301819a9517e6451084',
    --Untraceable
    ['76561198025014348'] = 'https://i.imgur.com/pPnIKhy.png',
    --ZeroWolf
    ['76561198069287630'] = 'http://i.imgur.com/OCOGzLH.jpg',
    })
--[[Card Spawning Class]]
local Card = setmetatable({
    n = 1,
    hwfd = true,
    image = false,
    --TTS
    json = '',
    position = {0,0,0},
    snap_to_grid = true,
    callback = 'INC',
    callback_owner = self},{
    __call = function(t,c, qTbl )
      t.json = ''
      c.face = ''
      c.oracle = ''
      c.back = Back[qTbl.player] or Back.___
      
      c.name = c.name..'\n'..c.type_line:gsub(' // .*',''):gsub('%w*',
        function(a) return '['..string_to_color(a)..']'..a..'[-]' end)..' '..c.cmc..'CMC'
      if c.printed_name then c.name = c.printed_name..' - '..c.name end
      --Oracle text Handling for Split/DFCs
      if c.card_faces then
        for _,f in ipairs(c.card_faces)do c.oracle = c.oracle .. c.name ..'\n'.. setOracle(f) end
      else c.oracle = setOracle(c) end
      --Image Handling
      if t.image then --Custom Image
        c.face = t.image
        t.image = false
      elseif c.image_uris then
        c.face = c.image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
      else --DFC Cards
        c.name = c.name:gsub(' // [^\n]*','')
        c.face = c.card_faces[1].image_uris.normal:gsub('%?.*','')
        if qTbl.deck == nil then
          c.back = c.face:gsub('normal',Quality[qTbl.player])
          c.face = c.card_faces[2].image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
          t.hwfd = false
      end end
      --Log Current Values
      if not qTbl.deck then
        uLog(qTbl.color..' Spawned '..c.name:gsub('\n.*','')) end
      --Set JSON to Spawn Card
      t.json = string.format(
'{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":180,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}',
        c.name , c.oracle , t.n , t.n , c.face , c.back)
      --Spawn at higher position
      t.position = qTbl.position
      t.position[2] = t.position[2] + Tick
      spawnObjectJSON(t)
    end})

function INC(obj)
  obj.hide_when_face_down = Card.hwfd
  Card.hwfd = true
  Card.n = Card.n + 1
end

function setOracle(c)
  local n = '\n[b]'
  if c.power then n = n .. c.power ..'/'.. c.toughness
  elseif c.loyalty then n = n .. tostring(c.loyalty)
  else n = '[b]' end
  uLog('Printed_Text')
  uLog (c.printed_text)
  if c.printed_text then
    return c.printed_text:gsub('\"',"'") .. n .. '[/b]'
  else
    return c.oracle_text:gsub('\"',"'") .. n .. '[/b]' end
end

function setCard(wr, qTbl )
  Test = true
  uLog(wr.url)
  
  if wr.text then
    local json = JSON.decode(wr.text)
    if json.object == 'card' then
      if json.lang == 'es' then
        Card(json, qTbl )
      else
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/es', function(asdf)
          setCard(asdf, qTbl )
        end)
      end
    elseif json.object == 'error' then
      uLog(json);
      local url = wr.url:sub(1, -4);
      uLog(url)
      WebRequest.get(wr.url:sub(1, -4), function(asdf)
        setCardEng(asdf, qTbl )
      end)
    end
  else error('No Data Returned Contact Amuzet. setCard') end end

  function setCardEng(wr, qTbl )
    Test = true
    uLog(wr.url)
    
    if wr.text then
      local json = JSON.decode(wr.text)
      if json.object == 'card' then
        if json.lang == 'en' then
          local oracle_es = '';
          local url = 'https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20200413T002921Z.2f8572044dc49412.deb076ca1e8fdd0b7c35e94c2306ef3c00149ea5&lang=en-es&text='..json.oracle_text
           WebRequest.get(url, function(res) 
            local jsonres = JSON.decode(res.text)
            json.printed_text = jsonres.text[1]..'\n'..json.oracle_text
            Card(json, qTbl )
          end)
          
        else
          WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/en', function(asdf)
            setCard(asdf, qTbl )
          end)
        end
      elseif json.object == 'error' then
        uLog(json);
        
        Player[qTbl.color].broadcast(json.details,{1,0,0}) end
    else error('No Data Returned Contact Amuzet. setCard') end end


function spawnList(wr, qTbl )
  uLog(wr.url)
  if wr.text then
    local n,json = 1,JSON.decode(wr.text)
    if json.object == 'list' then
      for i,v in ipairs(json.data) do Wait.time( function()Card(v,qTbl) end, i*Tick) end
      n = #json.data
    elseif json.object == 'card' then
      Card(json, qTbl )
    elseif json.object == 'error' then
      Player[qTbl.color].broadcast(json.details,{1,0,0})
    end
    delay('endLoop', n)
  else error('No Data Returned Contact Amuzet. spawnList') end endLoop() end

local dFile = {
  dckCheck = '%[[%w_]+:%w+%]',
  dck = function(line)
    local set, num, name = line:match('%[([%w_]+):(%w+)%] (%w.*)')
    set = set:gsub('_.*',''):lower()
    return 'https://api.scryfall.com/cards/'..set..'/'..num end,
  
  decCheck = '%[[%w_]+%]',
  dec = function(line)
    local set, name = line:match('%[([%w_]+)%] (%w.*)')
    set = set:gsub('_.*',''):lower()
    return 'https://api.scryfall.com/cards/named?fuzzy='..name..'&set='..set end,
  
  defCheck = '%d%s+%w+',
  def = function(line)
    local name = line:gsub('%[[^%]]%]',''):match('(%w.*)')
    return 'https://api.scryfall.com/cards/named?fuzzy='..name end}

--[[Deck spawning]]
function spawnDeck(wr,qTbl)
  if wr.text:find('!DOCTYPE') then
    uLog(wr.url,'Mal Formated Deck '..qTbl.color)
    uNotebook('D'..qTbl.color,wr.url)
    Player[qTbl.color].broadcast('Your Deck list could not be found\nMake sure the Deck is set to PUBLIC',{1,0.5,0})
  else
    uLog(wr.url,'Deck Spawned by '..qTbl.color)
    local deck, ft, list = {}, 'def', wr.text:gsub('[\n]%S*Sideboard.*','')
    
--[[if qTbl.mode == 'Sideboard' then list = wr.text:match('Sideboard(.*)') end
    list = list:gsub('Maybeboard.*','')]]
    
    for k,v in pairs(dFile) do
      if type(v) == 'string' and list:find(v) then
        ft = k:sub(1,3)
        uLog(ft)
      end
    end
    
    list:gsub('(%d+).?([^\r\n]+)',function(a,b)
        local url = dFile[ft](b)
        for i = 1 , a do
          table.insert( deck , url )
        end end)
    
    qTbl.deck = #deck
    
    for i,url in ipairs(deck) do
      Wait.time(function()
          WebRequest.get(url,function(c)
              setCard(c, qTbl ) end) end, i*Tick) end
    
    delay('endLoop',#deck )
end end

function spawnParse(wr,qTbl,g,url)
  uLog(wr.text,wr.url)
  qTbl.deck = 0
  wr.text:gsub(g,function(uid)
      qTbl.deck = qTbl.deck + 1
      Wait.time(function()
          WebRequest.get(url..uid,
            function(c) setCard(c,qTbl) end ) end, i*Tick ) end )
  delay('endLop',i)
end

local DeckSites = {
  --domain as key in table set to a function that takes a string and returns a url, and function name
  --Default Function name 'spawnDeck' requires a url that returns a plain text deck list.
  mtggoldfish = function(a)
    return a, function(b,qTbl)
      Player[qTbl.color].broadcast('MTG Goldfish Deck list currently broken',{0.9,0.1,0.1})
      endLoop()
    end end,
    
  archidekt = function(a) return 'https://archidekt.com/api/decks/'..a:match('/(%d+)')..'/', function(wr,qTbl)
    qTbl.deck = 0
    wr.text:gsub('uid":(.*quantity":%d+)',function(b)
        uLog(b)
        for i=1,b:match('%d+',-3) do
          qTbl.deck = qTbl.deck + 1
          Wait.time(function()
              WebRequest.get('https://api.scryfall.com/cards/'..b:match('[*"]+',2),
                function(c) setCard(c,qTbl) end ) end, i*Tick ) end end )
    delay('endLop',i)
    end end,
    
  cubetutor = function(a)
    return a, function(wr,qTbl)
      local deck = {}
        wr.text:gsub('class="cardPreview "[^>]*>([^<]*)<',function(b)
            table.insert(deck,b) uLog(b)
          end)
      qTbl.deck = #deck
      for i,v in ipairs(deck)do
        Wait.time(function()
            WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..v,function(c)
                setCard(c, qTbl ) end) end, i*Tick) end
      delay('endLop',#deck)
    end end,
  --[[Key = function(URL) return modifiedURL, listHandlerFunction end,]]
  deckstats = function(a) return a..'?export_txt=1', spawnDeck end,
    
  tappedout = function(a) return a..'?fmt=txt', spawnDeck end,
    
  pastbin = function(a) return a:gsub('com/','com/raw/'), spawnDeck end,
    
  deckbox = function(a) return a..'/export', spawnDeck end,
    }
--[[Importer Data Structure]]
local Importer = setmetatable({
  --Variables
  request = {},
  --Functions
  Search = function( qTbl )
    WebRequest.get('https://api.scryfall.com/cards/search?q='..qTbl.name,function(wr)
        spawnList(wr, qTbl ) end) end,
  
  Back = function( qTbl )
    if qTbl.target then
      qTbl.url = qTbl.target.getJSON():match('BackURL": "([^"]*)"')
    end
    Back[qTbl.player] = qTbl.url
    Player[qTbl.color].broadcast('Card Backs set to\n'..qTbl.url,{0.9,0.9,0.9})
    endLoop() end,
  
  Spawn = function( qTbl )
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local obj = JSON.decode( wr.text )
        if obj.object == 'card' and obj.type_line:match('Token') then
          WebRequest.get('https://api.scryfall.com/cards/search?unique=card&q=t%3Atoken+'..qTbl.name:gsub(' ','%%20'),function(wr)
              spawnList(wr, qTbl) end)
          return false
        else
          setCard(wr, qTbl )
          endLoop()
        end end) end,
    
  Token = function( qTbl )
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local json = JSON.decode(wr.text)
        if json.all_parts then
          for _,v in ipairs(json.all_parts) do
            if v.name ~= json.name then
            WebRequest.get(v.uri,function(wr)
                setCard(wr, qTbl )
              end) end end
          delay('endLoop',#json.all_parts )
        else
          Player[qTbl.color].broadcast('No Tokens Found',{0.9,0.9,0.9})
          endLoop() end end) end,
  
  Print = function( qTbl )
    local url,n = 'https://api.scryfall.com/cards/search?unique=prints&q=',qTbl.name:lower():gsub('%s','')
    if n=='plains' or n=='island' or n=='swamp' or n=='mountain' or n=='forest' then
      --url = url:gsub('prints','art') end
      broadcastToAll('Please Do NOT print Basics\nIf you would like a specific Basic find its art online\nSpawn it using "Importer URL BASICLANDNAME"',{0.9,0.9,0.9})
      endLoop()
    else
    WebRequest.get(url..qTbl.name,function(wr)
        spawnList(wr, qTbl ) end) end end,
  
  Text = function( qTbl )
    WebRequest.get('https://api.scryfall.com/cards/named?format=text&fuzzy='..qTbl.name,function(wr)
        if qTbl.target then qTbl.target.setDescription(wr.text)
        else Player[qTbl.color].broadcast(wr.text) end
        endLoop() end) end,
  
  Rules = function( qTbl )
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        WebRequest.get( JSON.decode(wr.text).rulings_uri , function(wr)
          local data = JSON.decode(wr.text)
          local text = '[00cc88]'
          if data[1] then
            for _,v in pairs(data)do
              text = text..v.published_at..'[-]\n[ff7700]'..v.comment..'[-][00cc88]\n'
            end
          else text = 'No Rulings'end
          
          if text:len()>2000 then
            uNotebook('R'..SF.request,text)
            broadcastToAll('Rulings are too long!\nFull rulings can be found in the Notebook',{0.9,0.9,0.9})
          elseif qTbl.target then
            qTbl.target.setDescription(text)
          else
            broadcastToAll(text,{0.9,0.9,0.9})
          end
          endLoop() end) end) end,
  
  Random = function( qTbl )
    local url, q = 'https://api.scryfall.com/cards/random', '?q='
    for k,m in pairs({i='t%3Ainstant',s='t%3Asorcery',e='t%3Aenchantment',c='t%3Acreature',a='t%3Aartifact',l='t%3Aland'}) do
      if string.match( qTbl.name:lower(),k) then q = q .. m .. '+' end end
    local cmc = qTbl.name:match('%d+')
    if cmc then q = q .. 'cmc%3A' .. cmc .. '+' end
    if q ~= '?q=' then url = string.sub(url .. q,1,-1) end
    uLog(url,qTbl.color..' Importer Random '..qTbl.name)
    WebRequest.get(url,function(wr)
        setCard(wr, qTbl )
        endLoop() end) end,
  
  Quality = function( qTbl )
    for k,v in pairs({s='small',n='normal',l='large',a='art_crop',b='border_crop'}) do
      if qTbl.name:find(v) then Quality[qTbl.player] = v end end
    endLoop() end,
  
  Deck = function( qTbl )
    if qTbl.url then
      for k,v in pairs( DeckSites ) do
        if qTbl.url:find(k) then
          local url,deckFunction = v( qTbl.url )
          WebRequest.get( url , function(wr) deckFunction( wr , qTbl ) end)
          return true end end
    elseif qTbl.mode == 'Deck' then
      local d = getNotebookTabs()
      d = d[#d]
      spawnDeck({
          text = d.body,
          url = 'Notebook '..d.title..d.color}, qTbl )
    end return false end,
  
    },{
  __call = function(t, qTbl )
    if qTbl then
      uLog( qTbl , 'Importer Request '..qTbl.color )
      table.insert(t.request, qTbl )
    end
    --Main Logic
    if t.request[4] and qTbl then
      Player[qTbl.color].broadcast('Clearing Previous requests yours added and being processed.')
      endLoop()
    elseif qTbl and t.request[2] then
      Player[qTbl.color].broadcast('Your request has been added to the list and is being processed.')
    elseif t.request[1] then
      local tbl = t.request[1]
      --Logic Branch
      if tbl.url and tbl.mode ~= 'Back' then
        if not t.Deck( tbl ) then
        --If URL is not Deck list then
        --Custom Image Replace
        Card.image = tbl.url
        t.Spawn( tbl )
        end
      elseif t[tbl.mode] then
        --Execute that Mode
        t[tbl.mode]( tbl )
      else
        --Attempt to Spawn
        t.Spawn( tbl )
      end
    elseif qTbl then broadcastToAll('Something went Wrong please contact Amuzet\nImporter did not get a mode. MAIN LOGIC')
  end end})

--[[Functions used everywhere else]]
local Usage = 'Something is wrong'
function endLoop()
  if Importer.request[1] then table.remove(Importer.request,1) end
  Importer()
end
function delay( fName , tbl )
  local timerParams = {
    function_name = fName,
    identifier = fName..'Timer'
  }
  
  if type(tbl) == 'table' then timerParams.parameters = tbl end
  if type(tbl) == 'number' then timerParams.delay = tbl * 0.20
  else timerParams.delay = 1.5 end
  
  Timer.destroy(timerParams.identifier)
  Timer.create(timerParams)
end
function uLog(a,b) if Test then log(a,b) end end
function uNotebook(t,b,c)
  local p = { index = -1, title = t, body = b or '', color = c or 'Grey'}
  for i,v in ipairs(getNotebookTabs()) do
    if v.title == p.title then
      p.index = i
  end end
  if p.index<0 then
    addNotebookTab(p)
  else
    removeNotebookTab(p.index)
    addNotebookTab(p)
  end return p.index end
function uVersion(wr)
  uLog(wr.is_done,'Checking Importer Version')
  local v = wr.text:match(mod_name..' Version %d+%p%d+')
  if v then v=v:match('%d+%p%d+') else v = version end
  Usage = [[    [753FC9][b]%s[-]
[0077ff]Scryfall[/b] [i]cardname[/i]  [-][Prints oracle text of card name]
[b][0077ff]Scryfall[/b] [i]URL cardname[/i]  [-][Spawns [i]card name[/i] with [i]URL[/i] as it face]
[b][0077ff]Scryfall[/b] [i]URL[/i]  [-][Spawn that deck list or Image]
 pastebin cubetutor tappedout.net deckstats.net deckbox.org

[b][753FC9]Scryfall[/b] [i]command[/i] [-][Executes that command]

[b][ff7700]help[/b] [-][Prints this text]
[b][ff7700]hide[/b] [-][Hides Importer Commands]
[b][ff7700]deck[/b] [-][Spawn deck from Notebook]
[b][ff7700]deck[/b] [i]URL[/i] [-][Spawn deck from the URL]
[b][ff7700]back[/b] [i]URL[/i] [-][Makes card back URL]
[b][ff7700]text[/b] [i]cardname[/i] [-][Prints Oracle text here]
[b][ff7700]legal[/b] [i]cardname[/i] [-][Prints the card name legalities]
[b][ff7700]rules[/b] [i]cardname[/i] [-][Prints the card name rulings]
[b][ff7700]random[/b] [i]isecal[/i] [-][Fills field with ANY random card]
[b][ff7700]quality[/b] [i]mode[/i] [-][Changes the quality of the image]
[i]small,normal,large,art_crop,border_crop[/i] ]]

  Usage = Usage:format(self.getName())

  if version < tonumber(v) then
    Usage = Usage..'\n[77ff00]Update:'..tonumber(v)..' Ready for Importer Module'
  elseif version > tonumber(v) or Test then
    Test = true
    Usage = Usage..'\n[fff600]Experimental Version of Importer Module'
  end
  uNotebook('SHelp',Usage)
  self.setDescription(Usage:gsub('[^\n]*\n','',1):gsub('%]  %[',']\n['):gsub('\n\n','\n'))
  printToAll(Usage,{0.9,0.9,0.9})
end

--[[Tabletop Callbacks]]
function onSave() self.script_state = JSON.encode(Back) end
function onLoad(data)
  WebRequest.get(WorkshopID,self,'uVersion')
  if data ~= '' then Back = JSON.decode(data) end
  self.createButton({label = "+",click_function = 'registerModule',function_owner = self,position = {0,0.2,-0.5},height = 100,width = 100,font_size = 100,tooltip = "Adds Oracle Look Up"})
  if self.getLock() then registerModule() end end

local chatToggle = false
function onChat(msg,player)
  if msg:find('Scryfall ') or msg:find('!S%S* ') then
    local a = msg:match('Scryfall (.*)') or msg:match('![SI]%S* (.*)') or false
    if a=='hide' and player.admin then
      chatToggle = not chatToggle
      if chatToggle then msg = 'supressing' else msg = 'showing' end
      broadcastToAll('Importer now '..msg..' Chat messages with Importer in them.\nToggle this with "Importer Hide"',{0.9,0.9,0.9})
    elseif a=='help' then
      player.print(Usage,{0.9,0.9,0.9})
    elseif a=='clear' then
      Back = TBL.new(Back.___,{})
      self.script_state = ''
    elseif a then
      local tbl = {
        position = player.getPointerPosition(),
        player = player.steam_id,
        color = player.color,
        url = a:match('(http%S+)'),
        mode = a:gsub('(http%S+)',''):match('(%S+)'),
        name = a:gsub('(http%S+)',''):gsub(' ',''),
      }
      
      if tbl.mode then
        for k,v in pairs(Importer)do
          if tbl.mode:lower() == k:lower() and type(v) == 'function' then
            tbl.mode = k
            tbl.name = tbl.name:lower():gsub(k:lower(),'',1)
            break
        end end
      end
      
      if tbl.name:len() < 1 or tbl.name == ' ' then
        tbl.name = 'island'
      else
        tbl.name = tbl.name:gsub('%s','')
      end
      
      Importer(tbl)
      if chatToggle then uLog(msg,player.steam_name) return false end
end end end

--[[Card Encoder]]
pID = mod_name

function ENC(o,p,m)
  enc.call('APIrebuildButtons',{obj = o})
  local ply = Player[p:lower()]
  if m then
    Importer({
      position = {
        o.getPosition().x +1,
        o.getPosition().y +1,
        o.getPosition().z +1,
      },
      target = o,
      player = ply.steam_id,
      color = p,
      name = o.getName():gsub('\n.*','') or 'Energy Reserve',
      mode = m})
    
  else return ply end end

function registerModule()
  enc = Global.getVar('Encoder')
  if enc then
    buttons = {'Respawn','Oracle','Rulings','Emblem\nAnd Tokens','Printings','Set Sleeve','Reverse Card'}
    enc.call('APIregisterTool',{
        toolID = pID,
        name = pID,
        funcOwner = self,
        activateFunc = 'toggleMenu',
        display = true})
    function eEmblemAndTokens(o,p) ENC(o,p,'Token')end
    function eOracle(o,p)          ENC(o,p,'Text') end
    function eRulings(o,p)         ENC(o,p,'Rules')end
    function ePrintings(o,p)       ENC(o,p,'Print')end
    function eRespawn(o,p)         ENC(o,p,'Spawn')end
    function eSetSleeve(o,p)       ENC(o,p,'Back') end
    function eReverseCard(o,p)
      ENC(o,p)
      spawnObjectJSON({
          json = o.getJSON():gsub('BackURL','FaceURL'):gsub('FaceURL','BackURL',1)
        })
end end end

Button = setmetatable({
    label = 'UNDEFINED',
    click_function = 'eOracle',
    function_owner = self,
    height = 400,
    width = 2100,
    font_size = 360,
    scale = {0.4,0.4,0.4},
    position = {0,0.28,-1.35},
    rotation = {0,0,90},
    reset = function(t)
      t.label = 'UNDEFINED'
      t.position = {0,0.28,-1.35}
    end
  },{
    __call = function(t,o,l,f)
      local inc, i = 0.325, 0
      l:gsub('\n',function()
          t.height = t.height + 400
          inc = inc + 0.1625
          i = i + 1 end)
      t.label = l
      t.click_function = 'e'..l:gsub('%s','')
      t.position = { 0 , 0.28 * f , t.position[3] + inc}
      t.rotation[3] = 90 - 90 * f
      o.createButton(t)
      t.height = 400
      if i % 2 == 1 then t.position[3] = t.position[3] + 0.1625 end
    end
  })

function toggleMenu(o)
  enc = Global.getVar('Encoder')
  if enc then
    flip = enc.call("APIgetFlip",{obj = o})
    for i,v in ipairs(buttons)do
      Button( o , v , flip )
    end
    Button:reset()
end end

--[[Colored Type Writen by Tipsy Hobbit]]
local oldName, basetable = '', '0123456789abcdefghijklmnopqrstuvwxyz'

local function tonum(num,base)
  if type(num) == 'string' or type(num) == 'number' then
    num = ''..num
    local total, l = 0, #num
    for i = 1, #num do
      local c = num:sub(i,i)
      c_val = string.find(basetable,c)
      if c_val <= base then
        total = total + base^(l-i)*c_val
      else
        return nil
      end
    end
    return total
  end
  return nil
end
function hex_to_rgb(val)
  hex = string.match(val,'[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]')
  if hex == nil then
    return {256,256,256}
  else
    return {tonum(string.sub(hex,1,2),16),tonum(string.sub(hex,3,4),16),tonum(string.sub(hex,5,6),16)}
  end
end
function rgb_to_hex(val)
  return string.format('%x',val[1])..string.format('%x',val[2])..string.format('%x',val[3])
end
function string_to_color(str)
  return string.sub(string.format('%x',tonum(string.sub(string.gsub(string.lower(str),'%W',''),1,-2),36))..'ffffff',1,6)
end
function lightenColor(hex,ammount)
  local cur, color = 0, hex_to_rgb(hex)
  for i,j in pairs(color) do
    cur = cur+j
  end
  while cur < ammount do
    cur = 0
    for i,j in pairs(color) do
      if j < 256 then
        color[i] = j+2
      end
      cur = cur+color[i]
    end
  --print(cur)
  end
  return rgb_to_hex(color)
end
--EOF