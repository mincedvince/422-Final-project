*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
*A1 loading and displaying messages for trap
*D0 currently use for trap task
*D1 currently use to store string length
*Currently not use D2-D7, A2-A7
    ORG    $1000
START:                  ; first instruction of program
*   Welcome Message 
    LEA WELCOME_MESSAGE,A1 *Print out welcome message
    MOVE.B #14,D0  *Display the NULL terminated string at (A1) without CR, LF
    TRAP #15

*   Staring address message 
FIRST_ADDRESS    
    LEA STARTING_ADDRESS_MESSAGE,A1 *print out prompt for first address
    MOVE.B #14,D0  *Display the NULL terminated string at (A1) without CR, LF
    TRAP #15
    
    MOVE.B #2,D0 *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
    TRAP #15
    
*   Check length 
    CMPI #6,D1  *Check if length is greater than 6
    BGT ERROR_LENGTH_GREATER    *Branch to display error message 
    
    CMPI #0,D1
    BEQ ERROR_LENGTH_EQUAL      *Branch to display error message
    
    JSR CHECKASCII   *If not error jump to subroutine for conversion
    MOVE.L D5,StartingAddress *store starting address into a storage
    CLR.L D5
SECOND_ADDRESS
    LEA ENDING_ADDRESS_MESSAGE,A1 *print out prompt for first address
    MOVE.B #14,D0  *Display the NULL terminated string at (A1) without CR, LF
    TRAP #15
    
    MOVE.B #2,D0 *Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
    TRAP #15
    
*   Check length 
    CMPI #6,D1  *Check if length is greater than 6
    BGT ERROR_LENGTH_GREATER    *Branch to display error message 
    
    CMPI #0,D1
    BEQ ERROR_LENGTH_EQUAL      *Branch to display error message
    
    JSR CHECKASCII   *If not error jump to subroutine for conversion
    MOVE.L D5,EndingAddress *store ending into a storage
    CLR.L D5
    *continue here................
 
*-----------------------------------------------------------------------------------------------------------*
*   Subrountine that reads a user input and save them to address register as hexadecimal number. START *
*   A-F in hex is 41-46
*   0-9 in hex is 30-39
*   D1 contain the length of string
*   Currently not use D2-D7, A2-A7
*   Use D2 to store each ASCII for converting
*   Use D3 to add each hex
*   Use D4 to check length
*   Use A6 to store the final hex address
CHECKASCII 
    MOVE.B (A1)+,D2   *read byte and byte and load it into D2 for checking and converting
        
    CMPI.B #$39,D2  *compare value within D2 to 39
    BLT NUMBER      *if D2 is less than 39, then it is a number

    CMPI.B #$39,D2 *compare value within D2 to 39
    BGT LETTER     *if D2 is greater than 39, then it is a letter

    
NUMBER
    CMPI.B #$30,D2 *compare value within D2 to 30
    BLT NOTVALID   *if D2 is less than 30, then it is not a number or letter
    
    SUBI.B #$30,D2
    BRA COMBINE    *Branch to combine to begin the process


LETTER
    CMPI.B #$46,D2 *compare value within D2 to 46
    BGT NOTVALID   *if D2 is greater than 46 then it is out of hex for A-F
    
    SUBI.B #$37,D2
    BRA COMBINE    *Branch to combine to begin the process
    
    

NOTVALID
    MOVEA.L #$00000000,A7 *Error in conversion, set A7 to 000000 for error
    RTS  *return from subroutine

COMBINE
    ADD.B D2,D3 *Add hex from D2 to D3 for combining
    ADDI.B #1,D4 *increament length by 1 each time
    CMP.B D1,D4  *check if current length equal maximum length
    BEQ EXITJSR  *Branch to exit subroutine when length are equal
    LSL.L #4,D3 *shift 4 bit to the left for adding
    BRA CHECKASCII *loop again to continue converting
    
EXITJSR
    MOVEA.L D3,D5
    CLR.L D1
    CLR.L D2
    CLR.L D3
    CLR.L D3
    RTS  *return from subroutine

*   Subrountine that reads a user input and save them to address register as hexadecimal number. END *


   
*   Display error related to length
ERROR_LENGTH_EQUAL 
    LEA ERROR_MESSAGE_LENGTH_EQUAL,A1
    MOVE.B #14,D0
    TRAP #15
    BRA FIRST_ADDRESS

*   Display error related to length
ERROR_LENGTH_GREATER
    LEA ERROR_MESSAGE_LENGTH_GREATER,A1
    MOVE.B #14,D0
    TRAP #15
    BRA FIRST_ADDRESS


* Put variables and constants here
CR EQU $0D  *ASCII code for Carriage Return
LF EQU $0A  *ASCII code for Line Feed
WELCOME_MESSAGE DC.B '-------------A Disassembler for the Motorola MC68000 Microprocessor-------------',CR,LF 
                DC.B 'Welcome to our program',CR,LF
                DC.B 'This program is created by group with the following member:',CR,LF
                DC.B '- Vincent Le',CR,LF
                DC.B '- Jibran Ahmed',CR,LF
                DC.B '- Duy Vu',CR,LF
                DC.B 'To start program please enter the starting and ending addresses asked below',CR,LF,CR,LF,0
  
STARTING_ADDRESS_MESSAGE   DC.B    'Please enter the starting address in hexadecimal length of 6: ',0
ENDING_ADDRESS_MESSAGE     DC.B    'Please enter the ending address hexadecimal length of 6: ',0
ERROR_MESSAGE_LENGTH_GREATER   DC.B    'Please re-enter the address with length less than 6',0
ERROR_MESSAGE_LENGTH_EQUAL     DC.B    'Please enter something here for the first address',0
StartingAddress     DS.L    1
EndingAddress       DS.L    1
    END    START        ; last line of source
    
    

