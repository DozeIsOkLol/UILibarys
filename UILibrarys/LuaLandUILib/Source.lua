local LuaLandLibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local IconsDict = {
	["a-arrow-down"] = "rbxassetid://92867583610071",
	["a-arrow-up"] = "rbxassetid://132318504999733",
	["a-large-small"] = "rbxassetid://111491496660216",
	["accessibility"] = "rbxassetid://114029945302017",
	["activity"] = "rbxassetid://94212016861936",
	["air-vent"] = "rbxassetid://81517226012329",
	["airplay"] = "rbxassetid://115020759309179",
	["alarm-clock-check"] = "rbxassetid://76437352099157",
	["alarm-clock-minus"] = "rbxassetid://77364179863205",
	["alarm-clock-off"] = "rbxassetid://97904885874823",
	["alarm-clock-plus"] = "rbxassetid://80468822979214",
	["alarm-clock"] = "rbxassetid://126259032907535",
	["alarm-smoke"] = "rbxassetid://96965448419685",
	["album"] = "rbxassetid://127358331163602",
	["align-center-horizontal"] = "rbxassetid://81570549209434",
	["align-center-vertical"] = "rbxassetid://118470463752466",
	["align-end-horizontal"] = "rbxassetid://139502909745427",
	["align-end-vertical"] = "rbxassetid://96528869059554",
	["align-horizontal-distribute-center"] = "rbxassetid://97220086126656",
	["align-horizontal-distribute-end"] = "rbxassetid://106128590702022",
	["align-horizontal-distribute-start"] = "rbxassetid://76074660002997",
	["align-horizontal-justify-center"] = "rbxassetid://75732302772427",
	["align-horizontal-justify-end"] = "rbxassetid://129167626402283",
	["align-horizontal-justify-start"] = "rbxassetid://130161830325281",
	["align-horizontal-space-around"] = "rbxassetid://91646106782950",
	["align-horizontal-space-between"] = "rbxassetid://103886093046990",
	["align-start-horizontal"] = "rbxassetid://125674804697729",
	["align-start-vertical"] = "rbxassetid://105020230154823",
	["align-vertical-distribute-center"] = "rbxassetid://93791183635525",
	["align-vertical-distribute-end"] = "rbxassetid://139354223511433",
	["align-vertical-distribute-start"] = "rbxassetid://74961997822126",
	["align-vertical-justify-center"] = "rbxassetid://134754696166569",
	["align-vertical-justify-end"] = "rbxassetid://92569381441969",
	["align-vertical-justify-start"] = "rbxassetid://99692844572718",
	["align-vertical-space-around"] = "rbxassetid://96206012459190",
	["align-vertical-space-between"] = "rbxassetid://124998077349706",
	["ambulance"] = "rbxassetid://78599995190651",
	["ampersand"] = "rbxassetid://75272915739209",
	["ampersands"] = "rbxassetid://126947193455996",
	["amphora"] = "rbxassetid://137370389604364",
	["anchor"] = "rbxassetid://92181172123618",
	["angry"] = "rbxassetid://74237056000103",
	["annoyed"] = "rbxassetid://80064369052011",
	["antenna"] = "rbxassetid://99628923540956",
	["anvil"] = "rbxassetid://100203029845919",
	["aperture"] = "rbxassetid://83396154449972",
	["app-window-mac"] = "rbxassetid://79587216113811",
	["app-window"] = "rbxassetid://93142176757189",
	["apple"] = "rbxassetid://104349242902442",
	["archive-restore"] = "rbxassetid://78956681942188",
	["archive-x"] = "rbxassetid://75830115088395",
	["archive"] = "rbxassetid://122180020814574",
	["armchair"] = "rbxassetid://105384358373973",
	["arrow-big-down-dash"] = "rbxassetid://137987229582002",
	["arrow-big-down"] = "rbxassetid://81081164158885",
	["arrow-big-left-dash"] = "rbxassetid://97827621354677",
	["arrow-big-left"] = "rbxassetid://85973092492641",
	["arrow-big-right-dash"] = "rbxassetid://117825834972403",
	["arrow-big-right"] = "rbxassetid://82960676755590",
	["arrow-big-up-dash"] = "rbxassetid://99260194327483",
	["arrow-big-up"] = "rbxassetid://93136954756149",
	["arrow-down-0-1"] = "rbxassetid://120961896217875",
	["arrow-down-1-0"] = "rbxassetid://93474255891850",
	["arrow-down-a-z"] = "rbxassetid://99554596207900",
	["arrow-down-from-line"] = "rbxassetid://132045845807798",
	["arrow-down-left"] = "rbxassetid://102899325237364",
	["arrow-down-narrow-wide"] = "rbxassetid://129105261655061",
	["arrow-down-right"] = "rbxassetid://123109928624974",
	["arrow-down-to-dot"] = "rbxassetid://101675355931221",
	["arrow-down-to-line"] = "rbxassetid://87050478931254",
	["arrow-down-up"] = "rbxassetid://85780258549577",
	["arrow-down-wide-narrow"] = "rbxassetid://88461733425991",
	["arrow-down-z-a"] = "rbxassetid://76115279362232",
	["arrow-down"] = "rbxassetid://98764963621439",
	["arrow-left-from-line"] = "rbxassetid://87857914437603",
	["arrow-left-right"] = "rbxassetid://131324733048447",
	["arrow-left-to-line"] = "rbxassetid://118645136026970",
	["arrow-left"] = "rbxassetid://102531941843733",
	["arrow-right-from-line"] = "rbxassetid://74073639809355",
	["arrow-right-left"] = "rbxassetid://77015754304300",
	["arrow-right-to-line"] = "rbxassetid://78632510329852",
	["arrow-right"] = "rbxassetid://113692007244654",
	["arrow-up-0-1"] = "rbxassetid://105257823943016",
	["arrow-up-1-0"] = "rbxassetid://134175521693798",
	["arrow-up-a-z"] = "rbxassetid://77763416595160",
	["arrow-up-down"] = "rbxassetid://81019887641527",
	["arrow-up-from-dot"] = "rbxassetid://124408496673275",
	["arrow-up-from-line"] = "rbxassetid://95777664626453",
	["arrow-up-left"] = "rbxassetid://123490598231261",
	["arrow-up-narrow-wide"] = "rbxassetid://73006024672636",
	["arrow-up-right"] = "rbxassetid://129280608535523",
	["arrow-up-to-line"] = "rbxassetid://108818207813537",
	["arrow-up-wide-narrow"] = "rbxassetid://87437426951568",
	["arrow-up-z-a"] = "rbxassetid://107546173611884",
	["arrow-up"] = "rbxassetid://89282378235317",
	["arrows-up-from-line"] = "rbxassetid://133710016938621",
	["asterisk"] = "rbxassetid://88552752106723",
	["at-sign"] = "rbxassetid://79059152889146",
	["atom"] = "rbxassetid://73167696981648",
	["audio-lines"] = "rbxassetid://70930641819242",
	["audio-waveform"] = "rbxassetid://86462036665209",
	["award"] = "rbxassetid://132740088158419",
	["axe"] = "rbxassetid://132405197863294",
	["axis-3d"] = "rbxassetid://122438676546804",
	["baby"] = "rbxassetid://93472926933440",
	["backpack"] = "rbxassetid://140420225386018",
	["badge-alert"] = "rbxassetid://101829200081951",
	["badge-cent"] = "rbxassetid://133345018873154",
	["badge-check"] = "rbxassetid://76078495178149",
	["badge-dollar-sign"] = "rbxassetid://127139803581141",
	["badge-euro"] = "rbxassetid://120016477674659",
	["badge-indian-rupee"] = "rbxassetid://75659682309981",
	["badge-info"] = "rbxassetid://131995373201472",
	["badge-japanese-yen"] = "rbxassetid://99081574588615",
	["badge-minus"] = "rbxassetid://140321561183881",
	["badge-percent"] = "rbxassetid://121359224294885",
	["badge-plus"] = "rbxassetid://100325578561866",
	["badge-pound-sterling"] = "rbxassetid://119688217279444",
	["badge-question-mark"] = "rbxassetid://121464963737502",
	["badge-russian-ruble"] = "rbxassetid://108839463659864",
	["badge-swiss-franc"] = "rbxassetid://91447608372740",
	["badge-turkish-lira"] = "rbxassetid://137839965873529",
	["badge-x"] = "rbxassetid://122931434733842",
	["badge"] = "rbxassetid://116620312917084",
	["baggage-claim"] = "rbxassetid://86922213051957",
	["balloon"] = "rbxassetid://97489111621526",
	["ban"] = "rbxassetid://90767043015246",
	["banana"] = "rbxassetid://140713420056179",
	["bandage"] = "rbxassetid://129660129590770",
	["banknote-arrow-down"] = "rbxassetid://139366449345199",
	["banknote-arrow-up"] = "rbxassetid://133758343082529",
	["banknote-x"] = "rbxassetid://95348701438065",
	["banknote"] = "rbxassetid://104840231536668",
	["barcode"] = "rbxassetid://118473018143689",
	["barrel"] = "rbxassetid://130647115622774",
	["baseline"] = "rbxassetid://124677132511270",
	["bath"] = "rbxassetid://76031400297942",
	["battery-charging"] = "rbxassetid://80139357470047",
	["battery-full"] = "rbxassetid://70906718268972",
	["battery-low"] = "rbxassetid://139659256984314",
	["battery-medium"] = "rbxassetid://105934079398915",
	["battery-plus"] = "rbxassetid://91931341486966",
	["battery-warning"] = "rbxassetid://115230083817257",
	["battery"] = "rbxassetid://70765800346189",
	["beaker"] = "rbxassetid://80902539995520",
	["bean-off"] = "rbxassetid://98164436608714",
	["bean"] = "rbxassetid://89491967076869",
	["bed-double"] = "rbxassetid://73820193212911",
	["bed-single"] = "rbxassetid://113423940880634",
	["bed"] = "rbxassetid://97726529032925",
	["beef-off"] = "rbxassetid://99869959725200",
	["beef"] = "rbxassetid://105850162318915",
	["beer-off"] = "rbxassetid://120333134736361",
	["beer"] = "rbxassetid://116404978807744",
	["bell-dot"] = "rbxassetid://93161277118810",
	["bell-electric"] = "rbxassetid://100277767266983",
	["bell-minus"] = "rbxassetid://126334890449727",
	["bell-off"] = "rbxassetid://78560046118930",
	["bell-plus"] = "rbxassetid://77014333795836",
	["bell-ring"] = "rbxassetid://94612128913941",
	["bell"] = "rbxassetid://97392696311902",
	["between-horizontal-end"] = "rbxassetid://81602774794322",
	["between-horizontal-start"] = "rbxassetid://76112384929846",
	["between-vertical-end"] = "rbxassetid://72817612571631",
	["between-vertical-start"] = "rbxassetid://85278312190301",
	["biceps-flexed"] = "rbxassetid://82004462003936",
	["bike"] = "rbxassetid://102930322246035",
	["binary"] = "rbxassetid://91751953950088",
	["binoculars"] = "rbxassetid://101460003267896",
	["biohazard"] = "rbxassetid://95956532900432",
	["bird"] = "rbxassetid://132284145117371",
	["birdhouse"] = "rbxassetid://83999157401433",
	["bitcoin"] = "rbxassetid://95459240442938",
	["blend"] = "rbxassetid://111679612185257",
	["blinds"] = "rbxassetid://71164165283925",
	["blocks"] = "rbxassetid://72212693357737",
	["bluetooth-connected"] = "rbxassetid://96315134002985",
	["bluetooth-off"] = "rbxassetid://80600044218117",
	["bluetooth-searching"] = "rbxassetid://100673019606426",
	["bluetooth"] = "rbxassetid://90506573139443",
	["bold"] = "rbxassetid://116141470019166",
	["bolt"] = "rbxassetid://102881251417484",
	["bomb"] = "rbxassetid://139223800924636",
	["bone"] = "rbxassetid://111242153474115",
	["book-a"] = "rbxassetid://104067275658465",
	["book-alert"] = "rbxassetid://124159928044853",
	["book-audio"] = "rbxassetid://109208148317037",
	["book-check"] = "rbxassetid://115999656081696",
	["book-copy"] = "rbxassetid://108543407492005",
	["book-dashed"] = "rbxassetid://127430784795958",
	["book-down"] = "rbxassetid://101011730128222",
	["book-headphones"] = "rbxassetid://108670200799574",
	["book-heart"] = "rbxassetid://112788845135284",
	["book-image"] = "rbxassetid://80808285757226",
	["book-key"] = "rbxassetid://116024426170705",
	["book-lock"] = "rbxassetid://118765061220571",
	["book-marked"] = "rbxassetid://73211024251780",
	["book-minus"] = "rbxassetid://112724962046282",
	["book-open-check"] = "rbxassetid://130848362492667",
	["book-open-text"] = "rbxassetid://100629528672195",
	["book-open"] = "rbxassetid://129845326810392",
	["book-plus"] = "rbxassetid://140267785051233",
	["book-search"] = "rbxassetid://132585409504950",
	["book-text"] = "rbxassetid://94011772484232",
	["book-type"] = "rbxassetid://97817304725443",
	["book-up-2"] = "rbxassetid://130161620853665",
	["book-up"] = "rbxassetid://98640174079190",
	["book-user"] = "rbxassetid://128489189240523",
	["book-x"] = "rbxassetid://118754548186537",
	["book"] = "rbxassetid://125383279695672",
	["bookmark-check"] = "rbxassetid://93940443347986",
	["bookmark-minus"] = "rbxassetid://96807096039910",
	["bookmark-plus"] = "rbxassetid://121469724491615",
	["bookmark-x"] = "rbxassetid://112272342584706",
	["bookmark"] = "rbxassetid://121093149326239",
	["boom-box"] = "rbxassetid://99901322535868",
	["bot-message-square"] = "rbxassetid://96145330292478",
	["bot-off"] = "rbxassetid://140417690560013",
	["bot"] = "rbxassetid://80451686744860",
	["bottle-wine"] = "rbxassetid://131675403196921",
	["bow-arrow"] = "rbxassetid://124089655150375",
	["box"] = "rbxassetid://101768155599700",
	["boxes"] = "rbxassetid://136372617578355",
	["braces"] = "rbxassetid://117761094704041",
	["brackets"] = "rbxassetid://74368995728099",
	["brain-circuit"] = "rbxassetid://70547962410202",
	["brain-cog"] = "rbxassetid://132039205501538",
	["brain"] = "rbxassetid://92424107303177",
	["brick-wall-fire"] = "rbxassetid://92980588705520",
	["brick-wall-shield"] = "rbxassetid://75954432775071",
	["brick-wall"] = "rbxassetid://112878522258821",
	["briefcase-business"] = "rbxassetid://129135125207283",
	["briefcase-conveyor-belt"] = "rbxassetid://108665725653714",
	["briefcase-medical"] = "rbxassetid://119917756334087",
	["briefcase"] = "rbxassetid://96754188164225",
	["bring-to-front"] = "rbxassetid://132975903553748",
	["brush-cleaning"] = "rbxassetid://71728977448805",
	["brush"] = "rbxassetid://127035535799640",
	["bubbles"] = "rbxassetid://106183424168227",
	["bug-off"] = "rbxassetid://88020025049245",
	["bug-play"] = "rbxassetid://80107955888092",
	["bug"] = "rbxassetid://83626408925438",
	["building-2"] = "rbxassetid://77873775611951",
	["building"] = "rbxassetid://110616258983082",
	["bus-front"] = "rbxassetid://89863432456045",
	["bus"] = "rbxassetid://133798469717463",
	["cable-car"] = "rbxassetid://128643682205596",
	["cable"] = "rbxassetid://128449944504901",
	["cake-slice"] = "rbxassetid://136769828413242",
	["cake"] = "rbxassetid://103131590503275",
	["calculator"] = "rbxassetid://74915716529646",
	["calendar-1"] = "rbxassetid://98458364171044",
	["calendar-arrow-down"] = "rbxassetid://108415736543437",
	["calendar-arrow-up"] = "rbxassetid://70574654109118",
	["calendar-check-2"] = "rbxassetid://120231170248276",
	["calendar-check"] = "rbxassetid://71551019465748",
	["calendar-clock"] = "rbxassetid://119132152594595",
	["calendar-cog"] = "rbxassetid://122402172360287",
	["calendar-days"] = "rbxassetid://99072017568595",
	["calendar-fold"] = "rbxassetid://117368871270394",
	["calendar-heart"] = "rbxassetid://88839008103676",
	["calendar-minus-2"] = "rbxassetid://98846170279891",
	["calendar-minus"] = "rbxassetid://137354318924383",
	["calendar-off"] = "rbxassetid://109726151749217",
	["calendar-plus-2"] = "rbxassetid://112264562093883",
	["calendar-plus"] = "rbxassetid://125266115249843",
	["calendar-range"] = "rbxassetid://103641849247576",
	["calendar-search"] = "rbxassetid://92010083223634",
	["calendar-sync"] = "rbxassetid://78082218499697",
	["calendar-x-2"] = "rbxassetid://107518051061147",
	["calendar-x"] = "rbxassetid://106703374806500",
	["calendar"] = "rbxassetid://114792700814035",
	["calendars"] = "rbxassetid://130944763042289",
	["camera-off"] = "rbxassetid://81057636835256",
	["camera"] = "rbxassetid://79950339943067",
	["candy-cane"] = "rbxassetid://71689468772492",
	["candy-off"] = "rbxassetid://110232752314832",
	["candy"] = "rbxassetid://107812129154678",
	["cannabis"] = "rbxassetid://98792006538601",
	["captions-off"] = "rbxassetid://105223545364193",
	["captions"] = "rbxassetid://104960225031445",
	["car-front"] = "rbxassetid://87380942739063",
	["car-taxi-front"] = "rbxassetid://122455403384057",
	["car"] = "rbxassetid://121065933462582",
	["caravan"] = "rbxassetid://120070979471783",
	["card-sim"] = "rbxassetid://134490550095771",
	["carrot"] = "rbxassetid://119118221444304",
	["case-lower"] = "rbxassetid://129303130603241",
	["case-sensitive"] = "rbxassetid://125410273293056",
	["case-upper"] = "rbxassetid://111633433531325",
	["cassette-tape"] = "rbxassetid://137065788934157",
	["cast"] = "rbxassetid://98202245922071",
	["castle"] = "rbxassetid://119275077187784",
	["cat"] = "rbxassetid://124252153404931",
	["cctv"] = "rbxassetid://99979894766624",
	["chart-area"] = "rbxassetid://123446436762366",
	["chart-bar-big"] = "rbxassetid://72336824986044",
	["chart-bar-decreasing"] = "rbxassetid://107217459044963",
	["chart-bar-increasing"] = "rbxassetid://88268905998571",
	["chart-bar-stacked"] = "rbxassetid://98478751113024",
	["chart-bar"] = "rbxassetid://105389816384108",
	["chart-candlestick"] = "rbxassetid://125676898615697",
	["chart-column-big"] = "rbxassetid://98598733210787",
	["chart-column-decreasing"] = "rbxassetid://73586137373563",
	["chart-column-increasing"] = "rbxassetid://120421615068601",
	["chart-column-stacked"] = "rbxassetid://86031449675105",
	["chart-column"] = "rbxassetid://97915995538580",
	["chart-gantt"] = "rbxassetid://88811660555940",
	["chart-line"] = "rbxassetid://101833156055618",
	["chart-network"] = "rbxassetid://104027882693561",
	["chart-no-axes-column-decreasing"] = "rbxassetid://123371717192542",
	["chart-no-axes-column-increasing"] = "rbxassetid://140383830943049",
	["chart-no-axes-column"] = "rbxassetid://94078751170351",
	["chart-no-axes-combined"] = "rbxassetid://121424233161912",
	["chart-no-axes-gantt"] = "rbxassetid://131936541106368",
	["chart-pie"] = "rbxassetid://113412261630136",
	["chart-scatter"] = "rbxassetid://108217585014571",
	["chart-spline"] = "rbxassetid://90307460742494",
	["check-check"] = "rbxassetid://95183312173858",
	["check-line"] = "rbxassetid://115122343485290",
	["check"] = "rbxassetid://93898873302694",
	["chef-hat"] = "rbxassetid://121744015002573",
	["cherry"] = "rbxassetid://139519182403183",
	["chess-bishop"] = "rbxassetid://121701705580238",
	["chess-king"] = "rbxassetid://90885687223462",
	["chess-knight"] = "rbxassetid://96467707042169",
	["chess-pawn"] = "rbxassetid://111318574652751",
	["chess-queen"] = "rbxassetid://98304702099749",
	["chess-rook"] = "rbxassetid://76223925830262",
	["chevron-down"] = "rbxassetid://134243273101015",
	["chevron-first"] = "rbxassetid://105243363790238",
	["chevron-last"] = "rbxassetid://89268452603731",
	["chevron-left"] = "rbxassetid://73780377692148",
	["chevron-right"] = "rbxassetid://92473583511724",
	["chevron-up"] = "rbxassetid://122444883127455",
	["chevrons-down-up"] = "rbxassetid://139404716013205",
	["chevrons-down"] = "rbxassetid://100524612205956",
	["chevrons-left-right-ellipsis"] = "rbxassetid://125035817741526",
	["chevrons-left-right"] = "rbxassetid://87910685945204",
	["chevrons-left"] = "rbxassetid://82617201744347",
	["chevrons-right-left"] = "rbxassetid://87149546686569",
	["chevrons-right"] = "rbxassetid://139121276490483",
	["chevrons-up-down"] = "rbxassetid://131833120209646",
	["chevrons-up"] = "rbxassetid://100467452364672",
	["chromium"] = "rbxassetid://128165143739006",
	["church"] = "rbxassetid://113714744350666",
	["cigarette-off"] = "rbxassetid://77797883078452",
	["cigarette"] = "rbxassetid://137149549886852",
	["circle-alert"] = "rbxassetid://83898160590116",
	["circle-arrow-down"] = "rbxassetid://95901860261344",
	["circle-arrow-left"] = "rbxassetid://102148876968988",
	["circle-arrow-out-down-left"] = "rbxassetid://140598097856694",
	["circle-arrow-out-down-right"] = "rbxassetid://119952801379305",
	["circle-arrow-out-up-left"] = "rbxassetid://132858212688303",
	["circle-arrow-out-up-right"] = "rbxassetid://81783743753173",
	["circle-arrow-right"] = "rbxassetid://70786767999559",
	["circle-arrow-up"] = "rbxassetid://84395128546494",
	["circle-check-big"] = "rbxassetid://93202927221730",
	["circle-check"] = "rbxassetid://85262178816537",
	["circle-chevron-down"] = "rbxassetid://137069490345718",
	["circle-chevron-left"] = "rbxassetid://130250009740827",
	["circle-chevron-right"] = "rbxassetid://125943696958495",
	["circle-chevron-up"] = "rbxassetid://111223574026321",
	["circle-dashed"] = "rbxassetid://126799443883746",
	["circle-divide"] = "rbxassetid://106398997754208",
	["circle-dollar-sign"] = "rbxassetid://91106238890387",
	["circle-dot-dashed"] = "rbxassetid://111451232827180",
	["circle-dot"] = "rbxassetid://82947033619201",
	["circle-ellipsis"] = "rbxassetid://91687150884779",
	["circle-equal"] = "rbxassetid://95133963751438",
	["circle-fading-arrow-up"] = "rbxassetid://104648212910336",
	["circle-fading-plus"] = "rbxassetid://91847890443490",
	["circle-gauge"] = "rbxassetid://108157549473765",
	["circle-minus"] = "rbxassetid://133556159576809",
	["circle-off"] = "rbxassetid://97923456918886",
	["circle-parking-off"] = "rbxassetid://128369410981252",
	["circle-parking"] = "rbxassetid://124034962915196",
	["circle-pause"] = "rbxassetid://139337739700879",
	["circle-percent"] = "rbxassetid://133311912860256",
	["circle-play"] = "rbxassetid://120408917249739",
	["circle-plus"] = "rbxassetid://113157136350384",
	["circle-pound-sterling"] = "rbxassetid://105476153083828",
	["circle-power"] = "rbxassetid://140676030155098",
	["circle-question-mark"] = "rbxassetid://97516698664325",
	["circle-slash-2"] = "rbxassetid://136766902186549",
	["circle-slash"] = "rbxassetid://125206439913049",
	["circle-small"] = "rbxassetid://73685402843600",
	["circle-star"] = "rbxassetid://120318414957104",
	["circle-stop"] = "rbxassetid://87400503942659",
	["circle-user-round"] = "rbxassetid://95489465399880",
	["circle-user"] = "rbxassetid://136220511671311",
	["circle-x"] = "rbxassetid://76821953846248",
	["circle"] = "rbxassetid://130359823580534",
	["circuit-board"] = "rbxassetid://107695264369312",
	["citrus"] = "rbxassetid://139018222976433",
	["clapperboard"] = "rbxassetid://132660667070200",
	["clipboard-check"] = "rbxassetid://92649798577170",
	["clipboard-clock"] = "rbxassetid://123957515687745",
	["clipboard-copy"] = "rbxassetid://125851897718493",
	["clipboard-list"] = "rbxassetid://96460215958908",
	["clipboard-minus"] = "rbxassetid://107968008485671",
	["clipboard-paste"] = "rbxassetid://74382068849983",
	["clipboard-pen-line"] = "rbxassetid://77711589791615",
	["clipboard-pen"] = "rbxassetid://75290966822953",
	["clipboard-plus"] = "rbxassetid://134285318675662",
	["clipboard-type"] = "rbxassetid://89949374318028",
	["clipboard-x"] = "rbxassetid://102222456890103",
	["clipboard"] = "rbxassetid://89601995828423",
	["clock-1"] = "rbxassetid://129363225422045",
	["clock-10"] = "rbxassetid://104332695855541",
	["clock-11"] = "rbxassetid://119023205186105",
	["clock-12"] = "rbxassetid://117789618723068",
	["clock-2"] = "rbxassetid://134710777209413",
	["clock-3"] = "rbxassetid://136385631189327",
	["clock-4"] = "rbxassetid://121808839832144",
	["clock-5"] = "rbxassetid://85082019959457",
	["clock-6"] = "rbxassetid://71009733505593",
	["clock-7"] = "rbxassetid://103111188546225",
	["clock-8"] = "rbxassetid://110059272125337",
	["clock-9"] = "rbxassetid://77610027126437",
	["clock-alert"] = "rbxassetid://97157344465162",
	["clock-arrow-down"] = "rbxassetid://92349314416042",
	["clock-arrow-up"] = "rbxassetid://111484286332629",
	["clock-check"] = "rbxassetid://85231630218857",
	["clock-fading"] = "rbxassetid://93205297285245",
	["clock-plus"] = "rbxassetid://93367709263150",
	["clock"] = "rbxassetid://121808839832144",
	["cloud-alert"] = "rbxassetid://91967273658626",
	["cloud-backup"] = "rbxassetid://111649579696132",
	["cloud-check"] = "rbxassetid://97318598202432",
	["cloud-cog"] = "rbxassetid://96497764065749",
	["cloud-download"] = "rbxassetid://121435581993566",
	["cloud-drizzle"] = "rbxassetid://139525315752605",
	["cloud-fog"] = "rbxassetid://76650233148776",
	["cloud-hail"] = "rbxassetid://72320462748242",
	["cloud-lightning"] = "rbxassetid://133517088924849",
	["cloud-moon-rain"] = "rbxassetid://127667837827018",
	["cloud-moon"] = "rbxassetid://71938114737914",
	["cloud-off"] = "rbxassetid://131907154501444",
	["cloud-rain-wind"] = "rbxassetid://107414583736721",
	["cloud-rain"] = "rbxassetid://105547081967408",
	["cloud-snow"] = "rbxassetid://72307126270226",
	["cloud-sun-rain"] = "rbxassetid://99041604425705",
	["cloud-sun"] = "rbxassetid://86114208148727",
	["cloud-sync"] = "rbxassetid://79393911188593",
	["cloud-upload"] = "rbxassetid://93307473217005",
	["cloud"] = "rbxassetid://121226497050352",
	["cloudy"] = "rbxassetid://105360479023346",
	["clover"] = "rbxassetid://74925550436750",
	["club"] = "rbxassetid://108490365816628",
	["code-xml"] = "rbxassetid://130150477351734",
	["code"] = "rbxassetid://107380207681249",
	["codepen"] = "rbxassetid://135643965971885",
	["codesandbox"] = "rbxassetid://106911852964823",
	["coffee"] = "rbxassetid://106864403231093",
	["cog"] = "rbxassetid://116544501716299",
	["coins"] = "rbxassetid://116510979641930",
	["columns-2"] = "rbxassetid://113004100221850",
	["columns-3-cog"] = "rbxassetid://121589691981064",
	["columns-3"] = "rbxassetid://115223357399375",
	["columns-4"] = "rbxassetid://130807991968419",
	["combine"] = "rbxassetid://79908476334048",
	["command"] = "rbxassetid://93648221906330",
	["compass"] = "rbxassetid://115123411028382",
	["component"] = "rbxassetid://110027788875080",
	["computer"] = "rbxassetid://77480056459407",
	["concierge-bell"] = "rbxassetid://140384259310436",
	["cone"] = "rbxassetid://97759550688437",
	["construction"] = "rbxassetid://106539489968173",
	["contact-round"] = "rbxassetid://71907624112229",
	["contact"] = "rbxassetid://75868297719012",
	["container"] = "rbxassetid://91507237573499",
	["contrast"] = "rbxassetid://112796643981497",
	["cookie"] = "rbxassetid://73159504540002",
	["cooking-pot"] = "rbxassetid://94959783129799",
	["copy-check"] = "rbxassetid://91177247988892",
	["copy-minus"] = "rbxassetid://109524509933035",
	["copy-plus"] = "rbxassetid://113618379616952",
	["copy-slash"] = "rbxassetid://93805787810390",
	["copy-x"] = "rbxassetid://106557557978061",
	["copy"] = "rbxassetid://78979572434545",
	["copyleft"] = "rbxassetid://78559055698593",
	["copyright"] = "rbxassetid://129433635747111",
	["corner-down-left"] = "rbxassetid://90473561177832",
	["corner-down-right"] = "rbxassetid://86512767702085",
	["corner-left-down"] = "rbxassetid://139876989150630",
	["corner-left-up"] = "rbxassetid://126228268096099",
	["corner-right-down"] = "rbxassetid://89237035551302",
	["corner-right-up"] = "rbxassetid://112851237026705",
	["corner-up-left"] = "rbxassetid://84669279763024",
	["corner-up-right"] = "rbxassetid://115099889693145",
	["cpu"] = "rbxassetid://77549309870247",
	["creative-commons"] = "rbxassetid://90408210735312",
	["credit-card"] = "rbxassetid://99163352872346",
	["croissant"] = "rbxassetid://130710485559420",
	["crop"] = "rbxassetid://116344601101413",
	["cross"] = "rbxassetid://101833377863588",
	["crosshair"] = "rbxassetid://134242818164054",
	["crown"] = "rbxassetid://127843403295538",
	["cuboid"] = "rbxassetid://75618807946111",
	["cup-soda"] = "rbxassetid://121098640829562",
	["currency"] = "rbxassetid://90551250119972",
	["cylinder"] = "rbxassetid://90569677179169",
	["dam"] = "rbxassetid://76874486231393",
	["database-backup"] = "rbxassetid://103403210984699",
	["database-search"] = "rbxassetid://92017137080138",
	["database-zap"] = "rbxassetid://131199921258418",
	["database"] = "rbxassetid://126791525623846",
	["delete"] = "rbxassetid://126279426372342",
	["dessert"] = "rbxassetid://71508133278830",
	["diameter"] = "rbxassetid://97429051503783",
	["diamond-minus"] = "rbxassetid://128989071438290",
	["diamond-percent"] = "rbxassetid://107717860105959",
	["diamond-plus"] = "rbxassetid://134701163723675",
	["diamond"] = "rbxassetid://105846996304890",
	["dice-1"] = "rbxassetid://112650149591038",
	["dice-2"] = "rbxassetid://112278274566793",
	["dice-3"] = "rbxassetid://118526270626312",
	["dice-4"] = "rbxassetid://113365650364004",
	["dice-5"] = "rbxassetid://72768312430593",
	["dice-6"] = "rbxassetid://85376239182543",
	["dices"] = "rbxassetid://81268120302865",
	["diff"] = "rbxassetid://135052708609715",
	["disc-2"] = "rbxassetid://91419420404185",
	["disc-3"] = "rbxassetid://135470554736048",
	["disc-album"] = "rbxassetid://74693460404344",
	["disc"] = "rbxassetid://101908120120777",
	["divide"] = "rbxassetid://136678191878278",
	["dna-off"] = "rbxassetid://89612426361540",
	["dna"] = "rbxassetid://74007982981741",
	["dock"] = "rbxassetid://121997427160252",
	["dog"] = "rbxassetid://71920105558570",
	["dollar-sign"] = "rbxassetid://127320961224019",
	["donut"] = "rbxassetid://72204922742657",
	["door-closed-locked"] = "rbxassetid://74027613267551",
	["door-closed"] = "rbxassetid://136249099949073",
	["door-open"] = "rbxassetid://91306356501736",
	["dot"] = "rbxassetid://137321056643916",
	["download"] = "rbxassetid://134814648082393",
	["drafting-compass"] = "rbxassetid://99701976182841",
	["drama"] = "rbxassetid://110297795801577",
	["dribbble"] = "rbxassetid://80231809663849",
	["drill"] = "rbxassetid://108644821412796",
	["drone"] = "rbxassetid://117299095794783",
	["droplet-off"] = "rbxassetid://119365002225172",
	["droplet"] = "rbxassetid://100597455015098",
	["droplets"] = "rbxassetid://140111846025180",
	["drum"] = "rbxassetid://136979060344890",
	["drumstick"] = "rbxassetid://104662462521709",
	["dumbbell"] = "rbxassetid://80277236776212",
	["ear-off"] = "rbxassetid://87421916192807",
	["ear"] = "rbxassetid://121894949934209",
	["earth-lock"] = "rbxassetid://88814147073745",
	["earth"] = "rbxassetid://76231597751076",
	["eclipse"] = "rbxassetid://114829622118222",
	["egg-fried"] = "rbxassetid://90622538210545",
	["egg-off"] = "rbxassetid://92288321309285",
	["egg"] = "rbxassetid://117851493400222",
	["ellipsis-vertical"] = "rbxassetid://117978708573781",
	["ellipsis"] = "rbxassetid://140019550645825",
	["equal-approximately"] = "rbxassetid://105382689698323",
	["equal-not"] = "rbxassetid://76864449458032",
	["equal"] = "rbxassetid://123467780715624",
	["eraser"] = "rbxassetid://133957773112410",
	["ethernet-port"] = "rbxassetid://75391715149314",
	["euro"] = "rbxassetid://72229646524456",
	["ev-charger"] = "rbxassetid://97906158859623",
	["expand"] = "rbxassetid://137492887754537",
	["external-link"] = "rbxassetid://129331830773832",
	["eye-closed"] = "rbxassetid://111063268625789",
	["eye-off"] = "rbxassetid://135928786788378",
	["eye"] = "rbxassetid://100033680381365",
	["facebook"] = "rbxassetid://72098528632192",
	["factory"] = "rbxassetid://102170024318039",
	["fan"] = "rbxassetid://78391400440696",
	["fast-forward"] = "rbxassetid://121615540167909",
	["feather"] = "rbxassetid://91872927606406",
	["fence"] = "rbxassetid://123451565578029",
	["ferris-wheel"] = "rbxassetid://79729205796176",
	["figma"] = "rbxassetid://134182122852301",
	["file-archive"] = "rbxassetid://77018106869967",
	["file-axis-3d"] = "rbxassetid://133912328009885",
	["file-badge"] = "rbxassetid://74564895394477",
	["file-box"] = "rbxassetid://119264004071690",
	["file-braces"] = "rbxassetid://95314128621234",
	["file-chart-column-increasing"] = "rbxassetid://134449481172067",
	["file-chart-column"] = "rbxassetid://82048481252560",
	["file-chart-line"] = "rbxassetid://71954360551345",
	["file-chart-pie"] = "rbxassetid://81072193564497",
	["file-check"] = "rbxassetid://82604001452455",
	["file-clock"] = "rbxassetid://102325208830990",
	["file-code"] = "rbxassetid://130978036895504",
	["file-cog"] = "rbxassetid://101385347151368",
	["file-diff"] = "rbxassetid://96147216772241",
	["file-digit"] = "rbxassetid://89220220354580",
	["file-down"] = "rbxassetid://120650154178290",
	["file-headphone"] = "rbxassetid://100533735901986",
	["file-heart"] = "rbxassetid://132214916401696",
	["file-image"] = "rbxassetid://123334057511782",
	["file-input"] = "rbxassetid://124728604166044",
	["file-key"] = "rbxassetid://118790255921100",
	["file-lock"] = "rbxassetid://72170228691242",
	["file-minus"] = "rbxassetid://111014798459222",
	["file-music"] = "rbxassetid://134948051536671",
	["file-output"] = "rbxassetid://92146832572911",
	["file-pen-line"] = "rbxassetid://104622936345006",
	["file-pen"] = "rbxassetid://79556179730240",
	["file-play"] = "rbxassetid://89006821567838",
	["file-plus"] = "rbxassetid://78881710800060",
	["file-scan"] = "rbxassetid://129480105228213",
	["file-search"] = "rbxassetid://97780235974933",
	["file-signal"] = "rbxassetid://122070252538165",
	["file-sliders"] = "rbxassetid://85787771732439",
	["file-spreadsheet"] = "rbxassetid://134501869359270",
	["file-stack"] = "rbxassetid://138929929862605",
	["file-symlink"] = "rbxassetid://91865722036510",
	["file-terminal"] = "rbxassetid://116757454755476",
	["file-text"] = "rbxassetid://90496405707281",
	["file-type"] = "rbxassetid://115272552799361",
	["file-up"] = "rbxassetid://131173039312748",
	["file-user"] = "rbxassetid://99552018455009",
	["file-video-camera"] = "rbxassetid://81719056173960",
	["file-volume"] = "rbxassetid://111264764438958",
	["file-x"] = "rbxassetid://107333775515154",
	["file"] = "rbxassetid://74748492079329",
	["files"] = "rbxassetid://102806336233202",
	["film"] = "rbxassetid://120978945609706",
	["fingerprint"] = "rbxassetid://112173305232811",
	["fire-extinguisher"] = "rbxassetid://111643493006960",
	["fish-off"] = "rbxassetid://89756724887508",
	["fish-symbol"] = "rbxassetid://118475177681618",
	["fish"] = "rbxassetid://124360663785796",
	["fishing-hook"] = "rbxassetid://121038780855899",
	["flag-off"] = "rbxassetid://112944528856799",
	["flag-triangle-left"] = "rbxassetid://88045221285272",
	["flag-triangle-right"] = "rbxassetid://108292480304566",
	["flag"] = "rbxassetid://78183383236196",
	["flame-kindling"] = "rbxassetid://139728976917928",
	["flame"] = "rbxassetid://98218034436456",
	["flashlight-off"] = "rbxassetid://79780362871740",
	["flashlight"] = "rbxassetid://100286985600444",
	["flask-conical-off"] = "rbxassetid://112597970025298",
	["flask-conical"] = "rbxassetid://128406680901165",
	["flask-round"] = "rbxassetid://127508287324940",
	["flip-horizontal-2"] = "rbxassetid://103726993598186",
	["flip-horizontal"] = "rbxassetid://122937530107837",
	["flip-vertical-2"] = "rbxassetid://103836358956328",
	["flip-vertical"] = "rbxassetid://108003917346888",
	["flower-2"] = "rbxassetid://72934574245145",
	["flower"] = "rbxassetid://86129438272762",
	["focus"] = "rbxassetid://87493973153317",
	["fold-horizontal"] = "rbxassetid://92835712442240",
	["fold-vertical"] = "rbxassetid://108873727253656",
	["folder-archive"] = "rbxassetid://97312009460206",
	["folder-check"] = "rbxassetid://128492920904557",
	["folder-clock"] = "rbxassetid://111964836738545",
	["folder-closed"] = "rbxassetid://118286209350843",
	["folder-code"] = "rbxassetid://70624096349370",
	["folder-cog"] = "rbxassetid://85299519462846",
	["folder-dot"] = "rbxassetid://138687772725278",
	["folder-down"] = "rbxassetid://118044108459225",
	["folder-git-2"] = "rbxassetid://101394054141166",
	["folder-git"] = "rbxassetid://121885778095158",
	["folder-heart"] = "rbxassetid://79104747211105",
	["folder-input"] = "rbxassetid://90699920697871",
	["folder-kanban"] = "rbxassetid://78313285104072",
	["folder-key"] = "rbxassetid://85270407596791",
	["folder-lock"] = "rbxassetid://119201572260567",
	["folder-minus"] = "rbxassetid://85648718999010",
	["folder-open-dot"] = "rbxassetid://74741494767354",
	["folder-open"] = "rbxassetid://76018996254888",
	["folder-output"] = "rbxassetid://101532447937612",
	["folder-pen"] = "rbxassetid://112770491173911",
	["folder-plus"] = "rbxassetid://91865663406119",
	["folder-root"] = "rbxassetid://103333751154693",
	["folder-search-2"] = "rbxassetid://71276453442655",
	["folder-search"] = "rbxassetid://110568075123861",
	["folder-symlink"] = "rbxassetid://127485747227189",
	["folder-sync"] = "rbxassetid://91544602659796",
	["folder-tree"] = "rbxassetid://85577554337861",
	["folder-up"] = "rbxassetid://72008269765857",
	["folder-x"] = "rbxassetid://91699618247635",
	["folder"] = "rbxassetid://80846616596607",
	["folders"] = "rbxassetid://110351216219061",
	["footprints"] = "rbxassetid://139192589041315",
	["forklift"] = "rbxassetid://72030930983101",
	["form"] = "rbxassetid://72999643971000",
	["forward"] = "rbxassetid://97545944739523",
	["frame"] = "rbxassetid://109080612832751",
	["framer"] = "rbxassetid://108384807262391",
	["frown"] = "rbxassetid://124407301067982",
	["fuel"] = "rbxassetid://106447647274511",
	["fullscreen"] = "rbxassetid://77793665526178",
	["funnel-plus"] = "rbxassetid://100780233821928",
	["funnel-x"] = "rbxassetid://70984385812555",
	["funnel"] = "rbxassetid://108829540827529",
	["gallery-horizontal-end"] = "rbxassetid://74672430161161",
	["gallery-horizontal"] = "rbxassetid://80004001442122",
	["gallery-thumbnails"] = "rbxassetid://136219289862706",
	["gallery-vertical-end"] = "rbxassetid://106461402088317",
	["gallery-vertical"] = "rbxassetid://119299431466725",
	["gamepad-2"] = "rbxassetid://92483947987410",
	["gamepad-directional"] = "rbxassetid://84342305212226",
	["gamepad"] = "rbxassetid://121607283959010",
	["gauge"] = "rbxassetid://110273524101447",
	["gavel"] = "rbxassetid://78952298198456",
	["gem"] = "rbxassetid://112904952151156",
	["ghost"] = "rbxassetid://113822048130017",
	["gift"] = "rbxassetid://109855212076373",
	["git-branch-minus"] = "rbxassetid://97385010649411",
	["git-branch-plus"] = "rbxassetid://125944221134316",
	["git-branch"] = "rbxassetid://90490195516649",
	["git-commit-horizontal"] = "rbxassetid://133646041800147",
	["git-commit-vertical"] = "rbxassetid://122098032990350",
	["git-compare-arrows"] = "rbxassetid://84874426520216",
	["git-compare"] = "rbxassetid://91945124438792",
	["git-fork"] = "rbxassetid://89954992404765",
	["git-graph"] = "rbxassetid://86166832019304",
	["git-merge-conflict"] = "rbxassetid://85677801675703",
	["git-merge"] = "rbxassetid://131833355158059",
	["git-pull-request-arrow"] = "rbxassetid://94507974577439",
	["git-pull-request-closed"] = "rbxassetid://78070600389091",
	["git-pull-request-create-arrow"] = "rbxassetid://127422677061091",
	["git-pull-request-create"] = "rbxassetid://105929577383926",
	["git-pull-request-draft"] = "rbxassetid://76173459869943",
	["git-pull-request"] = "rbxassetid://138463010991471",
	["github"] = "rbxassetid://120349554354380",
	["gitlab"] = "rbxassetid://114054627192933",
	["glass-water"] = "rbxassetid://115526102400988",
	["glasses"] = "rbxassetid://87936407455373",
	["globe-lock"] = "rbxassetid://134065526704402",
	["globe-off"] = "rbxassetid://77775243585824",
	["globe-x"] = "rbxassetid://109268097029296",
	["globe"] = "rbxassetid://114238209622913",
	["goal"] = "rbxassetid://120517954878160",
	["gpu"] = "rbxassetid://95577823614219",
	["graduation-cap"] = "rbxassetid://93771896340220",
	["grape"] = "rbxassetid://134760640415561",
	["grid-2x2-check"] = "rbxassetid://138468840220821",
	["grid-2x2-plus"] = "rbxassetid://91811610580247",
	["grid-2x2-x"] = "rbxassetid://72407303981388",
	["grid-2x2"] = "rbxassetid://99050491897640",
	["grid-3x2"] = "rbxassetid://95528684210010",
	["grid-3x3"] = "rbxassetid://70419024781206",
	["grip-horizontal"] = "rbxassetid://136255899715930",
	["grip-vertical"] = "rbxassetid://137183678565296",
	["grip"] = "rbxassetid://109058783556768",
	["group"] = "rbxassetid://107643418926671",
	["guitar"] = "rbxassetid://75915531867926",
	["ham"] = "rbxassetid://74465607934635",
	["hamburger"] = "rbxassetid://93086916815495",
	["hammer"] = "rbxassetid://83545120140895",
	["hand-coins"] = "rbxassetid://126990543175462",
	["hand-fist"] = "rbxassetid://83341608917591",
	["hand-grab"] = "rbxassetid://88867162163985",
	["hand-heart"] = "rbxassetid://117507367668412",
	["hand-helping"] = "rbxassetid://89897738419446",
	["hand-metal"] = "rbxassetid://113619498548713",
	["hand-platter"] = "rbxassetid://88594727743168",
	["hand"] = "rbxassetid://130703864968637",
	["handshake"] = "rbxassetid://78442115255814",
	["hard-drive-download"] = "rbxassetid://73913801230614",
	["hard-drive-upload"] = "rbxassetid://85762133615118",
	["hard-drive"] = "rbxassetid://88183305858463",
	["hard-hat"] = "rbxassetid://128050846767382",
	["hash"] = "rbxassetid://82890331678520",
	["haze"] = "rbxassetid://108857561768901",
	["hd"] = "rbxassetid://71682790698278",
	["hdmi-port"] = "rbxassetid://103693661037020",
	["heading-1"] = "rbxassetid://118129315662110",
	["heading-2"] = "rbxassetid://110209069670094",
	["heading-3"] = "rbxassetid://90267885237062",
	["heading-4"] = "rbxassetid://129625620307602",
	["heading-5"] = "rbxassetid://120386663181267",
	["heading-6"] = "rbxassetid://90959079775093",
	["heading"] = "rbxassetid://129254312067735",
	["headphone-off"] = "rbxassetid://85038251615641",
	["headphones"] = "rbxassetid://118833729589183",
	["headset"] = "rbxassetid://129269236787694",
	["heart-crack"] = "rbxassetid://110987638564119",
	["heart-handshake"] = "rbxassetid://111483078692002",
	["heart-minus"] = "rbxassetid://96827380163326",
	["heart-off"] = "rbxassetid://89748414415617",
	["heart-plus"] = "rbxassetid://94877796283249",
	["heart-pulse"] = "rbxassetid://129352925579546",
	["heart"] = "rbxassetid://116559368303288",
	["heater"] = "rbxassetid://140478466880916",
	["helicopter"] = "rbxassetid://111557171735930",
	["hexagon"] = "rbxassetid://127592089339199",
	["highlighter"] = "rbxassetid://77411555641113",
	["history"] = "rbxassetid://123980022019922",
	["hop-off"] = "rbxassetid://103386036934034",
	["hop"] = "rbxassetid://82778923997672",
	["hospital"] = "rbxassetid://105868763850707",
	["hotel"] = "rbxassetid://132283390859718",
	["hourglass"] = "rbxassetid://86160434939203",
	["house-heart"] = "rbxassetid://136054771868597",
	["house-plug"] = "rbxassetid://71438263712075",
	["house-plus"] = "rbxassetid://118495165208309",
	["house-wifi"] = "rbxassetid://126495519725698",
	["house"] = "rbxassetid://98755624629571",
	["home"]  = "rbxassetid://98755624629571",
	["ice-cream-bowl"] = "rbxassetid://124867218454386",
	["ice-cream-cone"] = "rbxassetid://90751397288639",
	["id-card"] = "rbxassetid://75354294622640",
	["image-down"] = "rbxassetid://78972295741235",
	["image-minus"] = "rbxassetid://101066016918565",
	["image-off"] = "rbxassetid://81934811700938",
	["image-play"] = "rbxassetid://129501806784210",
	["image-plus"] = "rbxassetid://70391970623917",
	["image-up"] = "rbxassetid://126610009605241",
	["image"] = "rbxassetid://112751259236831",
	["images"] = "rbxassetid://79350649395557",
	["import"] = "rbxassetid://116545008906029",
	["inbox"] = "rbxassetid://112591360302868",
	["indian-rupee"] = "rbxassetid://113038778381805",
	["infinity"] = "rbxassetid://98083086936965",
	["info"] = "rbxassetid://124560466474914",
	["instagram"] = "rbxassetid://119864798614855",
	["italic"] = "rbxassetid://96220378864282",
	["japanese-yen"] = "rbxassetid://106362863465813",
	["joystick"] = "rbxassetid://99416790224739",
	["kanban"] = "rbxassetid://125934100055431",
	["key-round"] = "rbxassetid://83619031955390",
	["key-square"] = "rbxassetid://94621420033649",
	["key"] = "rbxassetid://96510194465420",
	["keyboard-music"] = "rbxassetid://121058541758636",
	["keyboard-off"] = "rbxassetid://92466375369772",
	["keyboard"] = "rbxassetid://121474456068237",
	["lamp-ceiling"] = "rbxassetid://80032758469141",
	["lamp-desk"] = "rbxassetid://85290686983238",
	["lamp-floor"] = "rbxassetid://104585881375892",
	["lamp-wall-down"] = "rbxassetid://91271394132073",
	["lamp-wall-up"] = "rbxassetid://132141464337445",
	["lamp"] = "rbxassetid://110730830653382",
	["land-plot"] = "rbxassetid://96449039620294",
	["landmark"] = "rbxassetid://76885079756393",
	["languages"] = "rbxassetid://90816903776498",
	["laptop-minimal-check"] = "rbxassetid://114352019833865",
	["laptop-minimal"] = "rbxassetid://136705765566068",
	["laptop"] = "rbxassetid://111387063244975",
	["lasso-select"] = "rbxassetid://105609719912753",
	["lasso"] = "rbxassetid://121072936884007",
	["laugh"] = "rbxassetid://104491311361166",
	["layers-2"] = "rbxassetid://70536710516357",
	["layers-plus"] = "rbxassetid://77587765623057",
	["layers"] = "rbxassetid://81973586053257",
	["layout-dashboard"] = "rbxassetid://139929981863901",
	["layout-grid"] = "rbxassetid://81344910161871",
	["layout-list"] = "rbxassetid://87462136296578",
	["layout-panel-left"] = "rbxassetid://125092469751491",
	["layout-panel-top"] = "rbxassetid://91943941515944",
	["layout-template"] = "rbxassetid://115564446417985",
	["leaf"] = "rbxassetid://119951075637174",
	["leafy-green"] = "rbxassetid://105146290493154",
	["lectern"] = "rbxassetid://106166425183862",
	["library-big"] = "rbxassetid://106794530191412",
	["library"] = "rbxassetid://114334671982047",
	["life-buoy"] = "rbxassetid://81168450671956",
	["lightbulb-off"] = "rbxassetid://83795722296178",
	["lightbulb"] = "rbxassetid://103871245626488",
	["link-2-off"] = "rbxassetid://76885956296867",
	["link-2"] = "rbxassetid://86072351557466",
	["link"] = "rbxassetid://131607023382430",
	["linkedin"] = "rbxassetid://132842789255788",
	["list-check"] = "rbxassetid://72374358471156",
	["list-checks"] = "rbxassetid://99809353635593",
	["list-collapse"] = "rbxassetid://124505247702401",
	["list-end"] = "rbxassetid://77650610048119",
	["list-filter-plus"] = "rbxassetid://96385120752336",
	["list-filter"] = "rbxassetid://103321376129527",
	["list-minus"] = "rbxassetid://138507965142671",
	["list-music"] = "rbxassetid://126380635781840",
	["list-ordered"] = "rbxassetid://83212528113913",
	["list-plus"] = "rbxassetid://112384738137814",
	["list-restart"] = "rbxassetid://91703153577421",
	["list-start"] = "rbxassetid://84828348299727",
	["list-todo"] = "rbxassetid://132980603752108",
	["list-tree"] = "rbxassetid://97685396239010",
	["list-video"] = "rbxassetid://93648525452489",
	["list-x"] = "rbxassetid://113025303988861",
	["list"] = "rbxassetid://113179976918783",
	["loader-circle"] = "rbxassetid://116535712789945",
	["loader-pinwheel"] = "rbxassetid://108513357940900",
	["loader"] = "rbxassetid://78408734580845",
	["locate-fixed"] = "rbxassetid://137367361548433",
	["locate-off"] = "rbxassetid://73729216338137",
	["locate"] = "rbxassetid://84467676590391",
	["lock-keyhole-open"] = "rbxassetid://110863509313073",
	["lock-keyhole"] = "rbxassetid://78672912777756",
	["lock-open"] = "rbxassetid://93597915325122",
	["lock"] = "rbxassetid://134724289526879",
	["log-in"] = "rbxassetid://103768533135201",
	["log-out"] = "rbxassetid://84895399304975",
	["logs"] = "rbxassetid://89772091251787",
	["lollipop"] = "rbxassetid://84681611583044",
	["luggage"] = "rbxassetid://76619236486400",
	["magnet"] = "rbxassetid://135162361226972",
	["mail-check"] = "rbxassetid://86921536259917",
	["mail-minus"] = "rbxassetid://81989813236553",
	["mail-open"] = "rbxassetid://122785416858638",
	["mail-plus"] = "rbxassetid://104886401588341",
	["mail-question-mark"] = "rbxassetid://126540170949819",
	["mail-search"] = "rbxassetid://135616173775287",
	["mail-warning"] = "rbxassetid://81495303676089",
	["mail-x"] = "rbxassetid://74607841705644",
	["mail"] = "rbxassetid://103945161245599",
	["mailbox"] = "rbxassetid://82765503320335",
	["mails"] = "rbxassetid://90673453450080",
	["map-pin-check"] = "rbxassetid://118110914690154",
	["map-pin-off"] = "rbxassetid://82474689391020",
	["map-pin-plus"] = "rbxassetid://91875228967029",
	["map-pin"] = "rbxassetid://84279202219901",
	["map-pinned"] = "rbxassetid://103963788475034",
	["map"] = "rbxassetid://95107167260947",
	["maximize-2"] = "rbxassetid://73085922906397",
	["maximize"] = "rbxassetid://76045941763188",
	["medal"] = "rbxassetid://79016002264450",
	["megaphone-off"] = "rbxassetid://124280774193935",
	["megaphone"] = "rbxassetid://118759541854879",
	["meh"] = "rbxassetid://132197867028557",
	["memory-stick"] = "rbxassetid://93212591343119",
	["menu"] = "rbxassetid://77021539815611",
	["merge"] = "rbxassetid://126201866476775",
	["message-circle-check"] = "rbxassetid://132772297689418",
	["message-circle-more"] = "rbxassetid://92856823884663",
	["message-circle-off"] = "rbxassetid://134955643890328",
	["message-circle-plus"] = "rbxassetid://106562979649273",
	["message-circle-x"] = "rbxassetid://126843387725536",
	["message-circle"] = "rbxassetid://127255077587058",
	["message-square-check"] = "rbxassetid://125789987055668",
	["message-square-more"] = "rbxassetid://120139782405970",
	["message-square-off"] = "rbxassetid://99961019005789",
	["message-square-plus"] = "rbxassetid://76934450256199",
	["message-square-text"] = "rbxassetid://94899503194205",
	["message-square-x"] = "rbxassetid://137285463279462",
	["message-square"] = "rbxassetid://83881670383280",
	["messages-square"] = "rbxassetid://97532166733358",
	["metronome"] = "rbxassetid://101991829345965",
	["mic-off"] = "rbxassetid://82123034444822",
	["mic-vocal"] = "rbxassetid://99082286164362",
	["mic"] = "rbxassetid://89640799126523",
	["microchip"] = "rbxassetid://73937907669903",
	["microscope"] = "rbxassetid://116875530102782",
	["microwave"] = "rbxassetid://108411735353008",
	["milestone"] = "rbxassetid://101618292325920",
	["milk-off"] = "rbxassetid://72388480962742",
	["milk"] = "rbxassetid://96221903896918",
	["minimize-2"] = "rbxassetid://116269596042539",
	["minimize"] = "rbxassetid://121304296213645",
	["minus"] = "rbxassetid://118026365011536",
	["monitor-check"] = "rbxassetid://86651948439229",
	["monitor-cloud"] = "rbxassetid://85931096038318",
	["monitor-dot"] = "rbxassetid://130394010063680",
	["monitor-off"] = "rbxassetid://74395526657953",
	["monitor-play"] = "rbxassetid://133018824306217",
	["monitor-smartphone"] = "rbxassetid://84335680433378",
	["monitor-speaker"] = "rbxassetid://81744810060380",
	["monitor-x"] = "rbxassetid://126265210441423",
	["monitor"] = "rbxassetid://72664649203050",
	["moon-star"] = "rbxassetid://82782200506348",
	["moon"] = "rbxassetid://83380517901735",
	["motorbike"] = "rbxassetid://94580787368233",
	["mountain-snow"] = "rbxassetid://105315495740588",
	["mountain"] = "rbxassetid://73269957566415",
	["mouse-off"] = "rbxassetid://75267871697595",
	["mouse-pointer-click"] = "rbxassetid://107150227368485",
	["mouse-pointer"] = "rbxassetid://72322454962935",
	["mouse"] = "rbxassetid://73096068864710",
	["move-3d"] = "rbxassetid://103365982054003",
	["move-diagonal-2"] = "rbxassetid://117298577948096",
	["move-diagonal"] = "rbxassetid://101433481954184",
	["move-down"] = "rbxassetid://70510115135583",
	["move-horizontal"] = "rbxassetid://88513523439149",
	["move-left"] = "rbxassetid://137614740247980",
	["move-right"] = "rbxassetid://132455779472989",
	["move-up"] = "rbxassetid://84505444262658",
	["move-vertical"] = "rbxassetid://86234730730899",
	["move"] = "rbxassetid://116138709011735",
	["music-2"] = "rbxassetid://134397426600888",
	["music-3"] = "rbxassetid://94466120066498",
	["music-4"] = "rbxassetid://132459323665838",
	["music"] = "rbxassetid://113343203848535",
	["navigation-2"] = "rbxassetid://81889066747907",
	["navigation-off"] = "rbxassetid://87003270290777",
	["navigation"] = "rbxassetid://79308213542922",
	["network"] = "rbxassetid://127410729922644",
	["newspaper"] = "rbxassetid://123479530460544",
	["nfc"] = "rbxassetid://76822396542242",
	["notebook-pen"] = "rbxassetid://140380614761023",
	["notebook-tabs"] = "rbxassetid://127371085570083",
	["notebook-text"] = "rbxassetid://93061585217270",
	["notebook"] = "rbxassetid://136132108664987",
	["notepad-text"] = "rbxassetid://93404682958966",
	["nut-off"] = "rbxassetid://78795397311573",
	["nut"] = "rbxassetid://127146410705656",
	["octagon-alert"] = "rbxassetid://140438367956051",
	["octagon-minus"] = "rbxassetid://74720436795421",
	["octagon-pause"] = "rbxassetid://103161463909039",
	["octagon-x"] = "rbxassetid://90498161006311",
	["octagon"] = "rbxassetid://120803515514852",
	["omega"] = "rbxassetid://70414080018786",
	["option"] = "rbxassetid://100776883894054",
	["orbit"] = "rbxassetid://108926136860562",
	["origami"] = "rbxassetid://136020626667101",
	["package-2"] = "rbxassetid://70394974762575",
	["package-check"] = "rbxassetid://102374216055130",
	["package-minus"] = "rbxassetid://114492858789692",
	["package-open"] = "rbxassetid://132890233237818",
	["package-plus"] = "rbxassetid://129261988138366",
	["package-search"] = "rbxassetid://95465120894145",
	["package-x"] = "rbxassetid://70818501607442",
	["package"] = "rbxassetid://97261141732706",
	["paint-bucket"] = "rbxassetid://124275586663284",
	["paint-roller"] = "rbxassetid://115248074358348",
	["paintbrush-vertical"] = "rbxassetid://105151296591292",
	["paintbrush"] = "rbxassetid://125572663700289",
	["palette"] = "rbxassetid://86350350950064",
	["panel-bottom-close"] = "rbxassetid://74287004071159",
	["panel-bottom-open"] = "rbxassetid://107768659586540",
	["panel-bottom"] = "rbxassetid://132127145048511",
	["panel-left-close"] = "rbxassetid://126579818823552",
	["panel-left-open"] = "rbxassetid://111075816195767",
	["panel-left"] = "rbxassetid://97419752870313",
	["panel-right-close"] = "rbxassetid://139528655524132",
	["panel-right-open"] = "rbxassetid://118114419142794",
	["panel-right"] = "rbxassetid://116365035443156",
	["panel-top-close"] = "rbxassetid://83578325777808",
	["panel-top-open"] = "rbxassetid://137959875507454",
	["panel-top"] = "rbxassetid://75838479462875",
	["paperclip"] = "rbxassetid://92088291163453",
	["parentheses"] = "rbxassetid://78950955173096",
	["party-popper"] = "rbxassetid://111626795712193",
	["pause"] = "rbxassetid://74873705394436",
	["paw-print"] = "rbxassetid://112218825427601",
	["pen-line"] = "rbxassetid://109108135755303",
	["pen-off"] = "rbxassetid://84807123119438",
	["pen-tool"] = "rbxassetid://106145404953445",
	["pen"] = "rbxassetid://72037878096321",
	["pencil-line"] = "rbxassetid://88392917053533",
	["pencil-off"] = "rbxassetid://103330927652832",
	["pencil-ruler"] = "rbxassetid://110120288284597",
	["pencil"] = "rbxassetid://137986121120732",
	["pentagon"] = "rbxassetid://79184802179890",
	["percent"] = "rbxassetid://130155041032013",
	["person-standing"] = "rbxassetid://125020872044147",
	["phone-call"] = "rbxassetid://70555587592860",
	["phone-forwarded"] = "rbxassetid://113269614319737",
	["phone-incoming"] = "rbxassetid://82863576359288",
	["phone-missed"] = "rbxassetid://130156165198376",
	["phone-off"] = "rbxassetid://133318623553383",
	["phone-outgoing"] = "rbxassetid://104576478735825",
	["phone"] = "rbxassetid://128804946640049",
	["pi"] = "rbxassetid://74936036243146",
	["piano"] = "rbxassetid://85008880789520",
	["pickaxe"] = "rbxassetid://105888023317688",
	["picture-in-picture-2"] = "rbxassetid://112803319544468",
	["picture-in-picture"] = "rbxassetid://80579597835123",
	["piggy-bank"] = "rbxassetid://79498575790721",
	["pilcrow"] = "rbxassetid://139512780392871",
	["pill"] = "rbxassetid://73280534813448",
	["pin-off"] = "rbxassetid://127696372451750",
	["pin"] = "rbxassetid://120978111007514",
	["pipette"] = "rbxassetid://133167932934404",
	["pizza"] = "rbxassetid://126964453193501",
	["plane-landing"] = "rbxassetid://122555692211889",
	["plane-takeoff"] = "rbxassetid://117179478829575",
	["plane"] = "rbxassetid://126985561580989",
	["play"] = "rbxassetid://135609604299893",
	["plug-2"] = "rbxassetid://97912386476366",
	["plug-zap"] = "rbxassetid://74506269884055",
	["plug"] = "rbxassetid://99782373064495",
	["plus"] = "rbxassetid://111774323017047",
	["pocket-knife"] = "rbxassetid://134075428063965",
	["pocket"] = "rbxassetid://136686762542964",
	["podcast"] = "rbxassetid://109577075549215",
	["pointer"] = "rbxassetid://92615117311099",
	["popcorn"] = "rbxassetid://139446511232750",
	["pound-sterling"] = "rbxassetid://127482649469130",
	["power-off"] = "rbxassetid://118768311012214",
	["power"] = "rbxassetid://96479131758775",
	["presentation"] = "rbxassetid://106134583757890",
	["printer"] = "rbxassetid://76080649734247",
	["projector"] = "rbxassetid://103281856385283",
	["puzzle"] = "rbxassetid://136837798892463",
	["pyramid"] = "rbxassetid://107811442374127",
	["qr-code"] = "rbxassetid://105329945723350",
	["quote"] = "rbxassetid://103271711590001",
	["rabbit"] = "rbxassetid://98580518804206",
	["radar"] = "rbxassetid://138528222906635",
	["radiation"] = "rbxassetid://104499586848433",
	["radical"] = "rbxassetid://132758286926047",
	["radio-off"] = "rbxassetid://80359258046586",
	["radio-receiver"] = "rbxassetid://129598303378835",
	["radio-tower"] = "rbxassetid://93958663130054",
	["radio"] = "rbxassetid://85611589536956",
	["rainbow"] = "rbxassetid://132488862841895",
	["rat"] = "rbxassetid://127400975953159",
	["receipt-text"] = "rbxassetid://138483536013737",
	["receipt"] = "rbxassetid://77877895901792",
	["rectangle-ellipsis"] = "rbxassetid://112919953980965",
	["rectangle-horizontal"] = "rbxassetid://90224199814966",
	["rectangle-vertical"] = "rbxassetid://117277050590967",
	["recycle"] = "rbxassetid://140417023381961",
	["redo-2"] = "rbxassetid://70451039017914",
	["redo"] = "rbxassetid://116150342119054",
	["refresh-ccw"] = "rbxassetid://117913330389477",
	["refresh-cw"] = "rbxassetid://138133190015277",
	["refrigerator"] = "rbxassetid://102614042652753",
	["regex"] = "rbxassetid://100727200791841",
	["remove-formatting"] = "rbxassetid://112833162022628",
	["repeat-1"] = "rbxassetid://130144534857095",
	["repeat-2"] = "rbxassetid://85927537182704",
	["repeat"] = "rbxassetid://121886242955173",
	["replace-all"] = "rbxassetid://127862728198635",
	["replace"] = "rbxassetid://128404082279430",
	["reply-all"] = "rbxassetid://71723137343562",
	["reply"] = "rbxassetid://109788633497028",
	["rewind"] = "rbxassetid://95205297521988",
	["ribbon"] = "rbxassetid://94265331526851",
	["road"] = "rbxassetid://120251329173530",
	["rocket"] = "rbxassetid://87412317685854",
	["rocking-chair"] = "rbxassetid://110420269495360",
	["rose"] = "rbxassetid://126336840238769",
	["rotate-ccw"] = "rbxassetid://110116685948665",
	["rotate-cw"] = "rbxassetid://84183336178654",
	["route"] = "rbxassetid://89968303228953",
	["router"] = "rbxassetid://102130331994471",
	["rows-2"] = "rbxassetid://112556185960101",
	["rows-3"] = "rbxassetid://117215586961375",
	["rss"] = "rbxassetid://131789058984793",
	["ruler"] = "rbxassetid://81432445547423",
	["sailboat"] = "rbxassetid://87110567187540",
	["salad"] = "rbxassetid://128864507821603",
	["sandwich"] = "rbxassetid://104573187458917",
	["satellite-dish"] = "rbxassetid://136742443888305",
	["satellite"] = "rbxassetid://134967053164645",
	["save-all"] = "rbxassetid://116946975799440",
	["save-off"] = "rbxassetid://87085435778560",
	["save"] = "rbxassetid://126116963775616",
	["scale"] = "rbxassetid://108203682317477",
	["scan-barcode"] = "rbxassetid://96889457154761",
	["scan-eye"] = "rbxassetid://99244790601968",
	["scan-face"] = "rbxassetid://109959345069668",
	["scan-heart"] = "rbxassetid://106280819776142",
	["scan"] = "rbxassetid://123104789658180",
	["school"] = "rbxassetid://76351530290068",
	["scissors"] = "rbxassetid://118665510911274",
	["screen-share-off"] = "rbxassetid://107677572669805",
	["screen-share"] = "rbxassetid://85137895705653",
	["scroll-text"] = "rbxassetid://97321022666868",
	["scroll"] = "rbxassetid://74072101474951",
	["search"] = "rbxassetid://121018724060431",
	["send-horizontal"] = "rbxassetid://111734392411664",
	["send-to-back"] = "rbxassetid://75340312862253",
	["send"] = "rbxassetid://127751956873796",
	["server-crash"] = "rbxassetid://132810618000212",
	["server-off"] = "rbxassetid://114048751507723",
	["server"] = "rbxassetid://92188766517878",
	["settings-2"] = "rbxassetid://135684703553372",
	["settings"] = "rbxassetid://80758916183665",
	["shapes"] = "rbxassetid://129989433311409",
	["share-2"] = "rbxassetid://71210767962065",
	["share"] = "rbxassetid://87340985053299",
	["sheet"] = "rbxassetid://134902122480171",
	["shell"] = "rbxassetid://140212943563599",
	["shield-alert"] = "rbxassetid://114995877719925",
	["shield-ban"] = "rbxassetid://108765041044649",
	["shield-check"] = "rbxassetid://87354736164608",
	["shield-cog"] = "rbxassetid://129235695057857",
	["shield-minus"] = "rbxassetid://89965059528921",
	["shield-off"] = "rbxassetid://133426959132690",
	["shield-plus"] = "rbxassetid://100664857995498",
	["shield-x"] = "rbxassetid://73370117343811",
	["shield"] = "rbxassetid://110987169760162",
	["ship"] = "rbxassetid://83995100553930",
	["shirt"] = "rbxassetid://106579555405966",
	["shopping-bag"] = "rbxassetid://71885477293226",
	["shopping-basket"] = "rbxassetid://138646411956433",
	["shopping-cart"] = "rbxassetid://128420521375441",
	["shovel"] = "rbxassetid://102465000512056",
	["shower-head"] = "rbxassetid://75884944024117",
	["shuffle"] = "rbxassetid://132382786975101",
	["sigma"] = "rbxassetid://126884244870899",
	["signal-high"] = "rbxassetid://130436670012270",
	["signal-low"] = "rbxassetid://73674683500458",
	["signal-medium"] = "rbxassetid://125003021367019",
	["signal-zero"] = "rbxassetid://130045332414754",
	["signal"] = "rbxassetid://78424889355261",
	["siren"] = "rbxassetid://134210267818039",
	["skip-back"] = "rbxassetid://70466132711334",
	["skip-forward"] = "rbxassetid://124844823753990",
	["skull"] = "rbxassetid://137726256442333",
	["slack"] = "rbxassetid://96089719516736",
	["slash"] = "rbxassetid://117792185664263",
	["sliders-horizontal"] = "rbxassetid://85538382643347",
	["sliders-vertical"] = "rbxassetid://101190569086853",
	["smartphone-charging"] = "rbxassetid://102837532613995",
	["smartphone"] = "rbxassetid://96623008834511",
	["smile-plus"] = "rbxassetid://131981881472144",
	["smile"] = "rbxassetid://105880397565283",
	["snail"] = "rbxassetid://70904536548363",
	["snowflake"] = "rbxassetid://101235206534566",
	["sofa"] = "rbxassetid://114427687218324",
	["soup"] = "rbxassetid://115092551871618",
	["spade"] = "rbxassetid://131444449466462",
	["sparkle"] = "rbxassetid://111044800239623",
	["sparkles"] = "rbxassetid://138635884129147",
	["speaker"] = "rbxassetid://96227183003618",
	["split"] = "rbxassetid://105112438805988",
	["spray-can"] = "rbxassetid://128372039366326",
	["sprout"] = "rbxassetid://100091687832508",
	["square-activity"] = "rbxassetid://89496630185293",
	["square-arrow-down"] = "rbxassetid://135962519626588",
	["square-arrow-left"] = "rbxassetid://111671474549238",
	["square-arrow-right"] = "rbxassetid://113920471701361",
	["square-arrow-up"] = "rbxassetid://106998604646718",
	["square-asterisk"] = "rbxassetid://89186832353625",
	["square-check-big"] = "rbxassetid://115320390907184",
	["square-check"] = "rbxassetid://134682053539509",
	["square-chevron-down"] = "rbxassetid://91032307924592",
	["square-chevron-left"] = "rbxassetid://73143404829510",
	["square-chevron-right"] = "rbxassetid://90612077729930",
	["square-chevron-up"] = "rbxassetid://85565910197337",
	["square-code"] = "rbxassetid://81604576616881",
	["square-dashed"] = "rbxassetid://136905537847606",
	["square-divide"] = "rbxassetid://99894657101970",
	["square-dot"] = "rbxassetid://116613421354866",
	["square-equal"] = "rbxassetid://110283363706707",
	["square-function"] = "rbxassetid://86075219551088",
	["square-kanban"] = "rbxassetid://114537101260131",
	["square-library"] = "rbxassetid://73810931222081",
	["square-m"] = "rbxassetid://117662700410577",
	["square-menu"] = "rbxassetid://104067089444415",
	["square-minus"] = "rbxassetid://116764432015770",
	["square-parking"] = "rbxassetid://133116656122387",
	["square-pause"] = "rbxassetid://86608552787615",
	["square-pen"] = "rbxassetid://120239476110475",
	["square-percent"] = "rbxassetid://87111930314567",
	["square-pi"] = "rbxassetid://75383328781618",
	["square-play"] = "rbxassetid://108186325238481",
	["square-plus"] = "rbxassetid://114713264461873",
	["square-power"] = "rbxassetid://129240437805187",
	["square-radical"] = "rbxassetid://132645931868292",
	["square-scissors"] = "rbxassetid://110601255612411",
	["square-sigma"] = "rbxassetid://113231244246816",
	["square-slash"] = "rbxassetid://105477013908757",
	["square-split-horizontal"] = "rbxassetid://76095370148660",
	["square-split-vertical"] = "rbxassetid://88589192032058",
	["square-square"] = "rbxassetid://136555087357875",
	["square-stack"] = "rbxassetid://100463396619394",
	["square-star"] = "rbxassetid://94506958703720",
	["square-stop"] = "rbxassetid://80018708472943",
	["square-terminal"] = "rbxassetid://83969264476798",
	["square-user-round"] = "rbxassetid://86484997229302",
	["square-user"] = "rbxassetid://70771214183445",
	["square-x"] = "rbxassetid://125136183850190",
	["square"] = "rbxassetid://86304921356806",
	["squircle"] = "rbxassetid://82426632573807",
	["squirrel"] = "rbxassetid://112864252085343",
	["stamp"] = "rbxassetid://92370779813368",
	["star-half"] = "rbxassetid://117449275562979",
	["star-off"] = "rbxassetid://75742832732503",
	["star"] = "rbxassetid://136141469398409",
	["step-back"] = "rbxassetid://108672750005121",
	["step-forward"] = "rbxassetid://126131872136145",
	["stethoscope"] = "rbxassetid://122331031702148",
	["sticker"] = "rbxassetid://79938203791608",
	["sticky-note"] = "rbxassetid://111894074643919",
	["store"] = "rbxassetid://90338129673705",
	["strikethrough"] = "rbxassetid://103417324549613",
	["subscript"] = "rbxassetid://74553514785183",
	["sun-dim"] = "rbxassetid://129141645592715",
	["sun-medium"] = "rbxassetid://130278807964710",
	["sun-moon"] = "rbxassetid://75752898854559",
	["sun-snow"] = "rbxassetid://112791898014579",
	["sun"] = "rbxassetid://110150589884127",
	["sunrise"] = "rbxassetid://134705665494098",
	["sunset"] = "rbxassetid://75904872203588",
	["superscript"] = "rbxassetid://96887696590118",
	["swatch-book"] = "rbxassetid://126786244872453",
	["swiss-franc"] = "rbxassetid://113497920041625",
	["switch-camera"] = "rbxassetid://76841154349737",
	["sword"] = "rbxassetid://124448418211665",
	["swords"] = "rbxassetid://81872698913435",
	["syringe"] = "rbxassetid://123891270479254",
	["table-2"] = "rbxassetid://95751552281545",
	["table-of-contents"] = "rbxassetid://135044763275414",
	["table-properties"] = "rbxassetid://125062886015372",
	["table"] = "rbxassetid://109109148250737",
	["tablet-smartphone"] = "rbxassetid://133680859813404",
	["tablet"] = "rbxassetid://128403991264386",
	["tag"] = "rbxassetid://129104970103940",
	["tags"] = "rbxassetid://107179263080798",
	["target"] = "rbxassetid://87563802520297",
	["telescope"] = "rbxassetid://91755049143647",
	["tent-tree"] = "rbxassetid://76698322463977",
	["tent"] = "rbxassetid://109779587826330",
	["terminal"] = "rbxassetid://106783148545356",
	["test-tube"] = "rbxassetid://98801015650164",
	["thermometer-snowflake"] = "rbxassetid://121876188028425",
	["thermometer-sun"] = "rbxassetid://106693240074310",
	["thermometer"] = "rbxassetid://106546011492311",
	["thumbs-down"] = "rbxassetid://87794009914015",
	["thumbs-up"] = "rbxassetid://111137070767020",
	["ticket-check"] = "rbxassetid://105428777212507",
	["ticket-percent"] = "rbxassetid://80834774406405",
	["ticket-plus"] = "rbxassetid://110086734392189",
	["ticket"] = "rbxassetid://126527071492145",
	["timer-off"] = "rbxassetid://110916370767271",
	["timer-reset"] = "rbxassetid://110052125369932",
	["timer"] = "rbxassetid://85473888890506",
	["toggle-left"] = "rbxassetid://85887872573050",
	["toggle-right"] = "rbxassetid://90411952142550",
	["toilet"] = "rbxassetid://80930782432931",
	["toolbox"] = "rbxassetid://85341033903792",
	["tornado"] = "rbxassetid://88358291515768",
	["touchpad-off"] = "rbxassetid://78784008075456",
	["touchpad"] = "rbxassetid://74882354908014",
	["tower-control"] = "rbxassetid://95937619060532",
	["toy-brick"] = "rbxassetid://86293483924633",
	["tractor"] = "rbxassetid://103376704722051",
	["traffic-cone"] = "rbxassetid://74110220470369",
	["train-front"] = "rbxassetid://125237934215370",
	["train-track"] = "rbxassetid://77451032453723",
	["trash-2"] = "rbxassetid://109843431391323",
	["trash"] = "rbxassetid://106723740584310",
	["tree-deciduous"] = "rbxassetid://123124389219004",
	["tree-palm"] = "rbxassetid://103846705893963",
	["tree-pine"] = "rbxassetid://124662547202594",
	["trees"] = "rbxassetid://121203841375919",
	["trello"] = "rbxassetid://130987241149527",
	["trending-down"] = "rbxassetid://139309232226438",
	["trending-up-down"] = "rbxassetid://85083293981691",
	["trending-up"] = "rbxassetid://81819858538839",
	["triangle-alert"] = "rbxassetid://125920361880643",
	["triangle"] = "rbxassetid://126330486745540",
	["trophy"] = "rbxassetid://131545003268773",
	["truck-electric"] = "rbxassetid://111873446387359",
	["truck"] = "rbxassetid://86662707764771",
	["turkish-lira"] = "rbxassetid://114589876174070",
	["turntable"] = "rbxassetid://129870346487856",
	["turtle"] = "rbxassetid://118295081560334",
	["tv-minimal-play"] = "rbxassetid://99201833426972",
	["tv-minimal"] = "rbxassetid://100382201729427",
	["tv"] = "rbxassetid://135687724791776",
	["twitch"] = "rbxassetid://71383308134888",
	["twitter"] = "rbxassetid://88791703276842",
	["type"] = "rbxassetid://133543553793564",
	["umbrella-off"] = "rbxassetid://72395143739955",
	["umbrella"] = "rbxassetid://127502210274589",
	["underline"] = "rbxassetid://123709229216544",
	["undo-2"] = "rbxassetid://113885292059932",
	["undo"] = "rbxassetid://111258459077271",
	["unfold-horizontal"] = "rbxassetid://117128358526398",
	["unfold-vertical"] = "rbxassetid://116593025265499",
	["ungroup"] = "rbxassetid://106674800451003",
	["university"] = "rbxassetid://84652528263642",
	["unlink-2"] = "rbxassetid://128131898892572",
	["unlink"] = "rbxassetid://139835795227752",
	["unplug"] = "rbxassetid://90171381619874",
	["upload"] = "rbxassetid://138212042425501",
	["usb"] = "rbxassetid://117230058949613",
	["user-check"] = "rbxassetid://81775205032725",
	["user-cog"] = "rbxassetid://92795491530865",
	["user-minus"] = "rbxassetid://126976941957511",
	["user-pen"] = "rbxassetid://87445472574836",
	["user-plus"] = "rbxassetid://118514469915884",
	["user-round-check"] = "rbxassetid://118794737621941",
	["user-round-cog"] = "rbxassetid://78239503290053",
	["user-round-minus"] = "rbxassetid://98944176636447",
	["user-round-pen"] = "rbxassetid://108155244324878",
	["user-round-plus"] = "rbxassetid://113301899567470",
	["user-round-search"] = "rbxassetid://71565774381870",
	["user-round-x"] = "rbxassetid://122367980560930",
	["user-round"] = "rbxassetid://136485052187963",
	["user-search"] = "rbxassetid://101335649828115",
	["user-x"] = "rbxassetid://139748155894754",
	["user"] = "rbxassetid://81589895647169",
	["users-round"] = "rbxassetid://103005444008339",
	["users"] = "rbxassetid://115398113982385",
	["utensils-crossed"] = "rbxassetid://109520762270383",
	["utensils"] = "rbxassetid://139952569804235",
	["van"] = "rbxassetid://122066377022942",
	["variable"] = "rbxassetid://104743088438151",
	["vault"] = "rbxassetid://108049164599845",
	["vegan"] = "rbxassetid://119489190688082",
	["venus"] = "rbxassetid://82891342220859",
	["vibrate"] = "rbxassetid://108330910738733",
	["video-off"] = "rbxassetid://132239189859305",
	["video"] = "rbxassetid://107587444636945",
	["view"] = "rbxassetid://118717253976805",
	["voicemail"] = "rbxassetid://134313454010227",
	["volleyball"] = "rbxassetid://83889351124153",
	["volume-1"] = "rbxassetid://98514588731639",
	["volume-2"] = "rbxassetid://89344380902620",
	["volume-off"] = "rbxassetid://103047478058767",
	["volume-x"] = "rbxassetid://139252359189540",
	["volume"] = "rbxassetid://103236289817396",
	["vote"] = "rbxassetid://89409762851246",
	["wallet-cards"] = "rbxassetid://129728715308337",
	["wallet-minimal"] = "rbxassetid://137800448816116",
	["wallet"] = "rbxassetid://132331555762628",
	["wand-sparkles"] = "rbxassetid://82546429942392",
	["wand"] = "rbxassetid://114580617777835",
	["warehouse"] = "rbxassetid://78388887451080",
	["washing-machine"] = "rbxassetid://104194127573858",
	["watch"] = "rbxassetid://130544621618405",
	["waves"] = "rbxassetid://96340135183647",
	["waypoints"] = "rbxassetid://102450133666017",
	["webcam"] = "rbxassetid://104148487911129",
	["webhook"] = "rbxassetid://112812457747322",
	["weight"] = "rbxassetid://103860559844854",
	["wheat-off"] = "rbxassetid://133294844612307",
	["wheat"] = "rbxassetid://85261952080359",
	["whole-word"] = "rbxassetid://90111083954485",
	["wifi-cog"] = "rbxassetid://110500263326209",
	["wifi-high"] = "rbxassetid://81954601342139",
	["wifi-low"] = "rbxassetid://138217335635913",
	["wifi-off"] = "rbxassetid://74113634330106",
	["wifi-zero"] = "rbxassetid://124286465246123",
	["wifi"] = "rbxassetid://104669375183960",
	["wind"] = "rbxassetid://114551690399915",
	["wine-off"] = "rbxassetid://108294164302317",
	["wine"] = "rbxassetid://115743721332829",
	["workflow"] = "rbxassetid://99186544029189",
	["wrench"] = "rbxassetid://112148279212860",
	["x"] = "rbxassetid://110786993356448",
	["youtube"] = "rbxassetid://123663668456341",
	["zap-off"] = "rbxassetid://81385483183652",
	["zap"] = "rbxassetid://130551565616516",
	["zodiac-aquarius"] = "rbxassetid://74560047770362",
	["zodiac-aries"] = "rbxassetid://73255859670234",
	["zodiac-cancer"] = "rbxassetid://131985162532947",
	["zodiac-capricorn"] = "rbxassetid://97859568140652",
	["zodiac-gemini"] = "rbxassetid://80997588122992",
	["zodiac-leo"] = "rbxassetid://75509406718106",
	["zodiac-libra"] = "rbxassetid://113222735060218",
	["zodiac-ophiuchus"] = "rbxassetid://129180108892480",
	["zodiac-pisces"] = "rbxassetid://95845819440327",
	["zodiac-sagittarius"] = "rbxassetid://82651026742181",
	["zodiac-scorpio"] = "rbxassetid://113640924054631",
	["zodiac-taurus"] = "rbxassetid://123053219704400",
	["zodiac-virgo"] = "rbxassetid://99462994613661",
	["zoom-in"] = "rbxassetid://127956924984803",
	["zoom-out"] = "rbxassetid://108334162607319",
}

local ThemesDict = {
	["Default"] = {
		WindowBg       = Color3.fromRGB(8, 8, 8),
		TitleBarBg     = Color3.fromRGB(12, 12, 12),
		SidebarBg      = Color3.fromRGB(0, 0, 0),
		ElementBg      = Color3.fromRGB(18, 18, 18),
		PrimaryText    = Color3.fromRGB(240, 240, 240),
		SecondaryText  = Color3.fromRGB(165, 165, 165),
		AccentColor    = Color3.fromRGB(0, 170, 255),
		TabActive      = Color3.fromRGB(35, 35, 35),
		TabInactive    = Color3.fromRGB(18, 18, 18),
		SearchBarBg    = Color3.fromRGB(22, 22, 22),
	},
	["Darker"] = {
		WindowBg       = Color3.fromRGB(3, 3, 3),
		TitleBarBg     = Color3.fromRGB(5, 5, 5),
		SidebarBg      = Color3.fromRGB(3, 3, 3),
		ElementBg      = Color3.fromRGB(10, 10, 10),
		PrimaryText    = Color3.fromRGB(210, 210, 210),
		SecondaryText  = Color3.fromRGB(130, 130, 130),
		AccentColor    = Color3.fromRGB(0, 140, 220),
		TabActive      = Color3.fromRGB(18, 18, 18),
		TabInactive    = Color3.fromRGB(8, 8, 8),
		SearchBarBg    = Color3.fromRGB(12, 12, 12),
	},
	["Fire"] = {
		WindowBg       = Color3.fromRGB(18, 5, 2),
		TitleBarBg     = Color3.fromRGB(30, 8, 2),
		SidebarBg      = Color3.fromRGB(20, 5, 2),
		ElementBg      = Color3.fromRGB(35, 12, 4),
		PrimaryText    = Color3.fromRGB(255, 230, 210),
		SecondaryText  = Color3.fromRGB(210, 140, 100),
		AccentColor    = Color3.fromRGB(255, 90, 20),
		TabActive      = Color3.fromRGB(60, 18, 5),
		TabInactive    = Color3.fromRGB(35, 10, 3),
		SearchBarBg    = Color3.fromRGB(40, 12, 4),
	},
	["Blossom"] = {
		WindowBg       = Color3.fromRGB(20, 8, 14),
		TitleBarBg     = Color3.fromRGB(28, 10, 20),
		SidebarBg      = Color3.fromRGB(22, 8, 15),
		ElementBg      = Color3.fromRGB(35, 14, 25),
		PrimaryText    = Color3.fromRGB(255, 225, 240),
		SecondaryText  = Color3.fromRGB(210, 160, 185),
		AccentColor    = Color3.fromRGB(240, 90, 160),
		TabActive      = Color3.fromRGB(55, 20, 38),
		TabInactive    = Color3.fromRGB(32, 12, 22),
		SearchBarBg    = Color3.fromRGB(38, 14, 26),
	},
	["Snow"] = {
		WindowBg       = Color3.fromRGB(185, 198, 215),
		TitleBarBg     = Color3.fromRGB(165, 180, 200),
		SidebarBg      = Color3.fromRGB(170, 185, 205),
		ElementBg      = Color3.fromRGB(150, 168, 192),
		PrimaryText    = Color3.fromRGB(12, 22, 45),
		SecondaryText  = Color3.fromRGB(35, 55, 90),
		AccentColor    = Color3.fromRGB(30, 90, 200),
		TabActive      = Color3.fromRGB(125, 145, 172),
		TabInactive    = Color3.fromRGB(150, 168, 192),
		SearchBarBg    = Color3.fromRGB(138, 158, 182),
	},
	["Spring"] = {
		WindowBg       = Color3.fromRGB(12, 22, 10),
		TitleBarBg     = Color3.fromRGB(16, 30, 13),
		SidebarBg      = Color3.fromRGB(12, 22, 10),
		ElementBg      = Color3.fromRGB(20, 36, 16),
		PrimaryText    = Color3.fromRGB(220, 255, 215),
		SecondaryText  = Color3.fromRGB(140, 210, 130),
		AccentColor    = Color3.fromRGB(60, 210, 80),
		TabActive      = Color3.fromRGB(30, 55, 24),
		TabInactive    = Color3.fromRGB(18, 32, 14),
		SearchBarBg    = Color3.fromRGB(22, 38, 18),
	},
	["Cloudy"] = {
		WindowBg       = Color3.fromRGB(55, 62, 75),
		TitleBarBg     = Color3.fromRGB(65, 73, 88),
		SidebarBg      = Color3.fromRGB(58, 65, 78),
		ElementBg      = Color3.fromRGB(72, 80, 96),
		PrimaryText    = Color3.fromRGB(230, 235, 245),
		SecondaryText  = Color3.fromRGB(170, 178, 198),
		AccentColor    = Color3.fromRGB(130, 170, 230),
		TabActive      = Color3.fromRGB(90, 100, 120),
		TabInactive    = Color3.fromRGB(68, 76, 92),
		SearchBarBg    = Color3.fromRGB(75, 84, 100),
	},
}

local function RunSearch(query, ElementRegistry)
	local q = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
	for _, entry in ipairs(ElementRegistry) do
		if q == "" then
			entry.Frame.Visible = true
		else
			entry.Frame.Visible = (entry.Label:lower():find(q, 1, true) ~= nil)
		end
	end
end

function LuaLandLibrary:CreateWindow(WindowConfig)
	local TitleString     = WindowConfig.Title     or "Lua Land Ui Library"
	local SubtitleString  = WindowConfig.Subtitle  or "Lua Land Dev"
	local TitleIconString = WindowConfig.TitleIcon or "book-open-text"
	local ThemeName       = WindowConfig.Theme      or "Default"
	local T               = ThemesDict[ThemeName] or ThemesDict["Default"]

	local IntroConfig     = WindowConfig.Intro
	local ShowIntro       = IntroConfig ~= nil

	local IntroTitle    = ShowIntro and (IntroConfig.Title    or "Lua Land Ui Library") or ""
	local IntroSubtitle = ShowIntro and (IntroConfig.Subtitle or "Developed By LLH Lua Land") or ""
	local IntroIcon     = ShowIntro and (IntroConfig.Icon     or "house") or "house"

	local KeyConfig      = WindowConfig.KeySystem
	local ShowKey        = KeyConfig ~= nil
	local KeyTitle       = ShowKey and (KeyConfig.Title     or "Lua Land Ui Key System")    or ""
	local KeySubtitle    = ShowKey and (KeyConfig.Subtitle  or "Developed By LLH Lua Land") or ""
	local KeyTitleIcon   = ShowKey and (KeyConfig.TitleIcon or "key-round")                 or "key-round"
	local KeyThemeName   = ShowKey and (KeyConfig.Theme     or "Fire")                      or "Fire"
	local KeyT           = ThemesDict[KeyThemeName] or ThemesDict["Fire"]
	local KeyCorrect     = ShowKey and (KeyConfig.Key       or "LuaLand")                   or "LuaLand"
	local KeyGetLink     = ShowKey and (KeyConfig.GetLink   or "https://linkvertise.com")   or ""
	local KeyScript      = ShowKey and KeyConfig.Script                                     or nil
	local KeyNotifTitle  = ShowKey and (KeyConfig.NotifTitle or "Lua Land Ui Library")      or ""
	local KeyNotifIcon   = ShowKey and (KeyConfig.NotifIcon  or "key")                      or "key"
	local KeyNotifDesc   = ShowKey and (KeyConfig.NotifDesc  or "Link copied to clipboard!") or ""

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LuaLandGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = RunService:IsStudio()
		and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 500, 0, 350)
	MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
	MainFrame.BackgroundColor3 = T.WindowBg
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Visible = false
	MainFrame.Parent = ScreenGui

	if ShowIntro then
		local IntroFrame = Instance.new("Frame")
		IntroFrame.Name = "IntroFrame"
		IntroFrame.Size = UDim2.new(0, 320, 0, 120)
		IntroFrame.Position = UDim2.new(0.5, -160, 0.5, -60)
		IntroFrame.BackgroundColor3 = T.TitleBarBg
		IntroFrame.BackgroundTransparency = 1
		IntroFrame.BorderSizePixel = 0
		IntroFrame.Parent = ScreenGui

		local IFCorner = Instance.new("UICorner")
		IFCorner.CornerRadius = UDim.new(0, 12)
		IFCorner.Parent = IntroFrame

		local IIconFrame = Instance.new("Frame")
		IIconFrame.Size = UDim2.new(0, 48, 0, 48)
		IIconFrame.Position = UDim2.new(0.5, -24, 0, 18)
		IIconFrame.BackgroundTransparency = 1
		IIconFrame.Parent = IntroFrame

		local IIcon = Instance.new("ImageLabel")
		IIcon.Size = UDim2.new(1, 0, 1, 0)
		IIcon.BackgroundTransparency = 1
		IIcon.Image = IconsDict[IntroIcon] or IconsDict["house"] or ""
		IIcon.ImageColor3 = T.AccentColor
		IIcon.ImageTransparency = 1
		IIcon.Parent = IIconFrame

		local ITitleLbl = Instance.new("TextLabel")
		ITitleLbl.Size = UDim2.new(1, -20, 0, 0)
		ITitleLbl.AutomaticSize = Enum.AutomaticSize.Y
		ITitleLbl.Position = UDim2.new(0, 10, 0, 72)
		ITitleLbl.BackgroundTransparency = 1
		ITitleLbl.Text = IntroTitle
		ITitleLbl.TextColor3 = T.PrimaryText
		ITitleLbl.TextTransparency = 1
		ITitleLbl.TextSize = 18
		ITitleLbl.Font = Enum.Font.GothamBold
		ITitleLbl.TextXAlignment = Enum.TextXAlignment.Center
		ITitleLbl.TextWrapped = true
		ITitleLbl.Parent = IntroFrame

		local ISubLbl = Instance.new("TextLabel")
		ISubLbl.Size = UDim2.new(1, -20, 0, 0)
		ISubLbl.AutomaticSize = Enum.AutomaticSize.Y
		ISubLbl.Position = UDim2.new(0, 10, 0, 96)
		ISubLbl.BackgroundTransparency = 1
		ISubLbl.Text = IntroSubtitle
		ISubLbl.TextColor3 = T.SecondaryText
		ISubLbl.TextTransparency = 1
		ISubLbl.TextSize = 12
		ISubLbl.Font = Enum.Font.Gotham
		ISubLbl.TextXAlignment = Enum.TextXAlignment.Center
		ISubLbl.TextWrapped = true
		ISubLbl.Parent = IntroFrame

		local ILine = Instance.new("Frame")
		ILine.Size = UDim2.new(0, 0, 0, 2)
		ILine.Position = UDim2.new(0.5, 0, 1, -10)
		ILine.AnchorPoint = Vector2.new(0.5, 0)
		ILine.BackgroundColor3 = T.AccentColor
		ILine.BorderSizePixel = 0
		ILine.Parent = IntroFrame

		local ILineCor = Instance.new("UICorner")
		ILineCor.CornerRadius = UDim.new(1, 0)
		ILineCor.Parent = ILine

		local tw = TweenInfo.new
		local fast  = tw(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local med   = tw(0.5,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local slow  = tw(0.8,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local exit  = tw(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		local function tween(obj, info, props)
			TweenService:Create(obj, info, props):Play()
		end

		task.spawn(function()
			task.wait(0.05)

			tween(IntroFrame, fast, {BackgroundTransparency = 0})
			tween(IIcon, fast, {ImageTransparency = 0})
			task.wait(0.3)

			tween(ITitleLbl, med, {TextTransparency = 0})
			task.wait(0.25)

			tween(ISubLbl, med, {TextTransparency = 0})
			task.wait(0.2)

			tween(ILine, slow, {Size = UDim2.new(0.7, 0, 0, 2)})
			task.wait(1.2)

			tween(ILine,     exit, {Size = UDim2.new(0, 0, 0, 2)})
			tween(ISubLbl,   exit, {TextTransparency = 1})
			task.wait(0.15)
			tween(ITitleLbl, exit, {TextTransparency = 1})
			task.wait(0.1)
			tween(IIcon,     exit, {ImageTransparency = 1})
			task.wait(0.15)
			tween(IntroFrame, exit, {
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, -160, 0.5, -80),
			})
			task.wait(0.45)
			IntroFrame:Destroy()

			local function ShowNotification(ntTitle, ntIcon, ntDesc)
				local NGui = Instance.new("ScreenGui")
				NGui.Name = "LLNotif"
				NGui.ResetOnSpawn = false
				NGui.Parent = RunService:IsStudio()
					and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

				local NFrame = Instance.new("Frame")
				NFrame.Size = UDim2.new(0, 260, 0, 64)
				NFrame.Position = UDim2.new(0, -270, 1, -80)
				NFrame.BackgroundColor3 = T.TitleBarBg
				NFrame.BorderSizePixel = 0
				NFrame.Parent = NGui

				local NFCorner = Instance.new("UICorner")
				NFCorner.CornerRadius = UDim.new(0, 10)
				NFCorner.Parent = NFrame

				local NAccentBar = Instance.new("Frame")
				NAccentBar.Size = UDim2.new(0, 4, 1, 0)
				NAccentBar.BackgroundColor3 = T.AccentColor
				NAccentBar.BorderSizePixel = 0
				NAccentBar.Parent = NFrame

				local NAccentCorner = Instance.new("UICorner")
				NAccentCorner.CornerRadius = UDim.new(0, 10)
				NAccentCorner.Parent = NAccentBar

				local NIco = Instance.new("ImageLabel")
				NIco.Size = UDim2.new(0, 20, 0, 20)
				NIco.Position = UDim2.new(0, 12, 0, 12)
				NIco.BackgroundTransparency = 1
				NIco.Image = IconsDict[ntIcon] or IconsDict["key"] or ""
				NIco.ImageColor3 = T.AccentColor
				NIco.Parent = NFrame

				local NTitle = Instance.new("TextLabel")
				NTitle.Size = UDim2.new(1, -42, 0, 18)
				NTitle.Position = UDim2.new(0, 38, 0, 10)
				NTitle.BackgroundTransparency = 1
				NTitle.Text = ntTitle
				NTitle.TextColor3 = T.PrimaryText
				NTitle.TextSize = 13
				NTitle.Font = Enum.Font.GothamBold
				NTitle.TextXAlignment = Enum.TextXAlignment.Left
				NTitle.TextWrapped = true
				NTitle.Parent = NFrame

				local NDesc = Instance.new("TextLabel")
				NDesc.Size = UDim2.new(1, -42, 0, 16)
				NDesc.Position = UDim2.new(0, 38, 0, 30)
				NDesc.BackgroundTransparency = 1
				NDesc.Text = ntDesc
				NDesc.TextColor3 = T.SecondaryText
				NDesc.TextSize = 11
				NDesc.Font = Enum.Font.Gotham
				NDesc.TextXAlignment = Enum.TextXAlignment.Left
				NDesc.TextWrapped = true
				NDesc.Parent = NFrame

				local NProgress = Instance.new("Frame")
				NProgress.Size = UDim2.new(1, 0, 0, 2)
				NProgress.Position = UDim2.new(0, 0, 1, -2)
				NProgress.BackgroundColor3 = T.AccentColor
				NProgress.BorderSizePixel = 0
				NProgress.Parent = NFrame

				local NProgCorner = Instance.new("UICorner")
				NProgCorner.CornerRadius = UDim.new(1, 0)
				NProgCorner.Parent = NProgress

				local nfast = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				local nslow = TweenInfo.new(5, Enum.EasingStyle.Linear)
				local nexit = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

				TweenService:Create(NFrame, nfast, {Position = UDim2.new(0, 12, 1, -80)}):Play()
				task.wait(0.4)
				TweenService:Create(NProgress, nslow, {Size = UDim2.new(0, 0, 0, 2)}):Play()
				task.wait(5)
				TweenService:Create(NFrame, nexit, {Position = UDim2.new(0, -270, 1, -80)}):Play()
				task.wait(0.35)
				NGui:Destroy()
			end

			if ShowKey then
				local KeyPassed = false

				local KGui = Instance.new("ScreenGui")
				KGui.Name = "LLKeySystem"
				KGui.ResetOnSpawn = false
				KGui.Parent = RunService:IsStudio()
					and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui

				local KFrame = Instance.new("Frame")
				KFrame.Name = "KeyFrame"
				KFrame.Size = UDim2.new(0, 440, 0, 240)
				KFrame.Position = UDim2.new(0.5, -220, 0.5, -120)
				KFrame.BackgroundColor3 = KeyT.WindowBg
				KFrame.BorderSizePixel = 0
				KFrame.ClipsDescendants = false
				KFrame.Parent = KGui

				local KCorner = Instance.new("UICorner")
				KCorner.CornerRadius = UDim.new(0, 10)
				KCorner.Parent = KFrame

				local KTitleBar = Instance.new("Frame")
				KTitleBar.Name = "KTitleBar"
				KTitleBar.Size = UDim2.new(1, 0, 0, 48)
				KTitleBar.BackgroundColor3 = KeyT.TitleBarBg
				KTitleBar.BorderSizePixel = 0
				KTitleBar.ZIndex = 5
				KTitleBar.Parent = KFrame

				local KTBCorner = Instance.new("UICorner")
				KTBCorner.CornerRadius = UDim.new(0, 10)
				KTBCorner.Parent = KTitleBar

				local KTBFill = Instance.new("Frame")
				KTBFill.Size = UDim2.new(1, 0, 0, 10)
				KTBFill.Position = UDim2.new(0, 0, 1, -10)
				KTBFill.BackgroundColor3 = KeyT.TitleBarBg
				KTBFill.BorderSizePixel = 0
				KTBFill.ZIndex = 5
				KTBFill.Parent = KTitleBar

				local KTIcon = Instance.new("ImageLabel")
				KTIcon.Size = UDim2.new(0, 20, 0, 20)
				KTIcon.Position = UDim2.new(0, 10, 0.5, -10)
				KTIcon.BackgroundTransparency = 1
				KTIcon.Image = IconsDict[KeyTitleIcon] or IconsDict["key-round"] or ""
				KTIcon.ImageColor3 = KeyT.PrimaryText
				KTIcon.ZIndex = 6
				KTIcon.Parent = KTitleBar

				local KTTitle = Instance.new("TextLabel")
				KTTitle.Size = UDim2.new(1, -40, 0, 18)
				KTTitle.Position = UDim2.new(0, 36, 0, 6)
				KTTitle.BackgroundTransparency = 1
				KTTitle.Text = KeyTitle
				KTTitle.TextColor3 = KeyT.PrimaryText
				KTTitle.TextSize = 14
				KTTitle.Font = Enum.Font.GothamBold
				KTTitle.TextXAlignment = Enum.TextXAlignment.Left
				KTTitle.TextWrapped = true
				KTTitle.ZIndex = 6
				KTTitle.Parent = KTitleBar

				local KTSub = Instance.new("TextLabel")
				KTSub.Size = UDim2.new(1, -40, 0, 13)
				KTSub.Position = UDim2.new(0, 36, 0, 26)
				KTSub.BackgroundTransparency = 1
				KTSub.Text = KeySubtitle
				KTSub.TextColor3 = KeyT.SecondaryText
				KTSub.TextSize = 11
				KTSub.Font = Enum.Font.Gotham
				KTSub.TextXAlignment = Enum.TextXAlignment.Left
				KTSub.TextWrapped = true
				KTSub.ZIndex = 6
				KTSub.Parent = KTitleBar

				local KDivider = Instance.new("Frame")
				KDivider.Size = UDim2.new(1, -24, 0, 1)
				KDivider.Position = UDim2.new(0, 12, 0, 48)
				KDivider.BackgroundColor3 = KeyT.TabActive
				KDivider.BorderSizePixel = 0
				KDivider.Parent = KFrame

				local KTextboxFrame = Instance.new("Frame")
				KTextboxFrame.Size = UDim2.new(1, -28, 0, 44)
				KTextboxFrame.Position = UDim2.new(0, 14, 0, 62)
				KTextboxFrame.BackgroundColor3 = KeyT.ElementBg
				KTextboxFrame.BorderSizePixel = 0
				KTextboxFrame.Parent = KFrame

				local KTBxCorner = Instance.new("UICorner")
				KTBxCorner.CornerRadius = UDim.new(0, 7)
				KTBxCorner.Parent = KTextboxFrame

				local KTBxStroke = Instance.new("UIStroke")
				KTBxStroke.Color = Color3.fromRGB(255, 255, 255)
				KTBxStroke.Thickness = 1
				KTBxStroke.Parent = KTextboxFrame

				local KTextbox = Instance.new("TextBox")
				KTextbox.Size = UDim2.new(1, -16, 1, 0)
				KTextbox.Position = UDim2.new(0, 8, 0, 0)
				KTextbox.BackgroundTransparency = 1
				KTextbox.PlaceholderText = "Place your key..."
				KTextbox.Text = ""
				KTextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
				KTextbox.PlaceholderColor3 = KeyT.SecondaryText
				KTextbox.TextSize = 13
				KTextbox.Font = Enum.Font.Gotham
				KTextbox.TextXAlignment = Enum.TextXAlignment.Left
				KTextbox.ClearTextOnFocus = false
				KTextbox.MaxVisibleGraphemes = 50
				KTextbox.Parent = KTextboxFrame

				KTextbox:GetPropertyChangedSignal("Text"):Connect(function()
					if #KTextbox.Text > 50 then
						KTextbox.Text = KTextbox.Text:sub(1, 50)
					end
				end)

				local KStatusLabel = Instance.new("TextLabel")
				KStatusLabel.Size = UDim2.new(1, -28, 0, 16)
				KStatusLabel.Position = UDim2.new(0, 14, 0, 114)
				KStatusLabel.BackgroundTransparency = 1
				KStatusLabel.Text = ""
				KStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
				KStatusLabel.TextSize = 11
				KStatusLabel.Font = Enum.Font.Gotham
				KStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
				KStatusLabel.TextWrapped = true
				KStatusLabel.Parent = KFrame

				local KBtnRow = Instance.new("Frame")
				KBtnRow.Size = UDim2.new(1, -28, 0, 38)
				KBtnRow.Position = UDim2.new(0, 14, 0, 184)
				KBtnRow.BackgroundTransparency = 1
				KBtnRow.Parent = KFrame

				local KBtnLayout = Instance.new("UIListLayout")
				KBtnLayout.FillDirection = Enum.FillDirection.Horizontal
				KBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				KBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				KBtnLayout.Padding = UDim.new(0, 8)
				KBtnLayout.Parent = KBtnRow

				local function MakeKeyBtn(labelTxt, iconKey, bgColor, w)
					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(0, w, 1, 0)
					Btn.BackgroundColor3 = bgColor
					Btn.Text = ""
					Btn.AutoButtonColor = false
					Btn.Parent = KBtnRow

					local BCorner = Instance.new("UICorner")
					BCorner.CornerRadius = UDim.new(0, 6)
					BCorner.Parent = Btn

					local BIcon = Instance.new("ImageLabel")
					BIcon.Size = UDim2.new(0, 14, 0, 14)
					BIcon.Position = UDim2.new(0, 8, 0.5, -7)
					BIcon.BackgroundTransparency = 1
					BIcon.Image = IconsDict[iconKey] or ""
					BIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					BIcon.Parent = Btn

					local BLabel = Instance.new("TextLabel")
					BLabel.Size = UDim2.new(1, -26, 1, 0)
					BLabel.Position = UDim2.new(0, 26, 0, 0)
					BLabel.BackgroundTransparency = 1
					BLabel.Text = labelTxt
					BLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					BLabel.TextSize = 13
					BLabel.Font = Enum.Font.GothamMedium
					BLabel.TextXAlignment = Enum.TextXAlignment.Left
					BLabel.Parent = Btn

					return Btn
				end

				local CheckBtn  = MakeKeyBtn("Check Key", "key",      KeyT.AccentColor,           128)
				local ClearBtn2 = MakeKeyBtn("Clear",     "trash",    Color3.fromRGB(60, 25, 25),  90)
				local GetBtn    = MakeKeyBtn("Get Key",   "hand-grab",Color3.fromRGB(30, 55, 30), 108)

				CheckBtn.MouseButton1Click:Connect(function()
					local input = KTextbox.Text
					if input == KeyCorrect then
						KStatusLabel.TextColor3 = Color3.fromRGB(60, 220, 100)
						KStatusLabel.Text = "Key accepted! Loading..."
						task.wait(0.8)
						TweenService:Create(KFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
							Size = UDim2.new(0, 340, 0, 0),
							Position = UDim2.new(0.5, -170, 0.5, -100),
						}):Play()
						task.wait(0.35)
						KGui:Destroy()
						KeyPassed = true
						MainFrame.Visible = true
						MainFrame.Position = UDim2.new(0.5, -250, 0.6, -175)
						MainFrame.BackgroundTransparency = 1
						TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Position = UDim2.new(0.5, -250, 0.5, -175),
							BackgroundTransparency = 0,
						}):Play()
						if KeyScript then
							task.wait(0.4)
							task.spawn(KeyScript)
						end
					else
						KStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
						KStatusLabel.Text = "Invalid key. Try again."
						TweenService:Create(KTextboxFrame, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(80, 20, 20)}):Play()
						task.wait(0.3)
						TweenService:Create(KTextboxFrame, TweenInfo.new(0.15), {BackgroundColor3 = KeyT.ElementBg}):Play()
					end
				end)

				ClearBtn2.MouseButton1Click:Connect(function()
					KTextbox.Text = ""
					KStatusLabel.Text = ""
				end)

				GetBtn.MouseButton1Click:Connect(function()
					if setclipboard then
						setclipboard(KeyGetLink)
					end
					task.spawn(ShowNotification, KeyNotifTitle, KeyNotifIcon, KeyNotifDesc)
				end)

				local KDragging, KDragInput, KDragStart, KStartPos = false, nil, nil, nil
				KTitleBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						KDragging = true
						KDragStart = input.Position
						KStartPos  = KFrame.Position
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then KDragging = false end
						end)
					end
				end)
				KTitleBar.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch then
						KDragInput = input
					end
				end)
				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if input == KDragInput and KDragging then
						local d = input.Position - KDragStart
						KFrame.Position = UDim2.new(KStartPos.X.Scale, KStartPos.X.Offset + d.X,
						                            KStartPos.Y.Scale, KStartPos.Y.Offset + d.Y)
					end
				end)

				KFrame.BackgroundTransparency = 1
				for _, v in pairs(KFrame:GetDescendants()) do
					if v:IsA("TextLabel") then v.TextTransparency = 1
					elseif v:IsA("ImageLabel") then v.ImageTransparency = 1
					elseif v:IsA("Frame") then v.BackgroundTransparency = 1 end
				end
				KTBxStroke.Transparency = 1

				task.wait(0.05)
				TweenService:Create(KFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				task.wait(0.05)
				for _, v in pairs(KFrame:GetDescendants()) do
					if v:IsA("TextLabel") then
						TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
					elseif v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
					elseif v:IsA("Frame") and v.Name ~= "KTBFill" then
						TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
					end
				end
				TweenService:Create(KTBxStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()

			else
				MainFrame.Visible = true
				MainFrame.Position = UDim2.new(0.5, -250, 0.6, -175)
				MainFrame.BackgroundTransparency = 1
				TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = UDim2.new(0.5, -250, 0.5, -175),
					BackgroundTransparency = 0,
				}):Play()
			end
		end)
	else
		MainFrame.Visible = true
	end

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = MainFrame

	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 50)
	TitleBar.BackgroundColor3 = T.TitleBarBg
	TitleBar.BorderSizePixel = 0
	TitleBar.ZIndex = 10
	TitleBar.Parent = MainFrame

	local TitleIcon = Instance.new("ImageLabel")
	TitleIcon.Size = UDim2.new(0, 24, 0, 24)
	TitleIcon.Position = UDim2.new(0, 10, 0, 13)
	TitleIcon.BackgroundTransparency = 1
	TitleIcon.Image = IconsDict[TitleIconString] or IconsDict["book-open-text"]
	TitleIcon.ImageColor3 = T.PrimaryText
	TitleIcon.ZIndex = 10
	TitleIcon.Parent = TitleBar

	local TitleText = Instance.new("TextLabel")
	TitleText.Size = UDim2.new(0, 250, 0, 20)
	TitleText.Position = UDim2.new(0, 44, 0, 8)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = TitleString
	TitleText.TextColor3 = T.PrimaryText
	TitleText.TextSize = 16
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.TextWrapped = true
	TitleText.ZIndex = 10
	TitleText.Parent = TitleBar

	local SubtitleText = Instance.new("TextLabel")
	SubtitleText.Size = UDim2.new(0, 250, 0, 15)
	SubtitleText.Position = UDim2.new(0, 44, 0, 28)
	SubtitleText.BackgroundTransparency = 1
	SubtitleText.Text = SubtitleString
	SubtitleText.TextColor3 = T.SecondaryText
	SubtitleText.TextSize = 12
	SubtitleText.Font = Enum.Font.Gotham
	SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
	SubtitleText.TextWrapped = true
	SubtitleText.ZIndex = 10
	SubtitleText.Parent = TitleBar

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Name = "CloseButton"
	CloseBtn.Size = UDim2.new(0, 20, 0, 20)
	CloseBtn.Position = UDim2.new(1, -30, 0, 15)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = "rbxassetid://130629964514885"
	CloseBtn.ImageColor3 = T.PrimaryText
	CloseBtn.ZIndex = 10
	CloseBtn.Parent = TitleBar

	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.15), {ImageColor3 = T.SecondaryText}):Play()
	end)
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.15), {ImageColor3 = T.PrimaryText}):Play()
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 500, 0, 0),
			Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
			                     MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + 175)
		}):Play()
		task.delay(0.22, function() ScreenGui:Destroy() end)
	end)

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Name = "MinimizeButton"
	MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
	MinimizeBtn.Position = UDim2.new(1, -56, 0, 15)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.Text = ""
	MinimizeBtn.ZIndex = 10
	MinimizeBtn.Parent = TitleBar

	local MinimizeLine = Instance.new("Frame")
	MinimizeLine.Size = UDim2.new(1, 0, 0, 2)
	MinimizeLine.Position = UDim2.new(0, 0, 0.65, 0)
	MinimizeLine.BackgroundColor3 = T.PrimaryText
	MinimizeLine.BorderSizePixel = 0
	MinimizeLine.ZIndex = 10
	MinimizeLine.Parent = MinimizeBtn

	local MinLineCorner = Instance.new("UICorner")
	MinLineCorner.CornerRadius = UDim.new(1, 0)
	MinLineCorner.Parent = MinimizeLine

	local IsMinimized   = false
	local NormalSize    = UDim2.new(0, 500, 0, 350)
	local MinimizedSize = UDim2.new(0, 500, 0, 50)

	MinimizeBtn.MouseEnter:Connect(function()
		TweenService:Create(MinimizeLine, TweenInfo.new(0.15), {BackgroundColor3 = T.AccentColor}):Play()
	end)
	MinimizeBtn.MouseLeave:Connect(function()
		TweenService:Create(MinimizeLine, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryText}):Play()
	end)

	local Dragging, DragInput, DragStart, StartPos = false, nil, nil, nil
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true; DragStart = input.Position; StartPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)
	TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local d = input.Position - DragStart
			MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + d.X,
			                               StartPos.Y.Scale, StartPos.Y.Offset + d.Y)
		end
	end)

	local Body = Instance.new("Frame")
	Body.Name = "Body"
	Body.Size = UDim2.new(1, 0, 1, -50)
	Body.Position = UDim2.new(0, 0, 0, 50)
	Body.BackgroundTransparency = 1
	Body.ClipsDescendants = true
	Body.Parent = MainFrame

	MinimizeBtn.MouseButton1Click:Connect(function()
		IsMinimized = not IsMinimized
		if IsMinimized then
			Body.Visible = false
			TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = MinimizedSize}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = NormalSize}):Play()
			task.delay(0.05, function() Body.Visible = true end)
		end
	end)

	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 130, 1, 0)
	Sidebar.BackgroundColor3 = T.SidebarBg
	Sidebar.BackgroundTransparency = 0
	Sidebar.ScrollBarThickness = 2
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Body

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.Parent = Sidebar

	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingLeft  = UDim.new(0, 10)
	SidebarPadding.PaddingRight = UDim.new(0, 10)
	SidebarPadding.PaddingTop   = UDim.new(0, 5)
	SidebarPadding.Parent = Sidebar

	SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
	end)

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -130, 1, 0)
	ContentContainer.Position = UDim2.new(0, 130, 0, 0)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = Body

	local WindowHandling = {}
	local TabsCollection  = {}

	local SettingsHandling = {}

	function SettingsHandling:SetTitle(NewTitle)
		TitleText.Text = NewTitle
	end

	function SettingsHandling:SetSubtitle(NewSubtitle)
		SubtitleText.Text = NewSubtitle
	end

	function SettingsHandling:SetTitleIcon(IconName)
		TitleIcon.Image = IconsDict[IconName] or IconsDict["book-open-text"]
	end

	function SettingsHandling:SetTheme(NewThemeName)
		local NT = ThemesDict[NewThemeName] or ThemesDict["Default"]
		MainFrame.BackgroundColor3  = NT.WindowBg
		TitleBar.BackgroundColor3   = NT.TitleBarBg
		Sidebar.BackgroundColor3    = NT.SidebarBg
		TitleText.TextColor3        = NT.PrimaryText
		SubtitleText.TextColor3     = NT.SecondaryText
		TitleIcon.ImageColor3       = NT.PrimaryText
		CloseBtn.ImageColor3        = NT.PrimaryText
		MinimizeLine.BackgroundColor3 = NT.PrimaryText
		for _, tabData in ipairs(TabsCollection) do
			local isActive = tabData.Wrapper.Visible
			tabData.Button.BackgroundColor3 = isActive and NT.TabActive or NT.TabInactive
		end
	end

	WindowHandling.Settings = SettingsHandling

	function WindowHandling:CreateTab(TabConfig)
		local TabName       = TabConfig.Name or "Tab"
		local TabIconString = TabConfig.Icon or "book"

		local ShowSearch        = TabConfig.SearchBar         ~= false
		local SearchPlaceholder = TabConfig.SearchPlaceholder or "Search From This Page..."
		local SearchBarColor    = TabConfig.SearchBarColor    or T.SearchBarBg
		local SearchTextColor   = TabConfig.SearchTextColor   or T.PrimaryText
		local SearchIconColor   = TabConfig.SearchIconColor   or T.SecondaryText

		local TabButton = Instance.new("TextButton")
		TabButton.Name = TabName .. "Tab"
		TabButton.Size = UDim2.new(1, 0, 0, 30)
		TabButton.BackgroundColor3 = T.TabInactive
		TabButton.BorderSizePixel  = 0
		TabButton.Text = ""
		TabButton.Parent = Sidebar

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabButton

		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Size = UDim2.new(0, 16, 0, 16)
		TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
		TabIcon.BackgroundTransparency = 1
		TabIcon.Image = IconsDict[TabIconString] or IconsDict["book"]
		TabIcon.ImageColor3 = T.PrimaryText
		TabIcon.Parent = TabButton

		local TabText = Instance.new("TextLabel")
		TabText.Size = UDim2.new(1, -34, 1, 0)
		TabText.Position = UDim2.new(0, 30, 0, 0)
		TabText.BackgroundTransparency = 1
		TabText.Text = TabName
		TabText.TextColor3 = T.PrimaryText
		TabText.TextSize = 12
		TabText.Font = Enum.Font.GothamMedium
		TabText.TextXAlignment = Enum.TextXAlignment.Left
		TabText.TextWrapped = true
		TabText.Parent = TabButton

		local TabWrapper = Instance.new("Frame")
		TabWrapper.Name = TabName .. "Wrapper"
		TabWrapper.Size = UDim2.new(1, 0, 1, 0)
		TabWrapper.BackgroundTransparency = 1
		TabWrapper.Visible = false
		TabWrapper.Parent = ContentContainer

		local SearchBarHeight = ShowSearch and 34 or 0
		local ElementRegistry = {}

		if ShowSearch then
			local SearchBarFrame = Instance.new("Frame")
			SearchBarFrame.Name = "SearchBarFrame"
			SearchBarFrame.Size = UDim2.new(1, -20, 0, 26)
			SearchBarFrame.Position = UDim2.new(0, 10, 0, 4)
			SearchBarFrame.BackgroundColor3 = SearchBarColor
			SearchBarFrame.BorderSizePixel = 0
			SearchBarFrame.Parent = TabWrapper

			local SBCorner = Instance.new("UICorner")
			SBCorner.CornerRadius = UDim.new(0, 6)
			SBCorner.Parent = SearchBarFrame

			local SearchIcon = Instance.new("ImageButton")
			SearchIcon.Size = UDim2.new(0, 14, 0, 14)
			SearchIcon.Position = UDim2.new(0, 7, 0.5, -7)
			SearchIcon.BackgroundTransparency = 1
			SearchIcon.Image = "rbxassetid://118685771787843"
			SearchIcon.ImageColor3 = SearchIconColor
			SearchIcon.Parent = SearchBarFrame

			local SearchBox = Instance.new("TextBox")
			SearchBox.Name = "SearchBox"
			SearchBox.Size = UDim2.new(1, -56, 1, 0)
			SearchBox.Position = UDim2.new(0, 26, 0, 0)
			SearchBox.BackgroundTransparency = 1
			SearchBox.PlaceholderText = SearchPlaceholder
			SearchBox.Text = ""
			SearchBox.TextColor3 = SearchTextColor
			SearchBox.PlaceholderColor3 = T.SecondaryText
			SearchBox.TextSize = 12
			SearchBox.Font = Enum.Font.Gotham
			SearchBox.TextXAlignment = Enum.TextXAlignment.Left
			SearchBox.ClearTextOnFocus = false
			SearchBox.TextWrapped = true
			SearchBox.Parent = SearchBarFrame

			local ClearBtn = Instance.new("ImageButton")
			ClearBtn.Size = UDim2.new(0, 14, 0, 14)
			ClearBtn.Position = UDim2.new(1, -20, 0.5, -7)
			ClearBtn.BackgroundTransparency = 1
			ClearBtn.Image = "rbxassetid://130629964514885"
			ClearBtn.ImageColor3 = T.PrimaryText
			ClearBtn.Visible = false
			ClearBtn.Parent = SearchBarFrame

			SearchIcon.MouseButton1Click:Connect(function()
				SearchBox:CaptureFocus()
				RunSearch(SearchBox.Text, ElementRegistry)
			end)
			SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				ClearBtn.Visible = SearchBox.Text ~= ""
				RunSearch(SearchBox.Text, ElementRegistry)
			end)
			SearchBox.FocusLost:Connect(function(entered)
				if entered then RunSearch(SearchBox.Text, ElementRegistry) end
			end)
			ClearBtn.MouseButton1Click:Connect(function()
				SearchBox.Text = ""
				ClearBtn.Visible = false
				RunSearch("", ElementRegistry)
			end)
		end

		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Name = TabName .. "Content"
		TabContent.Size = UDim2.new(1, 0, 1, -SearchBarHeight)
		TabContent.Position = UDim2.new(0, 0, 0, SearchBarHeight)
		TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		TabContent.BackgroundTransparency = 1
		TabContent.ScrollBarThickness = 2
		TabContent.BorderSizePixel = 0
		TabContent.Parent = TabWrapper

		local ContentLayout = Instance.new("UIListLayout")
		ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ContentLayout.Padding = UDim.new(0, 8)
		ContentLayout.Parent = TabContent

		local ContentPadding = Instance.new("UIPadding")
		ContentPadding.PaddingLeft   = UDim.new(0, 10)
		ContentPadding.PaddingRight  = UDim.new(0, 15)
		ContentPadding.PaddingTop    = UDim.new(0, 5)
		ContentPadding.PaddingBottom = UDim.new(0, 10)
		ContentPadding.Parent = TabContent

		table.insert(TabsCollection, {Button = TabButton, Wrapper = TabWrapper})

		TabButton.MouseButton1Click:Connect(function()
			for _, t in ipairs(TabsCollection) do
				t.Wrapper.Visible = false
				t.Button.BackgroundColor3 = T.TabInactive
			end
			TabWrapper.Visible = true
			TabButton.BackgroundColor3 = T.TabActive
		end)

		if #TabsCollection == 1 then
			TabWrapper.Visible = true
			TabButton.BackgroundColor3 = T.TabActive
		end

		local TabHandling = {}

		local function Reg(frame, label)
			if ShowSearch then
				table.insert(ElementRegistry, {Frame = frame, Label = label})
			end
		end

		function TabHandling:CreateSection(SectionText)
			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Size = UDim2.new(1, 0, 0, 0)
			SectionLabel.AutomaticSize = Enum.AutomaticSize.Y
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.Text = SectionText
			SectionLabel.TextColor3 = T.PrimaryText
			SectionLabel.TextSize = 14
			SectionLabel.Font = Enum.Font.GothamBold
			SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			SectionLabel.TextWrapped = true
			SectionLabel.Parent = TabContent
			Reg(SectionLabel, SectionText)
		end

		function TabHandling:CreateLabel(LabelText)
			local TxtLabel = Instance.new("TextLabel")
			TxtLabel.Size = UDim2.new(1, 0, 0, 0)
			TxtLabel.AutomaticSize = Enum.AutomaticSize.Y
			TxtLabel.BackgroundTransparency = 1
			TxtLabel.Text = LabelText
			TxtLabel.TextColor3 = T.SecondaryText
			TxtLabel.TextSize = 13
			TxtLabel.Font = Enum.Font.Gotham
			TxtLabel.TextXAlignment = Enum.TextXAlignment.Left
			TxtLabel.TextWrapped = true
			TxtLabel.Parent = TabContent
			Reg(TxtLabel, LabelText)
			return TxtLabel
		end

		function TabHandling:CreateToggle(ToggleText, Callback)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
			ToggleFrame.BackgroundColor3 = T.ElementBg
			ToggleFrame.ClipsDescendants = false
			ToggleFrame.Parent = TabContent

			local TCorner = Instance.new("UICorner")
			TCorner.CornerRadius = UDim.new(0, 6)
			TCorner.Parent = ToggleFrame

			local TText = Instance.new("TextLabel")
			TText.Size = UDim2.new(1, -58, 1, 0)
			TText.Position = UDim2.new(0, 12, 0, 0)
			TText.BackgroundTransparency = 1
			TText.Text = ToggleText
			TText.TextColor3 = T.PrimaryText
			TText.TextSize = 13
			TText.Font = Enum.Font.GothamMedium
			TText.TextXAlignment = Enum.TextXAlignment.Left
			TText.TextWrapped = true
			TText.Parent = ToggleFrame

			local ToggleOuter = Instance.new("Frame")
			ToggleOuter.Size = UDim2.new(0, 40, 0, 20)
			ToggleOuter.Position = UDim2.new(1, -48, 0.5, -10)
			ToggleOuter.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			ToggleOuter.Parent = ToggleFrame

			local OuterCorner = Instance.new("UICorner")
			OuterCorner.CornerRadius = UDim.new(1, 0)
			OuterCorner.Parent = ToggleOuter

			local ToggleInner = Instance.new("Frame")
			ToggleInner.Size = UDim2.new(0, 16, 0, 16)
			ToggleInner.Position = UDim2.new(0, 2, 0.5, -8)
			ToggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleInner.Parent = ToggleOuter

			local InnerCorner = Instance.new("UICorner")
			InnerCorner.CornerRadius = UDim.new(1, 0)
			InnerCorner.Parent = ToggleInner

			local ToggleButton = Instance.new("TextButton")
			ToggleButton.Size = UDim2.new(1, 0, 1, 0)
			ToggleButton.BackgroundTransparency = 1
			ToggleButton.Text = ""
			ToggleButton.Parent = ToggleFrame

			local Toggled = false
			ToggleButton.MouseButton1Click:Connect(function()
				Toggled = not Toggled
				TweenService:Create(ToggleInner, TweenInfo.new(0.2), {
					Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				}):Play()
				TweenService:Create(ToggleOuter, TweenInfo.new(0.2), {
					BackgroundColor3 = Toggled and T.AccentColor or Color3.fromRGB(50, 50, 50)
				}):Play()
				Callback(Toggled)
			end)

			Reg(ToggleFrame, ToggleText)
		end

		function TabHandling:CreateButton(ButtonText, Callback)
			local ButtonFrame = Instance.new("TextButton")
			ButtonFrame.Name = "Button_" .. ButtonText
			ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
			ButtonFrame.BackgroundColor3 = T.ElementBg
			ButtonFrame.AutoButtonColor = false
			ButtonFrame.Text = ""
			ButtonFrame.Parent = TabContent

			local BCorner = Instance.new("UICorner")
			BCorner.CornerRadius = UDim.new(0, 6)
			BCorner.Parent = ButtonFrame

			local BLabel = Instance.new("TextLabel")
			BLabel.Size = UDim2.new(1, -42, 1, 0)
			BLabel.Position = UDim2.new(0, 12, 0, 0)
			BLabel.BackgroundTransparency = 1
			BLabel.Text = ButtonText
			BLabel.TextColor3 = T.PrimaryText
			BLabel.TextSize = 13
			BLabel.Font = Enum.Font.GothamMedium
			BLabel.TextXAlignment = Enum.TextXAlignment.Left
			BLabel.TextWrapped = true
			BLabel.Parent = ButtonFrame

			local BIcon = Instance.new("ImageLabel")
			BIcon.Size = UDim2.new(0, 18, 0, 18)
			BIcon.Position = UDim2.new(1, -28, 0.5, -9)
			BIcon.BackgroundTransparency = 1
			BIcon.Image = "rbxassetid://9728118892"
			BIcon.ImageColor3 = T.SecondaryText
			BIcon.Parent = ButtonFrame

			ButtonFrame.MouseEnter:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = T.TabActive}):Play()
				TweenService:Create(BIcon, TweenInfo.new(0.15), {ImageColor3 = T.PrimaryText}):Play()
			end)
			ButtonFrame.MouseLeave:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = T.ElementBg}):Play()
				TweenService:Create(BIcon, TweenInfo.new(0.15), {ImageColor3 = T.SecondaryText}):Play()
			end)
			ButtonFrame.MouseButton1Down:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = T.SidebarBg}):Play()
			end)
			ButtonFrame.MouseButton1Up:Connect(function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = T.TabActive}):Play()
			end)
			ButtonFrame.MouseButton1Click:Connect(function() Callback() end)

			Reg(ButtonFrame, ButtonText)
		end

		function TabHandling:CreateTextbox(TextboxConfig, Callback)
			local PlaceholderStr = TextboxConfig.Placeholder or "Type here..."
			local DefaultText    = TextboxConfig.Text        or ""

			local TextboxFrame = Instance.new("Frame")
			TextboxFrame.Size = UDim2.new(1, 0, 0, 35)
			TextboxFrame.BackgroundTransparency = 1
			TextboxFrame.Parent = TabContent

			local TBox = Instance.new("TextBox")
			TBox.Size = UDim2.new(1, 0, 1, 0)
			TBox.BackgroundColor3 = T.ElementBg
			TBox.PlaceholderText = PlaceholderStr
			TBox.Text = DefaultText
			TBox.TextColor3 = T.PrimaryText
			TBox.PlaceholderColor3 = T.SecondaryText
			TBox.TextSize = 13
			TBox.Font = Enum.Font.GothamMedium
			TBox.TextWrapped = true
			TBox.Parent = TextboxFrame

			local BoxCorner = Instance.new("UICorner")
			BoxCorner.CornerRadius = UDim.new(0, 6)
			BoxCorner.Parent = TBox

			TBox.FocusLost:Connect(function() Callback(TBox.Text) end)
			Reg(TextboxFrame, PlaceholderStr)
		end

		function TabHandling:CreateSlider(SliderText, MinValue, MaxValue, Callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, 0, 0, 0)
			SliderFrame.AutomaticSize = Enum.AutomaticSize.Y
			SliderFrame.BackgroundColor3 = T.ElementBg
			SliderFrame.Parent = TabContent

			local SCorner = Instance.new("UICorner")
			SCorner.CornerRadius = UDim.new(0, 6)
			SCorner.Parent = SliderFrame

			local SPad = Instance.new("UIPadding")
			SPad.PaddingLeft   = UDim.new(0, 10)
			SPad.PaddingRight  = UDim.new(0, 10)
			SPad.PaddingTop    = UDim.new(0, 6)
			SPad.PaddingBottom = UDim.new(0, 14)
			SPad.Parent = SliderFrame

			local SInner = Instance.new("Frame")
			SInner.Size = UDim2.new(1, 0, 0, 0)
			SInner.AutomaticSize = Enum.AutomaticSize.Y
			SInner.BackgroundTransparency = 1
			SInner.Parent = SliderFrame

			local SText = Instance.new("TextLabel")
			SText.Size = UDim2.new(1, -60, 0, 0)
			SText.AutomaticSize = Enum.AutomaticSize.Y
			SText.BackgroundTransparency = 1
			SText.Text = SliderText
			SText.TextColor3 = T.PrimaryText
			SText.TextSize = 13
			SText.Font = Enum.Font.GothamMedium
			SText.TextXAlignment = Enum.TextXAlignment.Left
			SText.TextWrapped = true
			SText.Parent = SInner

			local SValueText = Instance.new("TextLabel")
			SValueText.Size = UDim2.new(0, 55, 0, 18)
			SValueText.Position = UDim2.new(1, -55, 0, 0)
			SValueText.BackgroundTransparency = 1
			SValueText.Text = tostring(MinValue)
			SValueText.TextColor3 = T.AccentColor
			SValueText.TextSize = 13
			SValueText.Font = Enum.Font.GothamBold
			SValueText.TextXAlignment = Enum.TextXAlignment.Right
			SValueText.Parent = SInner

			local SliderBg = Instance.new("Frame")
			SliderBg.Size = UDim2.new(1, 0, 0, 4)
			SliderBg.Position = UDim2.new(0, 0, 1, 6)
			SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			SliderBg.ClipsDescendants = false
			SliderBg.Parent = SInner

			local BgCorner = Instance.new("UICorner")
			BgCorner.CornerRadius = UDim.new(1, 0)
			BgCorner.Parent = SliderBg

			local SliderFill = Instance.new("Frame")
			SliderFill.Size = UDim2.new(0, 0, 1, 0)
			SliderFill.BackgroundColor3 = T.AccentColor
			SliderFill.ZIndex = 2
			SliderFill.Parent = SliderBg

			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(1, 0)
			FillCorner.Parent = SliderFill

			local SliderThumb = Instance.new("Frame")
			SliderThumb.Size = UDim2.new(0, 12, 0, 12)
			SliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
			SliderThumb.Position = UDim2.new(0, 0, 0.5, 0)
			SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderThumb.ZIndex = 4
			SliderThumb.Parent = SliderBg

			local ThumbCorner = Instance.new("UICorner")
			ThumbCorner.CornerRadius = UDim.new(1, 0)
			ThumbCorner.Parent = SliderThumb

			local SliderBtn = Instance.new("TextButton")
			SliderBtn.Size = UDim2.new(1, 0, 0, 22)
			SliderBtn.Position = UDim2.new(0, 0, 0.5, -11)
			SliderBtn.BackgroundTransparency = 1
			SliderBtn.Text = ""
			SliderBtn.ZIndex = 5
			SliderBtn.Parent = SliderBg

			local SliderDragging = false

			local function UpdateSlider(mouseX)
				local percent = math.clamp((mouseX - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
				SliderFill.Size = UDim2.new(percent, 0, 1, 0)
				SliderThumb.Position = UDim2.new(percent, 0, 0.5, 0)
				local val = math.floor(MinValue + (MaxValue - MinValue) * percent)
				SValueText.Text = tostring(val)
				Callback(val)
			end

			SliderBtn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					SliderDragging = true
					UpdateSlider(UserInputService:GetMouseLocation().X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					SliderDragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if SliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(UserInputService:GetMouseLocation().X)
				end
			end)

			Reg(SliderFrame, SliderText)
		end

		function TabHandling:CreateCheckbox(CheckboxText, Callback)
			local CheckboxFrame = Instance.new("Frame")
			CheckboxFrame.Size = UDim2.new(1, 0, 0, 38)
			CheckboxFrame.BackgroundColor3 = T.ElementBg
			CheckboxFrame.ClipsDescendants = false
			CheckboxFrame.Parent = TabContent

			local CCorner = Instance.new("UICorner")
			CCorner.CornerRadius = UDim.new(0, 6)
			CCorner.Parent = CheckboxFrame

			local BoxVisual = Instance.new("Frame")
			BoxVisual.Size = UDim2.new(0, 18, 0, 18)
			BoxVisual.Position = UDim2.new(0, 10, 0.5, -9)
			BoxVisual.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			BoxVisual.Parent = CheckboxFrame

			local BoxCorner = Instance.new("UICorner")
			BoxCorner.CornerRadius = UDim.new(0, 4)
			BoxCorner.Parent = BoxVisual

			local BoxFill = Instance.new("Frame")
			BoxFill.Size = UDim2.new(1, 0, 1, 0)
			BoxFill.BackgroundColor3 = T.AccentColor
			BoxFill.Visible = false
			BoxFill.Parent = BoxVisual

			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(0, 4)
			FillCorner.Parent = BoxFill

			local CheckIcon = Instance.new("ImageLabel")
			CheckIcon.Size = UDim2.new(0, 13, 0, 13)
			CheckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			CheckIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
			CheckIcon.BackgroundTransparency = 1
			CheckIcon.Image = "rbxassetid://9754130783"
			CheckIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			CheckIcon.Visible = false
			CheckIcon.ZIndex = 3
			CheckIcon.Parent = BoxVisual

			local CText = Instance.new("TextLabel")
			CText.Size = UDim2.new(1, -36, 1, 0)
			CText.Position = UDim2.new(0, 34, 0, 0)
			CText.BackgroundTransparency = 1
			CText.Text = CheckboxText
			CText.TextColor3 = T.PrimaryText
			CText.TextSize = 13
			CText.Font = Enum.Font.GothamMedium
			CText.TextXAlignment = Enum.TextXAlignment.Left
			CText.TextWrapped = true
			CText.Parent = CheckboxFrame

			local CheckboxBtn = Instance.new("TextButton")
			CheckboxBtn.Size = UDim2.new(1, 0, 1, 0)
			CheckboxBtn.BackgroundTransparency = 1
			CheckboxBtn.Text = ""
			CheckboxBtn.Parent = CheckboxFrame

			local Checked = false
			CheckboxBtn.MouseButton1Click:Connect(function()
				Checked = not Checked
				BoxFill.Visible   = Checked
				CheckIcon.Visible = Checked
				TweenService:Create(BoxVisual, TweenInfo.new(0.15), {
					BackgroundColor3 = Checked and T.AccentColor or Color3.fromRGB(40, 40, 40)
				}):Play()
				Callback(Checked)
			end)
			Reg(CheckboxFrame, CheckboxText)
		end

		function TabHandling:CreateDropdown(DropdownConfig, Callback)
			local DropLabel       = DropdownConfig.Label       or "Dropdown"
			local DropOptions     = DropdownConfig.Options     or {}
			local DropShowSearch  = DropdownConfig.ShowSearch  ~= false
			local DropPlaceholder = DropdownConfig.Placeholder or "Select an option..."
			local DropDefault     = DropdownConfig.Default     or nil

			local IsOpen      = false
			local Selected    = DropDefault
			local ItemHeight  = 28
			local MaxVisible  = 5

			local DropFrame = Instance.new("Frame")
			DropFrame.Name = "Dropdown_" .. DropLabel
			DropFrame.Size = UDim2.new(1, 0, 0, 35)
			DropFrame.BackgroundColor3 = T.ElementBg
			DropFrame.ClipsDescendants = false
			DropFrame.Parent = TabContent

			local DCorner = Instance.new("UICorner")
			DCorner.CornerRadius = UDim.new(0, 6)
			DCorner.Parent = DropFrame

			local DLabelTxt = Instance.new("TextLabel")
			DLabelTxt.Size = UDim2.new(1, -40, 0, 35)
			DLabelTxt.Position = UDim2.new(0, 10, 0, 0)
			DLabelTxt.BackgroundTransparency = 1
			DLabelTxt.Text = DropLabel
			DLabelTxt.TextColor3 = T.PrimaryText
			DLabelTxt.TextSize = 13
			DLabelTxt.Font = Enum.Font.GothamMedium
			DLabelTxt.TextXAlignment = Enum.TextXAlignment.Left
			DLabelTxt.TextWrapped = true
			DLabelTxt.Parent = DropFrame

			local DSelectedTxt = Instance.new("TextLabel")
			DSelectedTxt.Size = UDim2.new(0.5, -25, 0, 35)
			DSelectedTxt.Position = UDim2.new(0.5, 0, 0, 0)
			DSelectedTxt.BackgroundTransparency = 1
			DSelectedTxt.Text = Selected or DropPlaceholder
			DSelectedTxt.TextColor3 = Selected and T.PrimaryText or T.SecondaryText
			DSelectedTxt.TextSize = 12
			DSelectedTxt.Font = Enum.Font.Gotham
			DSelectedTxt.TextXAlignment = Enum.TextXAlignment.Right
			DSelectedTxt.TextWrapped = true
			DSelectedTxt.Parent = DropFrame

			local DChevron = Instance.new("ImageLabel")
			DChevron.Size = UDim2.new(0, 14, 0, 14)
			DChevron.Position = UDim2.new(1, -24, 0.5, -7)
			DChevron.BackgroundTransparency = 1
			DChevron.Image = IconsDict["chevron-down"]
			DChevron.ImageColor3 = T.SecondaryText
			DChevron.Parent = DropFrame

			local DBtn = Instance.new("TextButton")
			DBtn.Size = UDim2.new(1, 0, 0, 35)
			DBtn.BackgroundTransparency = 1
			DBtn.Text = ""
			DBtn.Parent = DropFrame

			local SearchH    = DropShowSearch and 28 or 0
			local MaxH       = SearchH + math.min(#DropOptions, MaxVisible) * ItemHeight + 6
			local DropPopup  = Instance.new("Frame")
			DropPopup.Name   = "DropPopup"
			DropPopup.Size   = UDim2.new(1, 0, 0, MaxH)
			DropPopup.Position = UDim2.new(0, 0, 0, 38)
			DropPopup.BackgroundColor3 = T.ElementBg
			DropPopup.ClipsDescendants = true
			DropPopup.Visible = false
			DropPopup.ZIndex  = 20
			DropPopup.Parent  = DropFrame

			local DPopCorner = Instance.new("UICorner")
			DPopCorner.CornerRadius = UDim.new(0, 6)
			DPopCorner.Parent = DropPopup

			local FilterQuery = ""

			local DropSearchBox
			if DropShowSearch then
				local DSearchFrame = Instance.new("Frame")
				DSearchFrame.Size = UDim2.new(1, -10, 0, 22)
				DSearchFrame.Position = UDim2.new(0, 5, 0, 3)
				DSearchFrame.BackgroundColor3 = T.SearchBarBg
				DSearchFrame.BorderSizePixel = 0
				DSearchFrame.ZIndex = 21
				DSearchFrame.Parent = DropPopup

				local DSFCorner = Instance.new("UICorner")
				DSFCorner.CornerRadius = UDim.new(0, 5)
				DSFCorner.Parent = DSearchFrame

				local DSearchIcon = Instance.new("ImageLabel")
				DSearchIcon.Size = UDim2.new(0, 12, 0, 12)
				DSearchIcon.Position = UDim2.new(0, 5, 0.5, -6)
				DSearchIcon.BackgroundTransparency = 1
				DSearchIcon.Image = "rbxassetid://118685771787843"
				DSearchIcon.ImageColor3 = T.SecondaryText
				DSearchIcon.ZIndex = 22
				DSearchIcon.Parent = DSearchFrame

				DropSearchBox = Instance.new("TextBox")
				DropSearchBox.Size = UDim2.new(1, -22, 1, 0)
				DropSearchBox.Position = UDim2.new(0, 20, 0, 0)
				DropSearchBox.BackgroundTransparency = 1
				DropSearchBox.PlaceholderText = "Search content..."
				DropSearchBox.Text = ""
				DropSearchBox.TextColor3 = T.PrimaryText
				DropSearchBox.PlaceholderColor3 = T.SecondaryText
				DropSearchBox.TextSize = 11
				DropSearchBox.Font = Enum.Font.Gotham
				DropSearchBox.TextXAlignment = Enum.TextXAlignment.Left
				DropSearchBox.ClearTextOnFocus = false
				DropSearchBox.ZIndex = 22
				DropSearchBox.Parent = DSearchFrame
			end

			local ListFrame = Instance.new("ScrollingFrame")
			ListFrame.Size = UDim2.new(1, 0, 1, -SearchH)
			ListFrame.Position = UDim2.new(0, 0, 0, SearchH)
			ListFrame.BackgroundTransparency = 1
			ListFrame.ScrollBarThickness = 2
			ListFrame.BorderSizePixel = 0
			ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			ListFrame.ZIndex = 21
			ListFrame.Parent = DropPopup

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Parent = ListFrame

			local ListPad = Instance.new("UIPadding")
			ListPad.PaddingLeft   = UDim.new(0, 4)
			ListPad.PaddingRight  = UDim.new(0, 4)
			ListPad.PaddingTop    = UDim.new(0, 3)
			ListPad.PaddingBottom = UDim.new(0, 3)
			ListPad.Parent = ListFrame

			local ItemButtons = {}

			local function BuildItems()
				for _, child in ipairs(ListFrame:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				ItemButtons = {}

				for _, optionText in ipairs(DropOptions) do
					local lq = FilterQuery:lower()
					if lq ~= "" and not optionText:lower():find(lq, 1, true) then
						continue
					end

					local ItemBtn = Instance.new("TextButton")
					ItemBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
					ItemBtn.BackgroundColor3 = T.TabInactive
					ItemBtn.BorderSizePixel = 0
					ItemBtn.Text = ""
					ItemBtn.ZIndex = 22
					ItemBtn.Parent = ListFrame

					local IBCorner = Instance.new("UICorner")
					IBCorner.CornerRadius = UDim.new(0, 5)
					IBCorner.Parent = ItemBtn

					local IBLabel = Instance.new("TextLabel")
					IBLabel.Size = UDim2.new(1, -34, 1, 0)
					IBLabel.Position = UDim2.new(0, 8, 0, 0)
					IBLabel.BackgroundTransparency = 1
					IBLabel.Text = optionText
					IBLabel.TextColor3 = optionText == Selected and T.AccentColor or T.PrimaryText
					IBLabel.TextSize = 12
					IBLabel.Font = Enum.Font.Gotham
					IBLabel.TextXAlignment = Enum.TextXAlignment.Left
					IBLabel.TextWrapped = true
					IBLabel.ZIndex = 23
					IBLabel.Parent = ItemBtn

					local IBIcon = Instance.new("ImageLabel")
					IBIcon.Size = UDim2.new(0, 14, 0, 14)
					IBIcon.Position = UDim2.new(1, -20, 0.5, -7)
					IBIcon.BackgroundTransparency = 1
					IBIcon.Image = "rbxassetid://9728118892"
					IBIcon.ImageColor3 = optionText == Selected and T.AccentColor or T.SecondaryText
					IBIcon.ZIndex = 23
					IBIcon.Parent = ItemBtn

					ItemBtn.MouseButton1Click:Connect(function()
						Selected = optionText
						DSelectedTxt.Text = optionText
						DSelectedTxt.TextColor3 = T.PrimaryText
						IsOpen = false
						DropPopup.Visible = false
						TweenService:Create(DChevron, TweenInfo.new(0.15), {Rotation = 0}):Play()
						BuildItems()
						Callback(optionText)
					end)

					table.insert(ItemButtons, {Btn = ItemBtn, Label = IBLabel, Icon = IBIcon})
				end
			end

			BuildItems()

			if DropShowSearch and DropSearchBox then
				DropSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
					FilterQuery = DropSearchBox.Text
					BuildItems()
				end)
			end

			DBtn.MouseButton1Click:Connect(function()
				IsOpen = not IsOpen
				DropPopup.Visible = IsOpen
				TweenService:Create(DChevron, TweenInfo.new(0.15), {Rotation = IsOpen and 180 or 0}):Play()
				if IsOpen and DropShowSearch and DropSearchBox then
					DropSearchBox.Text = ""
					FilterQuery = ""
					BuildItems()
				end
			end)

			Reg(DropFrame, DropLabel)
		end

		return TabHandling
	end

	return WindowHandling
end

return LuaLandLibrary
