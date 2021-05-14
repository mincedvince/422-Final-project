*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    LEA WELCOME_MESSAGE,A1
    MOVE.B #14,D0
    TRAP #15

* Put program code here
    LEA STARTING_ADDRESS_MESSAGE,A1
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.B #2,D0
    TRAP #15

* Put variables and constants here
CR EQU $0D  ASCII code for Carriage Return
LF EQU $0A  ASCII code for Line Feed
WELCOME_MESSAGE DC.B '-------------A Disassembler for the Motorola MC68000 Microprocessor-------------',CR,LF 
                DC.B 'Welcome to our program',CR,LF
                DC.B 'This program is created by group with the following member:',CR,LF
                DC.B '- Vincent Le',CR,LF
                DC.B '- Jibran Ahmed',CR,LF
                DC.B '- Duy Vu',CR,LF
                DC.B 'To start program please enter the starting and ending addresses asked below',CR,LF,CR,LF,0

STARTING_ADDRESS_MESSAGE   DC.B    'Please enter the starting address: ',0
ENDING_ADDRESS_MESSAGE     DC.B    'Please enter the ending address: ',0
                

    END    START        ; last line of source
    
    

