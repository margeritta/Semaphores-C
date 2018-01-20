;podzielniki czestotliwosci
TC equ 9083;36060; 1.19MHz/33Hz
TD equ 8095;32162; 1.19MHz/37Hz
TE equ 7212;29024; 1.19MHz/41Hz
TF equ 6800;27045; 1.19MHz/44Hz
TG equ 6071;24285; 1.19MHz/49Hz
TA equ 5409;21636; 1.19MHz/55Hz
TH equ 4817;19193; 1.19MHz/62Hz
TP equ 1;pauza
;Q koniec melodii
Progr segment
assume cs:Progr,ss:stosik,ds:dane;

; ******************************************************
; * 					PROCEDURY 					   *
; ******************************************************

; LADOWANIE I WYSIWETLANIE

println proc
mov ah,09h;Funkcja wypisująca na ekran napis o adresie zawartym w rejestrze DX
int 21h;Wywołanie przerwania DOSa z funkcją 09H
ret;Powrót z procedury
endp

readln proc
mov ah,0ah
int 21h
ret
endp

no_file proc
lea dx,napis1;Wpisanie adresu napisu do rejestru DX
call println;Wywołanie procedury println
jmp exit
endp

close_file proc
mov ah,3Eh;    funkcja przerwania 21H zamykajaca plik
mov bx,fileHandle; identyfikator pliku ktory ma byc otwarty
int 21h;        przerwanie
ret ; powrot z procedury
endp

open_file proc  ;Początek procedury
mov dx,offset plik; nazwa pliku ktory ma byc otwarty
mov ah,3dh;    funkcja przerwania 21H otwierajaca plik
mov al,0;      otwarcie tylko do czytania
int 21h;        przerwanie
jc no_file;Jeżeli przerwanie zwróciło błąd to skocz do procedury "no_file"
mov fileHandle,ax;  zapisanie numeru identyfikatora pliku do zmiennej fileHandle
ret 
endp

read_file proc
push cx; odłóż na stos zawartość rejestru CX
push dx;
mov bx,fileHandle; identyfikator pliku ktory ma byc otwarty
mov cx,3;       liczba bajtow do przeczytania
lea dx,bufor;
mov ah,3Fh;     funkcja przerwania 21H czytajaca z pliku
int 21h;        przerwanie
pop dx;
pop cx; zdejmij ze stosu i zapisz zawartość do rejestru CX
ret;
endp;

; KONEIC W/W

; GRANIE MUZYKI

nuta proc
push dx;
push cx;
mov cx,7;
mov dx,65535;
mov ah,86h;
int 15h
pop cx
pop dx
ret
nuta endp;

polnuta proc
push dx;
push cx;
mov cx,3;
mov dx,65535;
mov ah,86h;
int 15h
pop cx
pop dx
ret
polnuta endp;

cwiercnuta proc
push dx;
push cx;
mov cx,1;
mov dx,65535;
mov ah,86h;
int 15h
pop cx
pop dx
ret
cwiercnuta endp;

osemka proc
push dx;
push cx;
mov cx,0;
mov dx,32000;
mov ah,86h;
int 15h
pop cx
pop dx
ret
osemka endp;

speakerON proc
;wgranie nuty(melodii)
mov ax,ton
out 42h,al
mov al,ah
out 42h,al
;zalaczenie glosnika
in al,61h;
or al,00000011b;
out 61h,al;
ret
endp

speakerOFF proc
in al,61h;
and al,11111100b;
out 61h,al;
ret
endp;

play proc
call speakerON
cmp czas,1
je cala
cmp czas,2
je pol
cmp czas,4
je cwierc
cmp czas,8
je eight
jmp endplay

cala: call nuta
jmp endplay
pol: call polnuta
jmp endplay
cwierc: call cwiercnuta
jmp endplay
eight: call osemka
jmp endplay
endplay:
call speakerOFF
ret
endp

; KONIEC GRANIA MUZYKI

println1 proc
mov al,bufor
mov ah,0eh
int 10h

;mov ah,1h
;int 16h
;jnz exit1
ret
endp
;--------------------------------------------------------------------
start: mov ax,dane
mov ds,ax
mov ax,stosik
mov ss,ax
mov sp,offset szczyt


mov ah, 62h		;
int 21h			;odczyt parametrów z PSP funkcja 62h z przerwania 21h
mov es,bx
mov al,es:[0080h] ; liczba znaków w parametrze jest pamiętana pod adresem o przesunięciu 0080H względem początku PSP
mov cl,al ; przepisjemy z al do cl
sub cl,2 ; mozna 2x dec cl ; zmniejszenie liczby znakow o ENTER 
mov si,0
cmp al,0
jbe brak
przepisywanie:
mov al,es:[0081h+si+1];   przekazanie znakow z bufora do al ; znaki parametrów są pamiętane o 1 bajt dalej, czyli 0081H                           
lea bx,plik        
mov ds:[bx+si],al;   przekazanie znaku do zmiennej lancuchowej
cmp cl,0;             porownanie rejestru CL z 0
je end_przepisywanie        
dec cl             
inc si
jmp przepisywanie
end_przepisywanie:

;sprawdzenie
;lea dx,plik
;call println

lea dx,napis3
call println
call open_file

melodia: 
call read_file
call println1
mov dl,bufor(0)
cmp dl,'Q'
je exit1

cmp dl,'C'
je do
cmp dl,'D'
je re
cmp dl,'E'
je mi
cmp dl,'F'
je fa
cmp dl,'G'
je so
cmp dl,'A'
je la
cmp dl,'H'
je Zi
cmp dl,'P'
je pauza

;wprowadzenie oktawy
graj:
mov cl,bufor(1)
sub cl,30h

shr ton,cl;
graj1:
mov cl,bufor(2)
sub cl,30h
mov czas,cl

call play;
; jesli wcisniety klawisz to zakoncz
mov ah,0Bh
int 21h
cmp al,0
jne exit
jmp melodia;

brak:
call no_file
jmp exit

exit1:
jmp exit

do: mov ton,TC
jmp graj
re: mov ton,TD
jmp graj
mi: mov ton,TE
jmp graj
fa: mov ton,TF
jmp graj
so: mov ton,TG
jmp graj
la: mov ton,TA
jmp graj
zi: mov ton,TH
jmp graj
pauza: mov ton,TP
jmp graj1

exit:
call close_file
lea dx,napis4
call println
mov ah,4ch
mov al,00h
int 21h;

Progr ends;


dane segment
		
ton dw 0
czas db 0


plik db 0,0,0,0,0,0,0,0,0,0,0,0;'music6.txt',0 ;0,0,0,0,0,0,0,0,0,0,0,0
;plik
fileHandle dw 0
bufor db 3 dup(0)

napis1 db 10,13,' Plik nie istnieje !!!$';
napis3 db '******************************',10,13,'* Witam w Programie grajacym *',10,13,'******************************',10,13,'$'
napis4 db 10,13,' THE END !$'
enterr db 10,13,10,13,'$'
dane ends


stosik segment
dw 100h dup(0)
szczyt label word
stosik ends
end start 
