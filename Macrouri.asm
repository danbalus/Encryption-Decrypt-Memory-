
deschidere_fisier macro nume_fisier,mod_deschidere,pointer_fisier

	; deschidem fisierul in modul precizat ca parametru ("r" sau "w")
	push offset mod_deschidere
	push offset nume_fisier
	call fopen
	mov pointer_fisier,eax ; in pointer_fisier este pointerul spre fisierul deschis
	add esp,8

endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

citire_caracter macro eticheta

	; citirea unui caracter din fisier
	
	push offset buffer_caracter
	push offset format_caracter
	push pointer_fisier_sursa
	call fscanf 
	add esp,12

	cmp eax,0ffffffffH ; se verifica daca s-a ajung la sfarsit de fisier
	je eticheta ; daca s-a ajuns la sfarsitul fisierul se sare la eticheta corespunzatoare data in momentul apelarii macro-ului
	
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

algoritm1 macro criptare_decriptare, nume_fisier
local citire_cheie, recitire_cheie, continuare, bucla,scriere

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
	
	jmp continuare ; daca cheia este in intervalul precizat se trece mai departe

	recitire_cheie:
	; afisare mesaj eroare pt cheie
	push offset mesaj_eroare_cheie
	call printf
	add esp,4
	jmp citire_cheie ; recitire propriu-zisa, urmata de reverificarea cheii
	
	continuare:
	; deschidem fisierul in care vom scrie rezultatele
	deschidere_fisier nume_fisier, mod_scriere, pointer_fisier_destinatie

	; incepem citirea,criptarea/decriptarea si scrierea in fisier, acestea executandu-se caracter cu caracter
	bucla:
	citire_caracter sfarsit ; macro-ul citeste cate un caracter pe care il pune in buffer_caracter. Dupa terminarea ciclului de citire,criptare/decriptare,scriere se inchid fisierele si programul
	
	; criptarea propriu-zisa a caracterului
	criptare_decriptare scriere ; macro ce aplica algoritmul de criptare sau de decriptqre in functie de parametrii dati
	
	scriere:
	; scrierea rezultatului pe ecran
	push dword ptr [buffer_caracter]
	push offset format_caracter
	call printf
	add esp,8
	
	; scrierea rezultatului in fisierul destinatie
	push dword ptr [buffer_caracter]
	push offset format_caracter
	push pointer_fisier_destinatie
	call fprintf
	add esp,12
	
	
	jmp bucla ; repeta bucla de citire,criptare/decriptare,scriere pana ajunge la sfarsitul fisierului

endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
criptare1 macro continuare
local et

	mov bl,buffer_caracter ; mutarea caracterului citit in registrul bl
	not bl ; executarea operatiei de complement fata de 1
	add bl,1 ; adunare rezultatului cu 1 => complement fata de 2
	mov cl,cheie ; mutarea cheii in registrul cl
	ror bl,cl ; rotirea rezultatului spre dreapta cu atatia biti cati sunt dati de cheia citita
	
	cmp bl,1Ah ; comparam daca nu cumva rezultatul criptarii va da sfarsit de fisier
	je eof ; daca da eof(1Ah) atunci se sare la eticheta care prelucreaza acest rezultat
	
	mov buffer_caracter,bl ; mutarea rezultatului criptarii in variabila
	jmp continuare ; se continua cu urmatoarea sectiune din program care este data ca parametru
	
	eof:
	mov buffer_caracter,0 ; punem 0-NULL ca rezultat (deoarece daca lasam 1Ah cand facem decriptarea se va opri acolo)
	
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

decriptare1 macro continuare
local et,cont

	mov bl,buffer_caracter ; mutarea caracterului citit in registrul bl
	
	cmp bl,0 ; comparam daca caracterul citit din fisier nu este cumva caracterul null
	je et ; daca am citit caracterul null, inseamna ca la criptare a fost initial un caracter criptat prin codul 1Ah
	
	cont:
	mov cl,cheie ; mutarea cheii in registrul cl
	rol bl,cl ; rotirea rezultatului spre stanga cu atatia biti cati sunt dati de cheia citita
	sub bl,1 ; scaderea rezultatului cu 1 
	not bl ; executarea operatiei de complement fata de 1
	mov buffer_caracter,bl ; mutarea rezultatului decriptarii in variabila
	jmp continuare ; se continua cu secventa de cod specificata ca parametru
	
	et: 
	mov bl,1Ah ; revenim la caracterul cu codul 1Ah care urmeaza a fi decriptat
	jmp cont
	
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

criptare_decriptare macro scriere,cript_decript
local bucla,et_cheie, continua

	mov esi,0 ; initializam indexul la 0
	
	bucla:
	cript_decript continua
	continua:
	dec edi ; decrementam edi pentru a trece la un alt octet din cheie (edi era  initial 7, iar apoi l-am decrementat pana la 0, unde se sare la et_cheie)
	cmp edi,-1 ; comparam indexul cheii cu -1 (deoarece edi se decrementeaza inainte de comparare)
	je et_cheie ; daca am ajuns la -1 sarim la et_cheie
	
	cmp esi,ebx ; comparam esi cu ultimul index al sirului sir[] 
	je scriere ; daca am ajuns la sfarsitul sirului trecem la eticheta de scriere in fisierul destinatie
	
	inc esi ; incrementam esi pentru a trece la un nou element din sir
	jmp bucla ; se sare in bucla urmand criptarea unui nou element din sir
	
	et_cheie: 
	; eticheta se apeleaza atunci cand edi a ajuns la -1
	mov edi,7 ; se pune 7 in edi, urmand ca ciclul cheii sa se reia

	; urmatoarea comparatie verifica daca nu cumva si blocul de 10 caractere se termina deodata cu blocul de 8 octeti ai cheii
	; daca se termina deodata atunci se scriu cele 10 caractere
	cmp esi,ebx ; comparam esi cu ultimul index al sirului sir[] 
	je scriere ; daca am ajuns la sfarsitul sirului trecem la eticheta de scriere in fisierul destinatie
	
	inc esi ; incrementam esi si aici deoarece am sarit peste partea asta in bucla principala
	jmp bucla ; se revine in bucla
	
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


scriere macro et_gata
local bucla

	mov esi,0 ; initializam indexul la 0
	
	bucla:
	
	push dword ptr sir[esi]
	push offset format_caracter
	call printf
	add esp,8
	
	; scriem in fisierul destinatie cate un caracter
	push dword ptr sir[esi]
	push offset format_caracter
	push pointer_fisier_destinatie
	call fprintf
	add esp,12
	
	cmp esi,ebx ; comparam indexul cu indexul ultimului caracter al sirului (stocat in ebx)
	je et_gata ; daca s-a auns la sfarsitul sirului se sare la et_gata care va fi data in interiorul macroului algoritm2 in functie daca e sau nu ultimul bloc de caractere
	
	inc esi ; incrementam esi pentru a parcurge sirul
	jmp bucla ; sarim la bucla pana cand esi=ebx

endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inchidere_fisier macro pointer_fisier
	
	; inchiderea fisierului precizat prin pointer fisier
	push pointer_fisier
	call fclose
	add esp,4
	
endm
