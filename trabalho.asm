.8086
.model	small
.stack	2048

dseg    segment para public 'data'
	msgFim	db	'Nome:','$'
	msgGrelha1	db	'1 - Nova','$'
	msgGrelha2	db	'2 - Editar','$'
	msgGrelha3  db  'Nome do ficheiro(Obg 3 carac):','$'
	nomeFichGrelha 	db 'duud.TXT',0
	tempFichGrelha	db '00000','.TXT',0
	msgJogar1 db '1- Criar grelha aleatoria','$'
	msgJogar2 db '2- Carregar grelha','$'
	grelha db 0
	contadorGrelha dw 0
	guardarWordGrelha dw 0
	num	 db 	60
	verCor	dw	?
	CalcX 	dw	?
	CalcY 	dw	?
	guardaCor db	?
	acumuladorX	db	1
	acumuladorY	db	1

	CalcPos 	dw	?
	mult	db	2
	posInicial	dw	?
	guardar dw ?
	explodiu db 0
	contagemLinhas db 1
	StringPontuacao db 'Pontua',135,198,'o:$'
	baixo1 db 0
	comb db 0
	
	contagemCarinhasC db 0
	contagemCarinhasT db 0
	stringTeste db 100 dup(?)
	strEspaco db ' '
	endLine1 db 13
	endLine2	db 10
	bufferString 	db 25
					db ?
					db 26 dup('$'),13,10
					
					
	contagemNumeros db 0
	jaEscreveu		db 0
    carLido db 0
	vetorPont db '0000','$'
	totalBytes	dw 0
 ; --- VARIAVEIS  FICHEIROS --------------------------------
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
	Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
	Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
	Fich         	db      'ABC1.TXT',0
	HandleFich      dw      0
	car_fich        db      ?
	
	FichOld        	db      'pont.TXT',0
	FichNovo         	db      'pont_novo.TXT',0
    HandleFichNovo     dw      0
	HandleFichOld     dw      0

 ; -------------------------------------------------------------

 	ultimo_num_aleat dw 0
	str_num db 5 dup(?),'$'
    linha		db	0	; Define o número da linha que está a ser desenhada
    nlinhas		db	0
	cor1		db 	0
	car1		db	' '	
 ; -----------------------------------------------------------------

 ; ---------Variaveis cursor.asm-------------------------------
	Car		db	32	; Guarda um caracter do Ecran 
	Cor		db	7	; Guarda os atributos de cor do caracter
	Car2		db	32	; Guarda um caracter do Ecran 
	Cor2		db	7	; Guarda os atributos de cor do caracter
	POSy		db	8	; a linha pode ir de [1 .. 25]
	POSx		db	30	; POSx pode ir [1..80]	
	POSya		db	5	; Posição anterior de y
	POSxa		db	10	; Posição anterior de x
;-----------------------------------------------------------------------

;----------VARIAVEIS TEMPO------------------
	STR12	 		DB 		"            "	; String para 12 digitos	
	Segundos		dw		0				; Vai guardar os segundos actuais
	Old_seg		dw		0				; Guarda os últimos segundos que foram lidos
	MostrarSegundos dw 10
	NUMDIG	db	0	; controla o numero de digitos do numero lido
	MAXDIG	db	4	; Constante que define o numero MAXIMO de digitos a ser aceite
;-------------------------------------------
;----------VARIAVEIS PONTUAÇÃO--------------	
	AcabouTempo db 0
	pont db '0'
	pont1 db '0'
	pont2 db '0'
	pont3 db '0'
	pontContagem db 0
;-------------------------------------------	
		
dseg    ends

cseg	segment para public 'code'
	assume  cs:cseg, ds:dseg

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
sem_tecla:
		cmp grelha,1
		je lul
		call Trata_Horas
		cmp AcabouTempo,1
		je	SAI_TECLA
lul:
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		goto_xy	POSx,POSy

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################
;********************************************************************************
;********************************************************************************
; Imprime o tempo e a data no monitor

Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		GOTO_XY	43,1
		mov dl,pont
		MOV AH,02H 
		INT 21H
		
		GOTO_XY	42,1
		mov dl,pont1
		MOV AH,02H 
		INT 21H
		GOTO_XY	41,1
		mov dl,pont2
		MOV AH,02H 
		INT 21H
		GOTO_XY	40,1
		mov dl,pont3
		MOV AH,02H 
		INT 21H
tempo:		
		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
 		
		dec		MostrarSegundos
		mov 	ax,MostrarSegundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY	10,1
		MOSTRA	STR12
		
		cmp MostrarSegundos,0
		jne fim_horas
		mov AcabouTempo,1
        
		
						
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP


;########################################################################

	
	
;-------------------Calcula numero aleatório(moodle)---------------------
CalcAleat proc near 

	sub	sp,2		; 
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	push	dx	
	mov	ax,[bp+4]
	mov	[bp+2],ax

	mov	ah,00h
	int	1ah

	add	dx,ultimo_num_aleat	; vai buscar o aleatório anterior
	add	cx,dx	
	mov	ax,65521
	push	dx
	mul	cx			
	pop	dx			 
	xchg	dl,dh
	add	dx,32749
	add	dx,ax

	mov	ultimo_num_aleat,dx	; guarda o novo numero aleatório  

	mov	[BP+4],dx		; o aleatório é passado por pilha

	pop	dx
	pop	cx
	pop	ax
	pop	bp
	ret
CalcAleat endp
;-------------------------------------------------------------------


;--------------APAGAR ECRA (MOODLE)--------------------------

apaga_ecran	proc
		xor	bx,bx
		mov	cx,25*80
		
apaga:		mov	byte ptr es:[bx],' '
		mov	byte ptr es:[bx+1],7
		inc	bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp


;--------------IMPRIMIR FICHEIRO (MOODLE)-----------------
Imp_Fich	PROC
        mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,Fich			; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir		; pode aconter erro a abrir o ficheiro 
        mov     HandleFich,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai

ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFich		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,car_fich		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
	jc	    erro_ler		; se carry é porque aconteceu um erro
	cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
	je	    fecha_ficheiro	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
	  mov	    dl,car_fich		; este é o caracter a enviar para o ecran
	  int	    21h				; imprime no ecran
	  jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai

        mov     ah,09h			; o ficheiro pode não fechar correctamente
        lea     dx,Erro_Close
        Int     21h
sai:	  RET
Imp_Fich	endp
;-----------------FIM IMPRIMIR FICHEIRO--------------------------------


;---------------Função Main--------------------------------------------

Main  proc
	mov	ax, dseg
	mov	ds,ax
	mov	ax,0B800h
	mov	es,ax

	
	
inicio:	
	;------MENU-----------
	mov grelha,0
	call	apaga_ecran
	goto_xy	1,1
	call	Imp_Fich
	goto_xy	2,22
	xor 	ax,ax
	mov		ah,01h 	;Interrupção de ler caracter
	int 	21h
	cmp		al,52 	;Compara o caracter lido com 4
	je		fim
	cmp		al,49
	je		jogar
	cmp     al,50	
	je 		verPont
	cmp 	al,51
	je 		editarGrelha
	
	jmp		inicio
	;------END_MENU-----------

	
;_---- VER PONTUAÇÕES------------------

verPont:
	call apaga_ecran
	goto_xy 0,2
		mov     ah,3dh			; vamos abrir ficheiro para leitura 
        mov     al,0			; tipo de ficheiro	
        lea     dx,FichNovo			; nome do ficheiro
        int     21h			; abre para leitura 
        jc      erro_abrir1		; pode aconter erro a abrir o ficheiro 
        mov     HandleFichNovo,ax		; ax devolve o Handle para o ficheiro 
        jmp     ler_ciclo		; depois de abero vamos ler o ficheiro 

erro_abrir1:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     esperarEscape

ler_ciclo:
        mov     ah,3fh			; indica que vai ser lido um ficheiro 
        mov     bx,HandleFichNovo		; bx deve conter o Handle do ficheiro previamente aberto 
        mov     cx,1			; numero de bytes a ler 
        lea     dx,carLido		; vai ler para o local de memoria apontado por dx (car_fich)
        int     21h				; faz efectivamente a leitura
		jc	    erro_ler		; se carry é porque aconteceu um erro
		cmp	    ax,0			;EOF?	verifica se já estamos no fim do ficheiro 
		je	    fecha_ficheiro1	; se EOF fecha o ficheiro 
        mov     ah,02h			; coloca o caracter no ecran
		mov	    dl,carLido		; este é o caracter a enviar para o ecran
		int	    21h				; imprime no ecran
		jmp	    ler_ciclo		; continua a ler o ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro1:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFichNovo
        int     21h
        jnc     esperarEscape
esperarEscape:
	goto_xy 3,23
	mov		ah,01h 	;Interrupção de ler caracter
	int 	21h
	cmp al,27
	jne verPont
	jmp inicio
;--------------------------------------
	
	
	
jogar:
	call apaga_ecran
	goto_xy 2,5
	MOV AH,09H
	LEA DX,msgJogar1
	INT 21H
	goto_xy 2,6
	MOV AH,09H
	LEA DX,msgJogar2
	INT 21H
	goto_xy	2,22
	xor 	ax,ax
	mov		ah,01h 	;Interrupção de ler caracter
	int 	21h
	cmp al,49
	je jogar1
	jmp jogar
jogar1:	
	call	apaga_ecran
	goto_xy	30,1
	MOV AH,09H
	LEA DX,StringPontuacao 
	INT 21H
	
	
	mov pont,'0'
	mov pont1,'0'
	mov pont2,'0'
	mov pont3,'0'
		
ciclo4:
		call	CalcAleat
		pop	ax 		; vai buscar 'a pilha o número aleatório

		mov	dl,cl	
		mov	dh,70
		
		mov   	ax, 0b800h	; Segmento de memória de vídeo onde vai ser desenhado o tabuleiro
		mov   	es, ax	
		mov	linha, 	8	; O Tabuleiro vai começar a ser desenhado na linha 8 
		mov	nlinhas, 6	; O Tabuleiro vai ter 6 linhas
		
ciclo2:		mov	al, 160		
		mov	ah, linha
		mul	ah
		add	ax, 60
		mov 	bx, ax		; Determina Endereço onde começa a "linha". bx = 160*linha + 60

		mov	cx, 9		; São 9 colunas 
cicl:  	
		mov 	dh,	car1	; vai imprimir o caracter "SPACE"
		mov	es:[bx],dh	;
novacor:	
		call	CalcAleat	; Calcula próximo aleatório que é colocado na pinha 
		pop	ax ; 		; Vai buscar 'a pilha o número aleatório
		cmp ah,30
		ja	sem_caracter
		mov dh,1
		jmp com_caracter
sem_caracter:
		cmp ah,240
		jb	semcaracter
		mov	dh,45
		jmp com_caracter
semcaracter:
		mov 	dh,' '	; vai imprimir o caracter "SPACE"
com_caracter:
		and 	al,01110000b	; posição do ecran com cor de fundo aleatório e caracter a preto

		cmp	al, 0		; Se o fundo de ecran é preto
		je	novacor		; vai buscar outra cor 
		and 	al,01111111b
		cmp	al, 0
		je	novacor		; vai buscar outra cor 

		
		mov	es:[bx],   dh		
		mov	es:[bx+1], al	; Coloca as características de cor da posição atual 
		inc	bx		
		inc	bx		; próxima posição e ecran dois bytes à frente

		mov	es:[bx+1], al
		inc	bx
		inc	bx

		
		mov	di,1 ;delay de 1 centesimo de segundo
		call	delay
		loop	novacor		; continua até fazer as 9 colunas que correspondem a uma liha completa
		
		inc	linha		; Vai desenhar a próxima linha
		dec	nlinhas		; contador de linhas
		mov	al, nlinhas
		cmp	al, 0		; verifica se já desenhou todas as linhas 
		jne	ciclo2		; se ainda há linhas a desenhar continua x
		je	cursor
cursor:
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição2
		mov 		ah, 08h		; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car2, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor	
		dec		POSx
	

CICLO:		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H	
aqui:	
		inc		POSxa
		goto_xy		POSxa,POSya
		mov		ah, 02h
		mov		dl, Car2	; Repoe Caracter2 guardado 
		int		21H
aqui5:	
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor2
		dec		POSx
		
		
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, Car	
		int		21H			
		
		goto_xy		78,0		; Mostra o caractr2 que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter2 da posição no canto
		mov		dl, Car2	
		int		21H			
		
IMPRIME:	
		goto_xy		POSx,POSy	; Vai para posição do cursor
		mov		ah, 02h
		mov		dl, '('	; Coloca AVATAR1
		int		21H
		
		inc		POSx
		goto_xy		POSx,POSy		
		mov		ah, 02h
		mov		dl, ')'	; Coloca AVATAR2
		int		21H	
		dec		POSx
		
		goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
LER_SETA:
		call 		LE_TECLA
		cmp AcabouTempo,1
		je	fim_tempo
		cmp		ah, 1
		je		ESTEND
		CMP 		AL, 27	; ESCAPE
		JE		fim
		cmp		al,13
		je		teclaenter
		jmp		LER_SETA
fim_tempo:
		mov MostrarSegundos,10
		mov AcabouTempo,0
		call apaga_ecran
;---Mostra a pontuação no final do tempo
		goto_xy	30,1
		MOV AH,09H
		LEA DX,StringPontuacao 
		INT 21H
		GOTO_XY	43,1
		mov dl,pont
		MOV AH,02H 
		INT 21H	
		GOTO_XY	42,1
		mov dl,pont1
		MOV AH,02H 
		INT 21H
		GOTO_XY	41,1
		mov dl,pont2
		MOV AH,02H 
		INT 21H
		GOTO_XY	40,1
		mov dl,pont3
		MOV AH,02H 
		INT 21H
;-------------------------
		goto_xy 20,10
		MOV AH,09H
		LEA DX,msgFim 
		INT 21H
		goto_xy 26,10
		lea dx,bufferString
		mov ah,0Ah
		int 21h
		
;----GUARDAR PONTUAÇÃO--------------
		mov     ah,3Dh			 
        mov     al,2			
        lea     dx,FichNovo		
        int     21h				
        mov     HandleFichNovo,ax		; ax devolve o Handle para o ficheiro 
		jc      erro_abrir
		mov bx,HandleFichNovo

		
escreverPont:
		xor cx,cx
		xor dx,dx

		mov     ah,3fh			
        mov     bx,HandleFichNovo		
        mov     cx,1			
        lea     dx,carLido
        int     21h	
		cmp ax,0
		jne escreverPont
		
		lea dx,pont3
		mov ah,40h
		int 21h
		lea dx,pont2
		mov ah,40h
		int 21h
		lea dx,pont1
		mov ah,40h
		int 21h
		lea dx,pont
		mov ah,40h
		int 21h
		
		lea dx,strEspaco
		mov ah,40h
		int 21h
		xor cx,cx
		
		mov cl,bufferString[1]
		
		lea dx,bufferString
		add dx,2
		mov ah,40h
		int 21h
		
		mov cx,1
		lea dx,endLine1
		mov ah,40h
		int 21h
		
		mov cx,1
		lea dx,endLine2
		mov ah,40h
		int 21h
		

fecha_ficheiro:					; vamos fechar o ficheiro 
        mov     ah,3eh
        mov     bx,HandleFichNovo
        int     21h
		jmp inicio
		
erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
		jmp fim
		
		
		
		
ESTEND:		cmp 		al,48h
		jne		BAIXO
		dec		POSy		;cima
		cmp POSy,8
		jb	limitar1
		jmp		CICLO
limitar1:
		inc POSY
		jmp Ciclo
BAIXO:		cmp		al,50h
		jne		ESQUERDA
		inc 		POSy		;Baixo
		cmp POSy,14
		jae	limitar2
		jmp		CICLO
limitar2:
		dec POSY
		jmp Ciclo
ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda
		cmp POSx,30
		jb	limitar3
		jmp		CICLO
limitar3:
		inc 	POSx
		inc 	POSx
		jmp Ciclo
DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		inc		POSx		;Direita
		inc		POSx		;Direita
		cmp POSx,48
		jae	limitar4
		jmp		CICLO
limitar4:
		dec 	POSx
		dec 	POSx
		jmp Ciclo
		
teclaenter:
	mov contagemCarinhasC,0
	mov contagemCarinhasT,0
	;CALCULAR o deslocamento da linha e coluna
	xor ax,ax
	add	al, POSx ;
	adc ax,0
	add	al, POSx ; 2 * coluna
	adc ax,0
	mov guardar,ax
	mov	al, 160		
	mov	ah, POSy
	mul	ah			; multiplicar o nº da linha por 160
	add ax,guardar 	; somar tudo (160*linha)+(2*coluna)
	adc ax,0
	
	mov bx,ax
	mov ax,es:[bx]
	and ah,01110000b
	cmp ah,0
	je LER_SETA
	mov guardaCor,ah
	mov posInicial,bx
	
	mov acumuladorX,1
	mov acumuladorY,0
verticalCima:
	sub	bx,160			; subtrai 160 a bx para verificar a core exatamente acima
	mov ax,es:[bx]		;	vai buscar a cor
	and ah,01110000b
	cmp ah,guardaCor	;	compara a cor em cima com a cor guardada
	jne	verticalBaixo
	cmp al,1
	jne tentarTriste1
	inc contagemCarinhasC
	jmp verticalCimaDeslizar
tentarTriste1:
	cmp al,45
	jne	verticalCimaDeslizar
	inc contagemCarinhasT
verticalCimaDeslizar:
	mov ax,es:[bx-160]
	cmp ah,0111b
	je verticalCimaDeslizarNovaCor
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	sub	bx,160
	jmp verticalCimaDeslizar
verticalCimaDeslizarNovaCor:
	call CalcAleat
	pop ax
	and al,01110000b
	cmp al,0
	je verticalCimaDeslizarNovaCor
	cmp ah,30
	ja semcarinha1
	mov ah,1
	mov es:[bx],ah
	mov ah,0
	mov es:[bx+2],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	inc explodiu
	jmp verticalBaixo
semcarinha1:
	xor ah,ah
	mov es:[bx],ah
	mov es:[bx+2],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	inc explodiu
	
	
verticalBaixo:
	mov bx,posInicial
	add	bx,160
	adc bx,0
	mov ax,es:[bx]		
	and ah,01110000b
	cmp ah,guardaCor
	jne	horizontalDir
	cmp al,1
	jne tentarTriste4
	inc contagemCarinhasC
tentarTriste4:
	cmp al,45
	jne	aqui2
	inc contagemCarinhasT
aqui2:
	mov al,es:[bx-160]
	cmp al,1
	jne tentarTriste5
	inc contagemCarinhasC
	jmp aqui1
tentarTriste5:
	cmp al,45
	jne	aqui1
	inc contagemCarinhasT
aqui1:
	mov bx,posInicial
explodirCursor: ;TEM QUE EXPLODIR E DESLIZAR PRIMEIRO O CUBO SELECIONADO PELO CURSOR
	mov ax,es:[bx-160]
	cmp ah,0111b
	je explodirNovaCor
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	sub bx,160
	jmp explodirCursor
explodirNovaCor:
	call CalcAleat
	pop ax
	and al,01110000b
	cmp al,0
	je explodirNovaCor
	cmp ah,30
	ja semcarinha5
	mov ah,1
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,0
	mov es:[bx+3],al
	mov es:[bx+2],ah
	inc explodiu
	jmp	verticalBaixoDeslizar
semcarinha5:
	xor ah,ah
	mov es:[bx],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+2],ah
	mov bx,posInicial
	add bx,160
	inc explodiu
	;-----
	
	
verticalBaixoDeslizar:
	
	mov ax,es:[bx-160]
	cmp ah,0111b
	je verticalBaixoDeslizarNovaCor
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	sub	bx,160
	jmp verticalBaixoDeslizar
verticalBaixoDeslizarNovaCor:
	call CalcAleat
	pop ax
	and al,01110000b
	cmp al,0
	je verticalBaixoDeslizarNovaCor
	cmp ah,30
	ja semcarinha4
	mov ah,1
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,0
	mov es:[bx+3],al
	mov es:[bx+2],ah
	inc explodiu
	mov baixo1,1
	jmp	horizontalDir
semcarinha4:
	xor ah,ah
	mov es:[bx],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+2],ah
	inc explodiu
	mov baixo1,1
	
	
horizontalDir:
	mov bx,posInicial
	add	bx,4
	adc bx,0
	mov ax,es:[bx]		
	and ah,01110000b
	cmp ah,guardaCor
	jne	horizontalEsq
	cmp al,1
	jne tentarTriste2
	inc contagemCarinhasC
	jmp horizontalDirDeslizar
tentarTriste2:
	cmp al,45
	jne	horizontalDirDeslizar
	inc contagemCarinhasT
horizontalDirDeslizar:
	mov ax,es:[bx-160]
	cmp ah,0111b
	je horizontalDirDeslizarNovaCor

	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	sub	bx,160
	jmp horizontalDirDeslizar
horizontalDirDeslizarNovaCor:
	call CalcAleat
	pop ax
	and al,01110000b
	cmp al,0
	je horizontalDirDeslizarNovaCor
	cmp ah,30
	ja semcarinha3
	mov ah,1
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,0
	mov es:[bx+3],al
	mov es:[bx+2],ah
	inc explodiu
	jmp	horizontalEsq
semcarinha3:
	xor ah,ah
	mov es:[bx],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+2],ah
	mov bx,posInicial
	inc explodiu
	
	
horizontalEsq:
	mov bx,posInicial
	sub	bx,4
	mov ax,es:[bx]		
	and ah,01110000b
	cmp ah,guardaCor
	jne	explodir
	cmp al,1
	jne tentarTriste6
	inc contagemCarinhasC
	jmp horizontalEsqDeslizar
tentarTriste6:
	cmp al,45
	jne	horizontalEsqDeslizar
	inc contagemCarinhasT
horizontalEsqDeslizar:
	mov ax,es:[bx-160]
	cmp ah,0111b
	je horizontalEsqDeslizarNovaCor
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	sub	bx,160
	jmp horizontalEsqDeslizar
horizontalEsqDeslizarNovaCor:
	call CalcAleat
	pop ax
	and al,01110000b
	cmp al,0
	je horizontalEsqDeslizarNovaCor
	cmp ah,30
	ja semcarinha2
	mov ah,1
	mov es:[bx],ah
	mov es:[bx+1],al
	mov ah,0
	mov es:[bx+3],al
	mov es:[bx+2],ah
	inc explodiu
	jmp	explodir
semcarinha2:
	xor ah,ah
	mov es:[bx],ah
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+2],ah
	mov bx,posInicial
	inc explodiu	
	
explodir:
	cmp explodiu,1
	jb LER_SETA
	mov bx,posInicial
explodirDeslizar:
	mov ax,es:[bx]
	cmp al,1
	jne	continuar
	inc contagemCarinhasC
	jmp continuar
tentarTriste3:
	cmp al,45
	jne	continuar
	inc contagemCarinhasT
continuar:
	cmp baixo1,1
	je pontuacaoCalc
	mov ax,es:[bx-160]
	cmp ah,0111b
	je explodirDeslizarNovacor
	mov es:[bx],ax
		mov al,0
	mov es:[bx+2],ax
	sub	bx,160
	jmp explodirDeslizar
explodirDeslizarNovacor:
	call CalcAleat
	pop ax
	and ah,01110000b
	cmp ah,0
	je explodirDeslizarNovacor
	cmp ah,30
	ja carinha
	mov al,1
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	mov bx,posInicial
	xor ah,ah
	inc explodiu
	jmp pontuacaoCalc
carinha:
	xor al,al
	mov es:[bx],ax
	mov al,0
	mov es:[bx+2],ax
	mov bx,posInicial
	xor ah,ah
	inc explodiu	
pontuacaoCalc:
	xor ah,ah
	mov al,explodiu
	add al,contagemCarinhasC
	sub al,contagemCarinhasT
	add al,pont1
	cmp al,'9'
	ja	incCentenas
	mov pont1,al
	jmp final
incCentenas:
	inc pont2
	sub al,10
	mov pont1,al
	cmp pont2,'9'
	jna final
incMilhares:
	inc pont3
	mov pont2,'0'
	
final:
	mov explodiu,0
	mov baixo1,0
verificarCombinacoes:
	;goto_xy 30,8   
	; calcular o endereço do primeiro quadrado no tabuleiro
	xor ax,ax
	add	al, 30 ;
	adc ax,0
	add	al, 30 ; 2 * coluna
	adc ax,0
	mov guardar,ax
	mov	al, 160		
	mov	ah, 8
	mul	ah			; multiplicar o nº da linha por 160
	add ax,guardar 	; somar tudo (160*linha)+(2*coluna)
	adc ax,0
	mov guardar,ax
	mov bx,ax
	
cicloComb:
	mov ax,es:[bx]
	mov dx,es:[bx+4]
	and ah,01110000b
	and dh,01110000b
	cmp dh,0
	je 	incLinha
	cmp ah,dh
	je	LER_SETA
	mov dx,es:[bx+160]
	and dh,01110000b
	cmp ah,dh
	je LER_SETA
	add bx,4
	adc bx,0
	jmp cicloComb
incLinha:
	mov dx,es:[bx+160]
	and dh,01110000b
	cmp dh,0
	je ciclo4
	add bx,160
	adc bx,0
	sub bx,8*4 ; para ir para o primeiro quadrado da linha
	jmp cicloComb



editarGrelha:
	call apaga_ecran
	goto_xy 7,4

	MOV AH,09H
	LEA DX,msgGrelha1
	INT 21H
	goto_xy 7,5
	MOV AH,09H
	LEA DX,msgGrelha2
	INT 21H
	goto_xy 3,20
	
	xor 	ax,ax
	mov		ah,01h 	;Interrupção de ler caracter
	int 	21h

	cmp		al,49
	je		criarGrelha
	cmp     al,50	
	jmp		editarGrelha
	
criarGrelha:
	call apaga_ecran
	mov grelha,1
	goto_xy 26,10
	MOV AH,09H
	LEA DX,msgGrelha3
	INT 21H
	goto_xy 36,11
	lea dx,tempFichGrelha
	mov ah,0Ah
	int 21h
	mov al,tempFichGrelha[3]
	mov nomeFichGrelha[0],al
	mov al,tempFichGrelha[4]
	mov nomeFichGrelha[1],al
	mov al,tempFichGrelha[5]
	mov nomeFichGrelha[2],al
	call apaga_ecran
	
	
	
	
ciclo_Grelha:
		
		mov ah, 01110000b
		mov al,0

		mov	dl,cl	
		mov	dh,70
		
		mov   	ax, 0b800h	; Segmento de memória de vídeo onde vai ser desenhado o tabuleiro
		mov   	es, ax	
		mov	linha, 	8	; O Tabuleiro vai começar a ser desenhado na linha 8 
		mov	nlinhas, 6	; O Tabuleiro vai ter 6 linhas
ciclo5:		
		mov	al, 160		
		mov	ah, linha
		mul	ah
		add	ax, 60
		mov 	bx, ax		; Determina Endereço onde começa a "linha". bx = 160*linha + 60

		mov	cx, 9		; São 9 colunas 
cicloo:  	
		mov 	dh,	car1	; vai imprimir o caracter "SPACE"
		mov	es:[bx],dh	;
	
novacor1:	
		mov ah,0
		mov al,01110000b


		mov 	dh,	   car1	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois carecteres de ecran
		mov	es:[bx],   dh		
		mov	es:[bx+1], al	; Coloca as características de cor da posição atual 
		inc	bx		
		inc	bx		; próxima posição e ecran dois bytes à frente
		mov 	dh,	   car1	; Repete mais uma vez porque cada peça do tabuleiro ocupa dois carecteres de ecran
		mov	es:[bx],   dh
		mov	es:[bx+1], al
		inc	bx
		inc	bx

		
		mov	di,1 ;delay de 1 centesimo de segundo
		call	delay
		loop	novacor1		; continua até fazer as 9 colunas que correspondem a uma liha completa
		
		inc	linha		; Vai desenhar a próxima linha
		dec	nlinhas		; contador de linhas
		mov	al, nlinhas
		cmp	al, 0		; verifica se já desenhou todas as linhas 
		jne	ciclo5		; se ainda há linhas a desenhar continua x
		je	cursor1
cursor1:
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h	; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor	
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição2
		mov 		ah, 08h		; Guarda o Caracter que está na posição do Cursor
		mov		bh,0		; numero da página
		int		10h			
		mov		Car2, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor	
		dec		POSx
	

CICLO1:		goto_xy	POSxa,POSya	; Vai para a posição anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado 
		int		21H	

		inc		POSxa
		goto_xy		POSxa,POSya	
		mov		ah, 02h
		mov		dl, Car2	; Repoe Caracter2 guardado 
		int		21H	
		dec 		POSxa
		
		goto_xy	POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car, al	; Guarda o Caracter que está na posição do Cursor
		mov		Cor, ah	; Guarda a cor que está na posição do Cursor
		
		inc		POSx
		goto_xy		POSx,POSy	; Vai para nova possição
		mov 		ah, 08h
		mov		bh,0		; numero da página
		int		10h		
		mov		Car2, al	; Guarda o Caracter2 que está na posição do Cursor2
		mov		Cor2, ah	; Guarda a cor que está na posição do Cursor2
		dec		POSx
		
		
		goto_xy		77,0		; Mostra o caractr que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter da posição no canto
		mov		dl, Car	
		int		21H			
		
		goto_xy		78,0		; Mostra o caractr2 que estava na posição do AVATAR
		mov		ah, 02h		; IMPRIME caracter2 da posição no canto
		mov		dl, Car2	
		int		21H			
		
IMPRIME1:	
		goto_xy		POSx,POSy	; Vai para posição do cursor
		mov		ah, 02h
		mov		dl, '('	; Coloca AVATAR1
		int		21H
		
		inc		POSx
		goto_xy		POSx,POSy		
		mov		ah, 02h
		mov		dl, ')'	; Coloca AVATAR2
		int		21H	
		dec		POSx
		
		goto_xy		POSx,POSy	; Vai para posição do cursor
		
		mov		al, POSx	; Guarda a posição do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posição do cursor
		mov 	POSya, al
		
LER_SETA1:

		call 		LE_TECLA2
		cmp		ah, 1
		je		ESTEND1
		CMP 		AL, 27	; ESCAPE
		je sair
		
		cmp al,13
		je	incAh
		
				
		
		jmp		LER_SETA1
sair:
	mov 	grelha,0
	mov 	contadorGrelha,0
	xor 	cx,cx
	mov     ah,3Dh
	mov 	al,1
	lea     dx,FichOld		
	int     21h
	jc      erro_abrir2				
	mov     HandleFichNovo,ax		; ax devolve o Handle para o ficheiro 
	
	mov bx,HandleFichNovo
escreverTudo:
	mov	ax,0B800h
	mov	es,ax
	mov ax,es:[bx]
	mov guardarWordGrelha,ax
	mov cx,1
	lea dx,guardarWordGrelha
	mov ah,40h
	int 21h
	inc contadorGrelha
	inc contadorGrelha
	inc bx
	inc bx
	cmp contadorGrelha,2000
	je fecha_ficheiro2
	jmp escreverTudo
	

fecha_ficheiro2:					; vamos fechar o ficheiro 
	mov     ah,3eh
	mov     bx,HandleFichNovo
	int     21h
	jmp fim
		
erro_abrir2:
	mov     ah,09h
	lea     dx,Erro_Open
	int     21h
	jmp fim
	
ESTEND1:		
		cmp 		al,48h
		jne		BAIXO2
		dec		POSy		;cima
		jmp		CICLO1

BAIXO2:		cmp		al,50h
		jne		ESQUERDA1
		inc 		POSy		;Baixo
		jmp		CICLO1

ESQUERDA1:
		cmp		al,4Bh
		jne		DIREITA1
		dec		POSx		;Esquerda
		dec		POSx		;Esquerda

		jmp		CICLO1

DIREITA1:
		cmp		al,4Dh
		jne		LER_SETA1
		inc		POSx		;Direita
		inc		POSx		;Direita
		
		jmp		CICLO1

incAh:
	xor ax,ax
	add	al, POSx ;
	adc ax,0
	add	al, POSx ; 2 * coluna
	adc ax,0
	mov guardar,ax
	mov	al, 160		
	mov	ah, POSy
	mul	ah			; multiplicar o nº da linha por 160
	add ax,guardar 	; somar tudo (160*linha)+(2*coluna)
	adc ax,0
	
	mov bx,ax
	mov ax,es:[bx]
	and ah,01110000b
	cmp ah,0
	je LER_SETA
	or ah,00001111b
	cmp ah,01111111b
	je ComecarDeNovo
	add ah,1
	adc ah,0
	mov es:[bx+1],ah
	mov es:[bx+3],ah
	jmp LER_SETA1
ComecarDeNovo:
	mov ah,00010000b
	mov es:[bx+1],ah
	mov es:[bx+3],ah
	jmp LER_SETA1
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

fim:
	mov     ah,4ch
	int     21h	
main	endp

LE_TECLA2	PROC
sem_tecla:
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
		goto_xy	POSx,POSy

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA1
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA1:	RET
LE_TECLA2	endp


;recebe em di o número de milisegundos a esperar
delay proc
	pushf
	push	ax
	push	cx
	push	dx
	push	si
	
	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx
	mov	si,ax


cicl:	mov	ah,2Ch
	int	21h
	mov	al,100
	mul	dh
	xor	dh,dh
	add	ax,dx

	cmp	ax,si 
	jnb	naoajusta
	add	ax,6000 ; 60 segundos
naoajusta:
	sub	ax,si
	cmp	ax,di
	jb	cicl

	pop	si
	pop	dx
	pop	cx
	pop	ax
	popf
	ret
delay endp

cseg    ends
end     Main