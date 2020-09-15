-- title:  Tic-Pong
-- author: PistachoDuck
-- desc:   Classic Pong
-- script: lua
-- Build Version
Version = 1.1
-- Tamaño de la pantalla
Scn_size = { x = 240, y = 136 }

-- Posiciones iniciales
P1_ini_pos      = { x = 10, y = Scn_size.y/2 }
P2_ini_pos      = { x = 230, y = Scn_size.y/2 }
Ball_ini_pos    = { x = Scn_size.x/2-2, y = Scn_size.y/2}

-- Declaracion del jugador 1 y 2
P1_racket   = {
    position    = { x = 0, y = 0 },
    size        = { anchura = 3, altura = 16 },
    baseSprite  = 1,
    color       = 12,
    active      = false
}

P2_racket   = {
    position    = { x = 0, y = 0 },
    size        = { anchura = 3, altura = 16 },
    baseSprite  = 1,
    color       = 1,
    active      = false
}

-- Declaracion de la bola
Ball        = {
    position    = { x = 0, y = 0 },
    size        = { anchura = 8, altura = 8 },
    baseSprite  = 2,
    color       = 0,
    offset      = 1,
    active      = false,
    direction		= {x = 1,y = 1},
    AnimFrame		= 2,
    AnimCounter = 0,
    Timer				= 0,
    AnimVelocity= 10
}

-- Score Variables

P1_score = 0
P2_score = 0

Score_Position_Buffer = 30
Score_Size = 3
Score_Color = 2

MaxScore = 5

-- Variables de la cancha

Court_Points = {
	UpLeft 	= {x=0,y=0},
	Up			= {x=Scn_size.x/2,y=0},
	UpRight	= {x=Scn_size.x,y=0},
	DownLeft= {x=0,y=Scn_size.y},
	Down		= {x=Scn_size.x/2,y=Scn_size.y},
	DownRight={x=Scn_size.x,y=Scn_size.y},
	color	= 2
}

-- Declaracion de variables de jugadores
RacketVelocity  = 1.5
BallVelocity    = { x = 1, y = 1, Maxima=3.5,Minima=1}
-- Variables del editor de Sprites
Tile_Size       = 8
Tile_Row_Size   = 16

-- Variable Inicializadora
Game_Initialised = false

-- Variables de estado
StatePlayTIC 			= 0
StateEndGame			= 1
StatePlayerScored	= 2
StateTitleScreen	= 3
StateLogoScreen		= 4

GameState = StateLogoScreen
-- Timer Global
Timer = 0
-- --------------------------------------------------------------------

function TIC()		
		if ( GameState == 0 ) then
			statPlayTIC()
		elseif ( GameState == 1 ) then
			statEndGameTIC()
		elseif ( GameState == 2) then
			statPlayerScored()
		elseif ( GameState == 3) then
			statTitleScreen()
		elseif ( GameState == 4) then
			statLogoScreen()
		end
end

function statLogoScreen()
	cls()
	Timer = Timer + 1
	
	if ( Timer < 180) then
		spr(
			256,
			160,
			70,
			0,
			1,
			false,
			false,
			9,
			7
		)
	else
		Timer = 0
		GameState = StateTitleScreen
	end
end
function statPressZ()
	
	cls()
	print("Presiona Tecla 'Z' o el boton 'A'",20,Scn_size.y/2,2,0,1)
	if ( btnp(4) or btnp(12)) then 
		GameState = StateTitleScreen
	end
end
function statTitleScreen()
	music()
	cls()
	print("|TIC - PONG|",15,30,2,0,3)
	print("Presiona 'Z' o Boton 'A' para empezar.",20,50)
	print("<- Jugador 1",20,Scn_size.y/2+5)
	print("Jugador 2 ->",Scn_size.x-90,Scn_size.y/2+5)
	
	print("Por:PistachoDuck",5,130,14,0,1)
	print("Ver."..Version,190,130,14,0,1)
	Ball.AnimVelocity = 5
	InitBall()
	InitPlayers()
	DrawBall()
	DrawP1()
	DrawP2()
	if ( btnp(4) or btnp(12)) then
		Game_Initialised = false
		GameState = StatePlayTIC
	end
end

function statEndGameTIC()
	cls()
	
	if ( P1_score > P2_score) then
		print("Jugador 1 Gana!!!",20,40,2,0,2)
	else
		print("Jugador 2 Gana!!!",20,40,2,0,2)
	end
	print("Tecla 'Z' o Boton 'A' -> Reiniciar",10,100,2)
	print("Tecla 'X' o Boton 'B' -> Pantalla de Titulo",10,110,2)
	
	if ( btnp(4) or btnp(12)) then
		Game_Initialised = false
		GameState = StatePlayTIC
	elseif ( btnp(5) or btnp(13)) then
		Game_Initialised = false
		GameState = StateTitleScreen
	end
end

function statPlayerScored()
		cls()
		Timer = Timer + 1
		
		if ( Timer < 120 ) then		
			
			print("PUNTO!!!!",80,100,2,0,2)
			DrawCourtYard()
			DrawP1()
			DrawP2()
			DrawScore()
			-- UPDATE
			P1Movement()
			P2Movement()
		else
			Timer = 0
			music()
			GameState = StatePlayTIC
		end
		-- RENDER
		
end

function statPlayTIC()
    if ( Game_Initialised == false ) then
        Ball.AnimVelocity = 1
        InitGame()
    else
        cls()
        -- UPDATE
        P1Movement()
        P2Movement()
        BallMovement()
        ScoreManager()

        -- RENDER
        DrawP1()
        DrawP2()
        DrawBall()
        --DrawCollisions()
        DrawScore()
        DrawCourtYard()
    end
end

function DrawCourtYard()
local court = Court_Points
	--TABLERO 1
		-- Linea Izquierda
		line(court.UpLeft.x,court.UpLeft.y,court.DownLeft.x,court.DownLeft.y,court.color)
		-- Linea Central
		line(court.Up.x,court.Up.y,court.Down.x,court.Down.y,court.color)
		-- Linea Derecha
		line(court.UpRight.x-1,court.UpRight.y-1,court.DownRight.x-1,court.DownRight.y-1,court.color)
		-- Linea Abajo
		line(court.DownRight.x,court.DownRight.y-1,court.DownLeft.x,court.DownLeft.y-1,court.color)
		--Linea Arriba
		line(court.UpRight.x,court.UpRight.y,court.UpLeft.x,court.UpLeft.y,court.color)
		--Circulo Central
		circb(Scn_size.x/2,Scn_size.y/2,10,2)
	-- TABLERO 2
		rectb(court.UpLeft.x+2,court.UpLeft.y+2,Scn_size.x-4,Scn_size.y-4,court.color)
end
function DrawCollisions()
		--DrawP1Collisions()
		rectb(P1_racket.position.x,P1_racket.position.y,P1_racket.size.anchura,P1_racket.size.altura,5)
		--DrawP2Collisions()
		rectb(P2_racket.position.x,P2_racket.position.y,P2_racket.size.anchura,P2_racket.size.altura,5)
		--DrawBallCollisions()
		rectb(Ball.position.x,Ball.position.y,Ball.size.anchura,Ball.size.altura,3)
end
function DrawScore()
		print(P1_score,(Scn_size.x/2)-Score_Position_Buffer-10,20,Score_Color,0,Score_Size)
		print(P2_score,(Scn_size.x/2)+Score_Position_Buffer,20,Score_Color,0,Score_Size)
end

function P1Movement()

		P1_racket.position.y = CheckLimits(P1_racket.position.y,0,Scn_size.y - P1_racket.size.altura)
		
    -- Movimiento del jugador 1
    if (btn(0)) then
        P1_racket.position.y    = P1_racket.position.y - RacketVelocity
    elseif btn(1) then
        P1_racket.position.y    = P1_racket.position.y + RacketVelocity
    end
end

function P2Movement()

		P2_racket.position.y = CheckLimits(P2_racket.position.y,0,Scn_size.y - P2_racket.size.altura)
    
    --Movimiento del jugador 2
    if (btn(8)) then
        P2_racket.position.y    = P2_racket.position.y - RacketVelocity
    elseif btn(9) then
        P2_racket.position.y    = P2_racket.position.y + RacketVelocity
    end
end

function DrawP1()
    -- Dibujamos la raqueta completa
    spr(
        P1_racket.baseSprite,
        P1_racket.position.x,
        P1_racket.position.y,
        P1_racket.colors
    )
    spr(
        P1_racket.baseSprite + Tile_Row_Size,
        P1_racket.position.x,
        P1_racket.position.y + Tile_Size,
        P1_racket.colors
    )
end

function DrawP2()
    -- Dibujamos la raqueta completa
    spr(
        P2_racket.baseSprite,
        P2_racket.position.x,
        P2_racket.position.y,
        P2_racket.colors
    )
    spr(
        P2_racket.baseSprite + Tile_Row_Size,
        P2_racket.position.x,
        P2_racket.position.y + Tile_Size,
        P2_racket.colors
    )
end

function DrawBall()
    -- Dibujamos la bola en las coordenadas correspondientes
    spr(
        Ball.baseSprite + Ball.AnimCounter,
        Ball.position.x,
        Ball.position.y,
        Ball.color
    )
    
    --Ball.AnimCounter 	= Ball.AnimCounter + 1
    --Ball.AnimCounter	= Ball.AnimCounter % Ball.AnimFrame
    
    Ball.Timer = Ball.Timer + 1
    
    if ( Ball.Timer > Ball.AnimVelocity ) then
			Ball.AnimCounter = Ball.AnimCounter + 1
			Ball.Timer = 0
    end
    Ball.AnimCounter = Ball.AnimCounter % Ball.AnimFrame
end

function ScoreManager()

		if ( P1_score >= MaxScore or P2_score >= MaxScore) then
			music(0,0,-1,false,false)
			GameState = StateEndGame
		else
		-- Si la bola revasa el jugador de la izquierda
		-- Que cambiemos al estado de "ScorePlayer"
			if ( Ball.position.x < 0 ) then
				P2_score = P2_score + 1
				music(1,0,-1,true,false)
				BallVelocity.x = BallVelocity.Minima
				Ball.position.x = Ball_ini_pos.x
				GameState = StatePlayerScored
				
			-- Si la bola revasa el jugador de la derecha
			-- Que cambiemos al estado de "ScorePlayer"
			elseif ( Ball.position.x > Scn_size.x ) then
				P1_score = P1_score + 1
				BallVelocity.x = BallVelocity.Minima
				Ball.position.x = Ball_ini_pos.x
				music(1,0,-1,true,false)
				GameState = StatePlayerScored
			end
		end
end

function BallMovement()
		-- Declaramos
		BallVelocity.x = CheckLimits(BallVelocity.x,BallVelocity.Minima,BallVelocity.Maxima)
		--print(BallVelocity.y,10,10)
		
    -- Que la bola se mueva en X direccion
    Ball.position.x = Ball.position.x + BallVelocity.x * Ball.direction.x
    Ball.position.y = Ball.position.y + BallVelocity.y * Ball.direction.y

    -- Si la posicion de la bola es mayor a la del techo o piso, que se haga contraria (Coordenada Y)
    if ( Ball.position.y < 0 or (Ball.position.y+Ball.size.altura) > Scn_size.y) then
        Ball.direction.y = Ball.direction.y * -1
        sfx(0,1,15,1,100,5)
		end
		-- Si la bola se sale de la cancha en X
		-- Que regrese a la posicion inicial.
    
    
    local ballCollided = false
    --Si la bola toca a algun jugador que de la señal "Colisiono"
    if ( CheckCollision(Ball,P1_racket) or CheckCollision(Ball,P2_racket)) then
			ballCollided = true
		else
			ballCollided = false
    end
    -- Si la bola colisiona que se invierta la direccion en X
    if ( ballCollided == true ) then
			Ball.direction.x 	= Ball.direction.x * -1
			BallVelocity.x		= BallVelocity.x + 0.1
			sfx(0,30,15,0,100,5)
    end
end
function InitGame()
    InitPlayers()
    InitBall()
    InitScore()
    Game_Initialised = true
end

function InitScore()
	P1_score = 0
	P2_score = 0
end

function InitPlayers()
    P1_racket.position = P1_ini_pos
    P2_racket.position = P2_ini_pos
end

function InitBall()
		Ball.position.x = Ball_ini_pos.x
		Ball.position.y = Ball_ini_pos.y
end
function CheckCollision(object1, object2)
		local object1Left 	= object1.position.x
		local object1Right	= object1.position.x + object1.size.anchura
		local object1Top		= object1.position.y
		local object1Down		= object1.position.y + object1.size.altura
		
		local object2Left 	= object2.position.x
		local object2Right	= object2.position.x + object2.size.anchura
		local object2Top		= object2.position.y
		local object2Down		= object2.position.y + object2.size.altura
		
		if ( object1Left 	< object2Right ) and
			( object1Right 	> object2Left ) and
			( object1Top 		< object2Down ) and
			( object1Down 	> object2Top) then
			return true
		else 
			return false
			
		end
end

function CheckLimits(valor,minimo,maximo)
		if ( valor > maximo ) then
			valor = maximo
		elseif ( valor < minimo ) then
			valor = minimo
		else
			valor = valor
		end
		
		return valor
end

-- <TILES>
-- 001:0200000020200000202000002220000020200000222000002220000022200000
-- 002:0000000000222200020220200220022002200220020220200022220000000000
-- 003:0000000000202200022022200220000000000220022202200022020000000000
-- 017:2220000022200000222000002020000022200000202000002020000002000000
-- </TILES>

-- <SPRITES>
-- 002:0000000000000000000000000000000000000000000000000000000000000011
-- 003:0000000000000000000000000000000000000000000000001111111022222222
-- 018:000001220000122200012222001222220122222201223e5500123e5500163e55
-- 019:22222262222262222222222222262222552222225555522255ee555255ee5552
-- 020:2000000022000000221000002221100022222100222221002262210022661100
-- 034:0016375500163555001663550001663300001666000001440000014400000144
-- 035:55ee552255775522555555223355362266333021433334414033344400004444
-- 036:2211000022100000110000001000000000000000000000001000000041000000
-- 048:0000000000000000000000000000000000000000000000000100010000000000
-- 050:0000014000000140000001400000014400000144000000140000000100000001
-- 051:0f0f0444f00f0444f0000444000004440f0f04440f0004440000044100000410
-- 052:4100000041000000410000001000000010000000100000000000000000000000
-- 055:0000000000000000000000000000000000000000000000000000000000000011
-- 056:0000000000000000000000000000000010000000100000001000000011000000
-- 064:0000101000000000001000000000000000000000000000000000000000000000
-- 065:1110111100000000000001110000011100000111000001110000011000000110
-- 066:1111111100000000100100001101100010011000000110000001100000011110
-- 067:1111111100000001011110010111100101111001011110010111100101001001
-- 068:1111111110000000101111111000110010001100100011001000110010001100
-- 069:1111111100000000010000100111001001111010011111100110111001100110
-- 070:1111111100000000100111011001110110011101111111011111110111111101
-- 071:1111111100000000111001001111110011111100110101001101010011000100
-- 072:1111110011110000011000000110000000100000000000000000000000000000
-- 081:0000011000000000111001011111110111111101110101011101010111000101
-- 082:0001111100000000111101111100011111000111111001111100011111000111
-- 083:010010010000000011110111111101e1010101e1010101e10101017100010111
-- 084:101111110000000011011110e1011111e1011111e10111107101111011010011
-- 085:0110001000000000011111100111111000111100000110000001100000011000
-- 086:1111110100000000111110011110001111100011111100001110000011100011
-- 087:1100010000000000111100001111000010000000110000000110000011110000
-- 088:0000000000000000000000000000000000000000000000000000000002000000
-- 096:0000200000000000000202020200000000002000000000000000000000000000
-- 097:1100010100000000222222220000000000000000000000000000000000000000
-- 098:1111011100000000222222220000000000000000000000000000000000000000
-- 099:0001011100000000222222220000000000000000000000000000000000000000
-- 100:1101001100000000222222220000000000000000000000000000000000000000
-- 101:0011110000000000222222220000000000000000000000000000000000000000
-- 102:1111101100000000222222220000000000000000000000000000000000000000
-- 103:1110000000000022222222220000222200000022000000200000002000000000
-- 104:2200000022000000222222002000000000000000000000000000000000000000
-- </SPRITES>

-- <WAVES>
-- 000:fecba9876543210fedcba98766542210
-- </WAVES>

-- <SFX>
-- 000:000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007400000000000
-- </SFX>

-- <PATTERNS>
-- 000:60000c10000000000060000c10000000000060100c00000000000040120c000000000000000000000000000000000000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000100000
-- 001:d8810a000000100000d8810a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:58810a00000010000058810a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:88810a00000010000088810a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:b5510845510a85510ab5510a00000085510ab5510a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:42210ab2210ab2210a42210a000000b2210a42210a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:2c04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004603ef
-- 001:5810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008d0300
-- </TRACKS>

-- <PALETTE>
-- 000:00000000f6ffeaeaee9159c671b28da191babec2c248e6b63c85d6008900005900f2d2c200beaa0085000038443c7169
-- </PALETTE>

