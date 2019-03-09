.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf:proc
extern scanf:proc
extern strlen:proc
extern fscanf:proc
extern fopen:proc
extern fprintf:proc
extern fclose:proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;criptare1
mesaj_citire_fisier db "Dati numele fisierului pentru descriptare: ",0
mesaj_eroare_fisier db "Fisier inexistent! Reintroduceti: ",0
mesaj_citire_cheie db "Dati cheia de criptare(de la 0-7) : ",0
mesaj_eroare_cheie db "Cheia trebuie sa fie in intervalul 0-7 ! Reintroduceti: ",0
format_caracter db "%c",0
format_zecimal db "%d",0
format_sir db "%s",0
mod_citire db "r",0
mod_scriere db "w",0
nume_fisier_scriere db "RezultatDecriptare.txt",0

buffer_caracter db 0
pointer_fisier_sursa dd 0
pointer_fisier_destinatie dd 0
nume_fisier db 0
cheie db 0

.code
start:

	
	; afisare mesaj pt citirea numelui fisierului
	push offset mesaj_citire_fisier
	call printf
	add esp,4
	
	
	; citire nume fisier
	citire_nume_fisier:
	push offset nume_fisier
	push offset format_sir
	call scanf
	add esp,8
	
	
	; deschidere fisier text in modul citire
	push offset mod_citire
	push offset nume_fisier
	call fopen
	mov pointer_fisier_sursa,eax ; in pointer_fisier_sursa este pointerul spre fisierul din care citim
	add esp,8
	
	cmp pointer_fisier_sursa, 0 ; verifica daca s-a deschis fisierul
	je recitire_nume_fisier ; daca pointerul spre fisier e 0 atunci fisierul nu s-a deschis si se reciteste numele acestuia
	jmp continuare ; daca fisierul s-a deschis continuam
	
	recitire_nume_fisier:
	; afisare mesaj eroare pt numele fisierului
	push offset mesaj_eroare_fisier
	call printf
	add esp,4
	jmp citire_nume_fisier ; salt la recitirea propriu-zisa a numelui fisierului, urmata de redeschiderea si reverificarea acestuia
	
	
	continuare:	
	; afisare mesaj citire cheie
	push offset mesaj_citire_cheie
	call printf
	add esp,4
	
	
	citire_cheie:
	; citire cheie
	push offset cheie
	push offset format_zecimal
	call scanf
	add esp,8
	
	; se verifica daca cheia este in intervalul precizat (0-7)
	; se va folosi compararea numerelor cu semn
	cmp cheie,0 
	jl recitire_cheie ; daca cheie < 0 se reciteste 
	
	cmp cheie,7
	jg recitire_cheie ; daca cheie > 7 se reciteste
	jmp continuare2 ; daca cheia este in intervalul precizat se trece mai departe
	
	
	recitire_cheie:
	; afisare mesaj eroare pt cheie
	push offset mesaj_eroare_cheie
	call printf
	add esp,4
	jmp citire_cheie ; recitire propriu-zisa, urmata de reverificarea cheii
	
		
	continuare2:
	; deschidem fisierul in care vom scrie rezultatele. Acesta se deschide in modul scriere ("w")
	push offset mod_scriere
	push offset nume_fisier_scriere
	call fopen
	mov pointer_fisier_destinatie,eax ; in pointer_fisier_destinatie este pointerul spre fisierul in care scriem rezultatele
	add esp,8
	
	
	; incepem citirea,decriptarea si scrierea in fisier, acestea executandu-se caracter cu caracter
	bucla_citire_decriptare_scriere:
	; citirea unui caracter din fisier
	push offset buffer_caracter
	push offset format_caracter
	push pointer_fisier_sursa
	call fscanf 
	add esp,12
				
	cmp eax,0ffffffffH ; se verifica daca s-a ajung la sfarsit de fisier
	je sfarsit ; daca s-a ajuns la sfarsitul fisierul se sare la inchiderea fisierelor si terminarea programului
	
	; decriptarea propriu-zisa a caracterului
	mov bl,buffer_caracter ; mutarea caracterului citit in registrul bl
	mov cl,cheie ; mutarea cheii in registrul cl
	rol bl,cl ; rotirea rezultatului spre stanga cu atatia biti cati sunt dati de cheia citita
	sub bl,1 ; scaderea rezultatului cu 1 
	not bl ; executarea operatiei de complement fata de 1
	mov buffer_caracter,bl ; mutarea rezultatului criptarii in variabila
		
		
	push dword ptr [buffer_caracter]
	push offset format_caracter
	call printf
	add esp,8
	
	; scrierea rezultatului criptarii in fisierul destinatie
	push dword ptr [buffer_caracter]
	push offset format_caracter
	push pointer_fisier_destinatie
	call fprintf
	add esp,12
	
	jmp bucla_citire_decriptare_scriere ; repeta bucla de citire,decriptare,scriere pana ajunge la sfarsitul fisierului

	
	
	sfarsit:
	; inchiderea fisierului din care am citit
	push pointer_fisier_sursa
	call fclose
	add esp,4
	
	; inchiderea fisierul in care am scris
	push pointer_fisier_destinatie
	call fclose
	add esp,4
	
	;terminarea programului
	push 0
	call exit
end start