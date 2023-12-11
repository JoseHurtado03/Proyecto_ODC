.macro ColorearPixel(%x, %y) #¨Para colorear muros
	move $t0, $t1
	mul $t0, $t0, 4
	sw %x display($t0) #Pinta el color $s5 (azul) en el pixel de posición $t1
	addi $t1, $t1, 1 #Va al siguiente pixel
	li $t0, 0
	li $s0 0x0E0906
	j %y
.end_macro 


.macro MoverPixel          #Funciona para mover el pixel del personaje
	li $s1, 3
	sb $s1, Map1($t6)  #Cambia el valor de sector de la matriz
	lb $t2, Map1($t4)  
	beq $t2, 5, MoverPc
	li $s1, 0
	sb $s1, Map1($t4)
MoverPc:
	move $t4, $t6     #Actualiza la posición del personaje en el registro.
	li $s1, 0
	li $t2, 0
.end_macro 

.macro ReiniciarRegistros
	li $t1, 0
	li $t0, 0
	li $t3, 0
	jr $ra
.end_macro 


.macro MoverEnemigo(%x)
	move $t6, $t5
	addi $t6 $t6, %x  
	
	lb $t2, Map1($t6)
	beq $t2, 4, cmEnemigo #Si el enemigo encuentra la salida no se la come
	beq $t2, 5, cmEnemigo #si es otro enemigo en la matriz elije otro movimiento
	beq $t2, 6, cmEnemigo #Verifica que si hay una moneda el enemigo no se mueva
	beq $t2, 8, cmEnemigo #Si es un teletransporte no se mueve
	beq $t2, 9, cmEnemigo #Si es un teletransporte no se mueve
	beq $t2, 7, cmEnemigo #Si es una zona de teletransporte no se mueve
	
	mul $t6, $t6, 4   
	lw $s1, display($t6)
	beq $s1, $s5, mover    #Si es pared, no se mueve
	beq $s1, $t7 cmEnemigo #si es otro enemigo elije otro movimiento
	beq $s1, $t9 ZonaMuerte
	div $t6, $t6, 4
	
	li $t2, 5
	sb $t2, Map1($t6)
	li $t2, 0
	sb $t2, Map1($t5)
	move $t2, $t5
	mul $t2, $t2, 4
	move $t1, $t6
	j cmEnemigo
.end_macro 

.macro MoverPersonaje(%x, %y)
	move $t6 $t4          #$t4 es la posición actual y se guardará en $t6
	addi $t6 $t6 %x       #Le sumas a $t6 el valor del desplazamiento (A, W, S, D) y queda allí...
			      #...el valor a donde se quiere mover
	lb $t2, Map1($t6)     #Carga en $t2 la posición a la que el usuario se quiere mover
	beq $t2, 5, GameOver  #Si llega a 5 (Rojo) toca a un enemigo y es GameOver
	beq $t2 6 scoreD      #Si llega a 6 (Amarillo) toca una moneda y va a sumar 10 a un contador
	beq $t2 4 youWin      #Si llega a 4 (Morado), YouWin
	beq $t2 9, teleport_1 #Si llega a 9 (Verde), usa el teletransportador
	beq $t2 8, teleport_2 #Si llega a 8 (Verde), usa el teletransportador
	
%y:	mul $t6, $t6 4        #Cambia la posici[on en el display, para eso, hay que multiplicar 4 porque el display...
	lw $s1 display($t6)   #funciona con .word, mientras que Map1, es implementado con .byte
	beq $s1, $s5 Stay     #Si es pared, no se mueve
	div $t6, $t6 4        #Se divide entre 4 para tener el valor necesario para mover en Map1.
	MoverPixel
	j Update
.end_macro 
		
.data
display: .space  1024
#Se reservan 1024 espacios puesto que son 256 palabras 
#La pantalla es de 512*512 y los pixels son de tamaño 32
##512/32 = 16. Te queda una ventana de 16*16 pixeles
#Para los colores se reserva cada uno en palabra

Map1:	.byte  	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,		# Reserva de espacio para matriz1 de 16*16
		1,0,0,0,0,0,0,0,0,0,5,0,0,1,0,1,		#Los pixels se guardan por palabras (.word)
   	      	1,0,7,1,0,0,1,1,1,1,1,0,0,0,0,1,		#Donde cada palabra representa un componente de la matriz
   	      	1,0,8,1,0,0,0,0,0,0,0,0,0,1,0,1,		# 0 --> vacio, sin colorear (Negro por defecto)
   	      	1,0,1,1,1,0,0,1,1,1,1,1,1,1,0,1,		# 1 --> pardes, muros, (azul)
   	      	1,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,		# 3 --> personaje (blanco)
   	      	1,0,0,1,0,0,0,1,0,1,1,1,1,1,0,1,		# 4 --> salida/terminar nivel (morado)
   	      	1,0,0,1,0,5,0,1,0,1,0,0,0,1,0,1,		# 5 --> enemigos (rojo)
   	      	1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,1,		# 6 --> monedas (amarillo)
   	      	1,0,0,1,1,1,1,1,0,0,0,5,0,0,0,1,         # 8 --> Teletransportador2 (verde)
   	      	1,0,0,0,0,0,1,0,0,1,0,0,1,1,0,1,         # 9 --> Teletransportador1 (verde)
   	      	1,0,0,1,0,0,1,0,1,1,1,0,1,0,0,1,
   	      	1,0,0,0,0,0,1,0,0,0,1,0,1,1,1,1,
   	      	1,0,0,5,1,1,1,1,1,1,1,0,0,7,9,1,
   	      	1,0,0,0,0,0,0,0,0,0,1,3,0,0,0,1,
   	      	1,1,1,1,1,1,1,1,1,4,1,1,1,1,1,1
   	      	
Pos: .space 256   #NO ELIMINAR

Dead: .byte 	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,		# Reserva de espacio para matriz1 de 16*16
		1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,		#Los pixels se guardan por palabras (.word)
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,		#Donde cada palabra representa un componente de la matriz
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,		# 0 --> vacio, sin colorear (Negro por defecto)
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,		# 1 --> pardes, muros, (azul)
   	      	1,4,4,0,0,4,4,0,0,4,0,0,4,4,0,1,		# 3 --> personaje (blanco)
   	      	1,4,0,4,0,4,0,0,4,0,4,0,4,0,4,1,		# 4 --> salida/terminar nivel (morado)
   	      	1,4,0,4,0,4,0,0,4,0,4,0,4,0,4,1,		# 5 --> enemigos (rojo)
   	      	1,4,0,4,0,4,4,0,4,0,4,0,4,0,4,1,		# 6 --> monedas (amarillo)
   	      	1,4,0,4,0,4,0,0,4,4,4,0,4,0,4,1,
   	      	1,4,4,0,0,4,4,0,4,0,4,0,4,4,0,1,
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   	      	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
   	      	
Win: .byte 	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,	# Reserva de espacio para matriz1 de 16*16
		1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,	#Los pixels se guardan por palabras (.word)
   	      	1,0,6,0,6,0,0,6,6,0,0,6,0,6,0,1,	#Donde cada palabra representa un componente de la matriz
   	      	1,0,6,0,6,0,6,0,0,6,0,6,0,6,0,1,	# 0 --> vacio, sin colorear (Negro por defecto)
   	      	1,0,6,0,6,0,6,0,0,6,0,6,0,6,0,1,	# 1 --> pardes, muros, (azul)
   	      	1,0,0,6,0,0,6,0,0,6,0,6,0,6,0,1,	# 3 --> personaje (blanco)
   	      	1,0,0,6,0,0,0,6,6,0,0,6,6,6,0,1,	# 4 --> salida/terminar nivel (morado)
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,	# 5 --> enemigos (rojo)
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,	# 6 --> monedas (amarillo)
   	      	1,0,6,0,6,0,6,0,6,0,6,0,0,6,0,1,
   	      	1,0,6,0,6,0,6,0,6,0,6,0,0,6,0,1,
   	      	1,0,6,0,6,0,6,0,6,0,6,6,0,6,0,1,
   	      	1,0,6,0,6,0,6,0,6,0,6,0,6,6,0,1,
   	      	1,0,0,6,6,6,0,0,6,0,6,0,0,6,0,1,
   	      	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   	      	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


msg: 	.asciiz "\n¡DEAD! TE HAN ELIMINADO. EL JUEGO HA TERMINADO."
msgW:	.asciiz "\n ¡¡¡FELICIDADES!!! HAZ GANADO."
ansD:	.asciiz "La puntuación en decimal es: "
ansH:	.asciiz "La puntuación en hexadecimal es: "
ansO:	.asciiz "La puntuación en octal es: "
ansB:	.asciiz "La puntuación en binario es: "
jump:	.asciiz "\n"
numH:	.space 9  #Caben 8 dígitos hexadecimales en MIPS R2000 + 1 bit de borrado
numO:	.space 11 #Caben 10 dígitos octales en MIPS R2000      + 1 bit de borrado
	
.text 
li $s0 0x0E0906 #Pintar el display de casi negro (Fondo)
li $s5 0x338DFF #Pintar el display de azul       (Muros)
li $s4 0xFFFF00 #Pintar el display de amarillo   (Monedas)
li $t9 0xFFFFFF #Pintar el display de blanco     (Personaje)
li $t8 0x572364 #Pintar la salida
li $t7 0xd32031 #Pintar enemigos de rojo 

li $t0, 0
li $t1, 0 #Indice de la matriz
li $t3, 0 #Se guarda el valor del indice de la matriz
li $s2, -1

Main:
	li $t0, 0
 	li $t4, 211	#No eliminar ninguna de las siguientes filas hasta el jal, por alguna razon no sirve si se elimina  
	sb $t4, Pos+0  
	li $t4, 117
	sb $t4, Pos+1
	li $t4, 155
	sb $t4, Pos+2
	li $t4, 26
	sb $t4, Pos+3
	
	jal PutMoneda #Coloca un 6 (moneda) con un 7% de probabilidad#
 	jal PintaNivel
	li $t4, 235
 	j Update
	
Update:
	li $t0, 0
	li $t1, 0
	beq $s2, $t4, GameOver #Lugar donde ocurrirá la colisión
	beq $s3, $t4, GameOver #Lugar en la matriz donde estaba el enemigo que originó la colisión
	li $s2, -1
	jal PintaNivel
	jal chooseenemys
	li $v0, 12 #Syscall para leer un char
	syscall
	
	beq $v0, 100, moveRight	# Si presiona "D" va a moveRight
	beq $v0, 97, moveLeft	# Si presiona "A" va a moveLeft
	beq $v0, 119, moveUp	# Si presiona "W" va a moveUp
	beq $v0, 115, moveDown	# Si presiona "S" va a moveDown
	
	j Update #Después de moverse, regresa de nuevo a Update

moveRight:
	MoverPersonaje(1, contR) #1= Derecha
	
moveLeft:
	MoverPersonaje(-1, contL) #-1= Izquierda

moveUp:
	MoverPersonaje(-16, contU) #-16= Arriba
	
moveDown:
	MoverPersonaje(16, contD) #16= Abajo

Stay:
	#jal PintaNivel
	j Update	

#Elementos para el coloreado de pixeles de niveles
PintarMuro:
	ColorearPixel($s5, PintaNivel)
	
PintarPersonaje: #Pinta el Personaje el cual se va a interactuar
	ColorearPixel($t9, PintaNivel)

PintarSalida: #Pinta la Salida donde debe ir el personaje
	ColorearPixel($t8, PintaNivel)
		
	
PintarEnemigo:
	ColorearPixel($t7, PintaNivel)
PintaFondo:
	ColorearPixel($s0, PintaNivel)
	
PintaTeleport1:
	li $s0 0x42FF33
	ColorearPixel($s0, PintaNivel)

PintaTeleport2:
	li $s0 0x42FF33
	ColorearPixel($s0, PintaNivel)
	
Moneda: #Poner las monedas en el juego, debe ser aleatoreo
	la $a0 0 #Minimo del random incluye el 0
	la $a1 16 # Maximo del random no incluye el 2
	li $v0, 42 #Coloca el numero random en $a0
	syscall
	beq $a0, 1, storeMoneda #Si el numero random es igual a 1 entonces se hace una moneda
	beq $a0, 7, storeMoneda
	#wbeq $a0, 13, storeMoneda
	#sb $t2, Map1($t1)
	addi $t1, $t1, 1
	
	j PutMoneda
storeMoneda:
	li $t2, 6
	sb $t2, Map1($t1)
	li $t2, 0
	addi $t1, $t1, 1
	j PutMoneda
	
PintarMoneda:	#Se activa la moneda, la posibilidad de que aparezca una moneda es del 50% 
	ColorearPixel($s4, PintaNivel)

PintaNivel:
	lb $t3, Map1($t1) #Guarda en $t3 el numero puesto en la matriz segun el indice $t1
	
	beq $t3, 1, PintarMuro #Si el numero de la matriz es 1 entonces entra al bucle
	beq $t3, 4, PintarSalida
	beq $t3, 5, PintarEnemigo 
	beq $t3, 6, PintarMoneda
	beq $t3, 3, PintarPersonaje
	beq $t3, 0, PintaFondo
	beq $t3, 8, PintaTeleport1
	beq $t3, 9, PintaTeleport2
	addi $t1, $t1, 1  #Como es un .word, debe ir sumando de 4 bits en 4 bits (1 palabra en 1 palabra)
	blt $t1, 256, PintaNivel #Si llega hasta la ultima iteracion que es 1024, entonces termina el nivel_1
	ReiniciarRegistros
	
PutMoneda:
	lb $t3, Map1($t1) #Guarda en $t3 el numero puesto en la matriz segun el indice $t1

	beq $t3, 0, Moneda
	addi $t1, $t1, 1  #Como es un .word, debe ir sumando de 4 bits en 4 bits (1 palabra en 1 palabra)
	blt $t1, 256, PutMoneda #Si llega hasta la ultima iteracion que es 1024, entonces termina el nivel_1
	ReiniciarRegistros
	
# Conjunto de literales para mover al enemigo	
chooseenemys: #Busca al enemigo, solo busca
	lb $t3, Map1($t1) #Guarda en $t3 el numero puesto en la matriz segun el indice $t1
	beq $t3, 5, mover 
	addi $t1, $t1, 1  #Como es un .word, debe ir sumando de 4 bits en 4 bits (1 palabra en 1 palabra)
	blt $t1, 256, chooseenemys #Si llega hasta la ultima iteracion que es 1024, entonces termina el nivel_1
	ReiniciarRegistros
mover:
	la $a0, 0
	la $a1, 5
	li $v0, 42
	syscall
	move $t5, $t1
	beq $a0, 0, moveEnemyUP
	beq $a0, 1, moveEnemyDown
	beq $a0, 2, moveEnemyRight
	beq $a0, 3, moveEnemyLeft
	beq $a0, 4, cmEnemigo

moveEnemyUP:
	MoverEnemigo(-16)
	
moveEnemyDown:
	MoverEnemigo(16)
	
moveEnemyRight:
	MoverEnemigo(1)
	
moveEnemyLeft:
	MoverEnemigo(-1)

cmEnemigo:
	addi $t1, $t1, 1
	j chooseenemys
	
GameOver:
	li $t2, 0
	sb $t2, Map1($t4) #para algunas muertes se tiene que directamente cambiar el valor del personaje en la matriz a 0 para que el personaje desaparezca al imprimir

	jal PintaNivel

	mul $s2, $s2, 4		#Esto hace lo mismo que el codigo que mencione unas lineas arriba
	sw $t7, display($s2) 	#Básicamente coloca el enemigo en el puesto de la colisión, en la matriz aparecerá como 0, por eso se imprime despues

	li $v0, 4
	la $a0, msg
	syscall
	li $t1, 0
	
	li $v0, 32	# syscall sleep para dar un chance de ver donde moriste antes de mostrar el Dead
	li $a0, 2000	#2s
	syscall
	
	jal PintaDead
	j transformaciones
finally1:	
	li $v0, 10
	syscall

ZonaMuerte:
	# si la proxima jugada del enemigo es donde esta el jugador caera en esta zona de muerte, si el jugador mantiene la posicion se morira
	div $t6, $t6, 4
	
	li $t2, 5
	sb $t2, Map1($t6)
	li $t2, 0
	#sb $t6, Pos($t2)
	sb $t2, Map1($t5)
	
	move $s2, $t6
	move $s3, $t5
	
	move $t1, $t6
	j cmEnemigo
	
PintaDead: #Codigo que usa la misma logica que pinta nivel para pintar las letras "Dead" cuando mueres
	lb $t3, Dead($t1) #Guarda en $t3 el numero puesto en la matriz segun el indice $t1
	
	beq $t3, 1, DeadMarco #Si el numero de la matriz es 1 entonces entra al bucle
	beq $t3, 4, DeadLetra
	beq $t3, 0, DeadFondo
	addi $t1, $t1, 1  #Como es un .word, debe ir sumando de 4 bits en 4 bits (1 palabra en 1 palabra)
	blt $t1, 256, PintaDead #Si llega hasta la ultima iteracion que es 1024, entonces termina el nivel_1
	ReiniciarRegistros
	

DeadFondo:
	ColorearPixel($s0, PintaDead)
DeadLetra:
	ColorearPixel($t8, PintaDead)

DeadMarco:
	ColorearPixel($s5, PintaDead)

scoreD: 
	addi $s6 $s6 10
	j contD

transformaciones:
	#TRANSFORMACIÓN HEXADECIMAL#
	li $t1 0  #Para apuntar a donde debe guardarse
	li $t7 28 #Para el shift. 28 porque va de 4 en 4
	li $t6 15 #0000...0000 1111
loop:	
	bge $t1 8 fin
	move $t2 $s6
	srlv $t2 $t2 $t7
	and $t2 $t2 $t6
	bgt $t2 9 alpha
	j numero
alpha:	
	addi $t2 $t2 55  #Si es una letra A-F, se suma 55 para llevarlo a su valor ASCII
	j finCasos
numero:	addi $t2 $t2 48  #Si es un número 0-9, se suma 48 para llevarlo a su valor ASCII 
	j finCasos
finCasos:
	sb $t2 numH($t1) #Carga en numH el valor en ASCII del dígito hexadecimal
	addi $t7 $t7 -4  #Resta 4 para moverse en la posición de los bits.
	addi $t1 $t1 1   #Suma uno para moverse en la posición de numH
	j loop
fin:	
	#PRIMERO MUESTRA LA PUNTUACIÓN EN DECIMAL
	#Imprimir mensaje ansD
	li $v0 4
	la $a0 jump 
	syscall
	li $v0 4
	la $a0 ansD 
	syscall
	#Imprime el número decimal
	li $v0 1
	move $a0 $s6
	syscall
	#Imprimir salto
	li $v0 4
	la $a0 jump 
	syscall
	#Imprimir mensaje ansH
	li $v0 4
	la $a0 ansH 
	syscall
	#Imprimir número hexadecimal
	li $v0 4
	la $a0 numH
	syscall
	#Imprimir salto
	li $v0 4
	la $a0 jump 
	syscall
	#TRANSFORMACIÓN A BINARIO#
	#Imprime ansB#
	li $v0 4
	la $a0 ansB
	syscall
	#Pasar a Binario
	li $t1 31
loop2:	bltz $t1 octal
	move $t2 $s6     #Creamos una copia de $s6
	srlv $t2 $t2 $t1 #Hacemos shift y and para verificar si el bit es 0 o 1
	and $t2 $t2 1
	#Imprimimos el 0 o 1
	li $v0 1
	move $a0 $t2
	syscall
	#Restamos 1 a $t1 para que se vaya movindo y evalúe todos los números
	addi $t1 $t1 -1
	j loop2
	#TRANSFORMACIÓN A OCTAL#
octal:	
	li $v0 4
	la $a0 jump 
	syscall
	li $t1 9     #Contador que va disminuyendo
	li $t2 8     #Base de la división en octal
	move $t3 $s6 #Copia de $s6 para no afectar el registro de la puntuación
	
loopO:	blt $t3 $t2 ansLO # (Si la copia de la puntuación es menor a 8)
	div $t3 $t2
	mfhi $t5 #Residuo
	mflo $t3 #Resultado
	sb $t5 numO($t1) #Va cargando el residuo en la posición correspondiente de numO
	addi $t1 $t1 -1  #Para el desplazamiento del contador
	j loopO
ansLO:	sb $t3 numO($t1) #En la última iteración, el cociente de la división para el número octal
	addi $t1 $t1 -1  #Para el desplazamiento del contador
zeros:	bltz $t1 finLO   #Si hace falta, rellena con 0 las posiciones de numO que no se llenaron.
	sb $zero numO($t1)
	addi $t1 $t1 -1  #Para el desplazamiento del contador
	j zeros
finLO:	#Imprime el ansO
	li $v0 4
	la $a0 ansO
	syscall
	#Imprime el número en octal
	li $t1 0
	li $v0 1
printO:	
	bgt $t1 9 finally1 #Va imprimiendo cada dígito del número octal
	lb $t2 numO($t1)
	move $a0 $t2
	syscall
	addi $t1 $t1 1
	j printO
	
youWin:	li $t2 0         
	sb $t2 Map1($t4)    #Se carga en $t2 la posición del jugador en el mapa
	jal PintaNivel      #Se pinta el nivel de nuevo (para mostrar que llegaste a la meta)
	li $v0 4            #Se imprime el mensaje msgW
	la $a0 msgW
	syscall
	addi $s6 $s6 100     # Se añaden 100ptos al contador de puntos como bonificación por haber llegado a la meta.
	li $v0 32	    # syscall sleep para dar tiempo antes de la pantalla de "YOU WIN"
	li $a0 1000         #1s
	syscall
	#Imprimir pantalla "YOU WIN"
	jal PintaWin
	j transformaciones #Va a transformar la puntuación en diferentes sistemas numéricos.

PintaWin:
	lb $t3 Win($t1)
	beq $t3, 0, WinFondo
	beq $t3, 1, WinMarco
	beq $t3, 6, WinLetra
	addi $t1, $t1, 1
	blt $t1, 256, PintaWin
	ReiniciarRegistros
	
WinFondo:
	ColorearPixel($s0, PintaWin)
	
WinLetra:
	ColorearPixel($s4, PintaWin)

WinMarco:
	ColorearPixel($s5, PintaWin)

teleport_1:
	li $t6 34
	MoverPixel
	j Update
	

teleport_2:
	li $t6 221
	MoverPixel
	j Update

	
 





