.model small
.stack 100h
.data
MaxArrayLength equ 30
Array dw  MaxArrayLength dup (0)                
TempArraySum dw 0  
Temp dw 0
ArrayLength dw ?
MsgErrorSum db 'Sum overflow! Restart program!$',0Ah,0Dh
MsgInputArrayLength db 0Ah,0Dh,'Input array length: ','$',0Ah,0Dh
MsgErrorInput db 0Ah,0Dh,'Incorect value!','$',0Ah,0Dh
MsgErrorInputLength db 0Ah,0Dh,'Array length should be >0 and <=30','$',0Ah,0Dh
MsgAverage db 'Arithmetic mean of array is: $',0Ah,0Dh
MsgInputStr db 0Ah,0Dh,'Input element (-32 768,32 767): $'     
                                
negative db 0 
NumBuffer dw 0         
EnterredNum db 9 dup('$') 
Asnwer db 20 dup,'$',0Ah,0Dh 
nextStr db 0Ah,0Dh,'$'  
str dw ?
ten dw 10
  
.code 

input macro str   
    mov ah, 0Ah
    int 21h
endm

output macro msg       
    lea dx,msg
    mov ah,09h
    int 21h
endm   

saveLength proc      
    
    output MsgInputArrayLength  
  
    xor cx,cx
    mov [EnterredNum+1],0
    lea dx,EnterredNum
    input EnterredNum
    
    mov cl,[EnterredNum+1]
    lea si,EnterredNum
    add si,2
    
    checkSym:
              
         xor ax,ax
         lodsb
         cmp al,'0'
         jl badNum
         cmp al,'9'
         jg badNum
         
         sub ax,'0'
         mov bx,ax
         xor ax,ax
         mov ax,NumBuffer 
         
         mov dx,ten
         imul dx
         jo badNum
         add ax, bx
         comeBack:
         jo badNum
         mov NumBuffer,ax
         
         loop checkSym 
    
         mov ArrayLength,ax
         mov NumBuffer,0   
         
         cmp ArrayLength,30
         jg  ErrorLengthOutp      
         cmp ArrayLength,0  
         jle ErrorLengthOutp  
           
    ret
    
    badNum:
        output MsgErrorInput 
        jmp ClearBuf   
        
    ErrorLengthOutp:
        output MsgErrorInputLength  
        jmp ClearBuf   
        
    ClearBuf:
        clc
        mov NumBuffer, 0 
        jmp saveLength   
        
endp       
 
 
 
inputElArray proc   
    
    push cx
    output MsgInputStr 
    
    mov [EnterredNum+1],0
    lea dx,EnterredNum
    input EnterredNum
    
    mov cl,[EnterredNum+1]
  
    lea si,EnterredNum
    add si,2
    
    checkSymbol:
              
         xor ax,ax 
         xor bx,bx
         lodsb 
         cmp al,'-'
         je FindMinus
         cmp al,'0'
         jl badArrEl
         cmp al,'9'
         jg badArrEl       
         
         mov bl,1;1>=symbol
         sub ax,'0' 
         cmp negative,1
         je SetMinus  
         
         Loop1:
         mov bx,ax
         xor ax,ax
         mov ax,NumBuffer 
         
         mov dx,ten
         imul dx
         jo badArrEl
         add ax, bx 
         
         jo badArrEl
         mov NumBuffer,ax
         
         loop checkSymbol  
         
         mov Array[di], ax  
         
         mov NumBuffer,0  
         mov negative,0  
         mov bl,0
         
         add di,2      
         pop cx        
         loop inputElArray  
    ret                        
    
    SetMinus:
        neg ax
        jmp Loop1    
    FindMinus:
         cmp bl,1
         je badArrEl
         mov negative,1 
         dec cx
         jmp checkSymbol
         
    badArrEl:
         output MsgErrorInput 
         jmp ClearBuf  
         
endp       

sumArray proc    
    
    mov ax,Array[di]
    add TempArraySum,ax 
    mov ax,TempArraySum
    adc di,2
    loop sumArray   
    
NumbtoStr proc    
    xor cx,cx
    mov ax,TempArraySum
    idiv ArrayLength 
    lea di,Asnwer 
    Divpart:  
        add cx,1      
        push bx 
        mov bx,ax  
        push dx  
    
        DivWis:  
        mov ax,bx 
        cmp ax,9
        jg Divpartt
        
        Divv:   
        sub ax,'0'
        imul ten
        sub bx,ax
        mov ax,bx
        OverDiv:     
        
        add ax,'0'
        mov [di],ax 
        add di,1  
        pop bx
        pop dx
    
        loop Divv    
        output nextStr
        output Asnwer
        call endProgram
    Divpartt: 
    
        add cx,1 
        idiv ten
        cmp ax,9       
        push bx
        mov bx,ax 
        jg Divpart
        jmp OverDiv 
                                           
endProgram proc
    mov ax,4C00h
    int 21h
    ret
endProgram endp

start:
    mov ax,@data
    mov ds,ax  

    call saveLength  
    
    xor cx,cx
    mov cx,ArrayLength
    
    call inputElArray  
    
    xor cx,cx
    mov cx,ArrayLength
    xor di,di         
    
    call sumArray   
    
    call NumbtoStr
    
    call endProgram
          
end start 

         
