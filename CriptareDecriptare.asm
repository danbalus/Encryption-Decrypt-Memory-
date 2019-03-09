.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
include macrouri.asm
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
;criptare/decriptare1
sir db 10 dup(0)
mesaj_citire_fisier db "Dati numele fisierului: ",0
cheie2 dq 0
mesaj_eroare_fisier db "Fisierul NU exista! Reintroduceti: ",0
mesaj_optiune db "Alegeti operatia dorita",10,13,"1. Criptare 1",10,13, "2. Decriptare 1",10,13, "Optiune: ",0
mesaj_eroare_optiune db "Optiune incorecta. Reintroduceti: ",0
mesaj_citire_cheie db "Dati cheia de criptare(0-->7): ",0

mesaj_eroare_cheie db "Cheie incorecta. Reintroduceti : ",0
format_caracter db "%c",0
format_zecimal db "%d",0
format_sir db "%s",0
format_long db "%ld",0
mod_citire db "r",0
mod_scriere db "w",0
nume_fisier_decript db "rezultatDecriptare.txt",0
nume_fisier_cript db "rezultatCriptare.txt",0
buffer_caracter db 0
pointer_fisier_sursa dd 0
pointer_fisier_destinatie dd 0
nume_fisier db 20 dup(0)
cheie db 0
optiune db 0


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
	
	; deschidere fisierului de intrare in modul citire
	deschidere_fisier nume_fisier, mod_citire, pointer_fisier_sursa

	cmp pointer_fisier_sursa, 0 ; verifica daca s-a deschis fisierul
	je recitire_nume_fisier ; daca pointerul spre fisier e 0, atunci fisierul nu s-a deschis si se reciteste numele acestuia
	jmp continuare ; daca fisierul s-a deschis continuam
	
	recitire_nume_fisier:
	; afisare mesaj eroare pt numele fisierului
	push offset mesaj_eroare_fisier
	call printf
	add esp,4
	jmp citire_nume_fisier ; recitirea propriu-zisa a numelui fisierului, urmata de redeschiderea si reverificarea acestuia
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	continuare:
	; afisare mesaj de alegere a optiunii
	push offset mesaj_optiune
	call printf
	add esp,4
		
	
	citire_optiune:
	; citirea optiunii (trebuie sa fie 1 sau 2)
	push offset optiune
	push offset format_zecimal
	call scanf
	add esp,8

	cmp optiune,1
	je criptare_1
	
	cmp optiune,2
	je decriptare_1
	
	jmp recitire_optiune ; daca optiunea aleasa nu este 1 sau 2 se reciteste 
	
	recitire_optiune:
	push offset mesaj_eroare_optiune ; se afiseaza mesajul de eroare pt optiunea introdusa
	call printf
	add esp,4
	jmp citire_optiune ; recitirea propriu-zisa a optiunii, urmata de reverificarea acesteia
	
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	criptare_1:
	; macro-ul are ca parametrii operatia dorita(criptare1 sau decriptare1) si numele fisierului in care se scrie rezultatul
	algoritm1 criptare1,nume_fisier_cript
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	decriptare_1:
	; macro-ul are ca parametrii operatia dorita(criptare1 sau decriptare1) si numele fisierului in care se scrie rezultatul
	algoritm1 decriptare1,nume_fisier_decript
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	sfarsit:
	
	; inchiderea fisierului destinatie
	inchidere_fisier pointer_fisier_destinatie
	
	; inchiderea fisierului sursa
	inchidere_fisier pointer_fisier_sursa
	
	; terminarea programului
	push 0
	call exit
	
end start