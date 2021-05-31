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
* Reading process that read each byte and break it down for it opcode
* 
    MOVEA.L StartingAddress,A2 move starting address into address register A2
    MOVEA.L EndingAddress,A3   move ending address into address register A3

*   A2 is currently use to store and increment starting address
*   A3 is currently use to store ending address   
*   D0-D7 is available to use
*   A4-A7 is available to use 
Address_Loop
    CMPA.L A3,A2    Check if program read pass ending address
    BGT END_RESTART If read pass ending address, go to end of program decision
    BEQ END_RESTART If equal to ending address, go to end of program decision
    MOVE.B CurrentLine,D0 Move value from current line to D0 for comparing printing limit
    CMP.B PrintLimit,D0   Compare current line count to max line count
    BEQ PressEnter  if line limit is reach then branch. Otherwise, ignore until line limit reach
  
OpcodeProcess
*   Begin with getting opcode
    JSR Display_Memory
    MOVE.W (A2),D1 store current word value at memory to D2
    ADDQ.L #2,A2   increment current memory location by 2 for the next word or byte.
    
*   Get first most significant bit of opcode
*   Use D1 to temporary store the bit
    MOVE.W D1,D2    move current opcode word into D2 for shifting
    LSR.W #8,D2     max shift is 8 bit therefore shift current word 8 bits to rights
    LSR.W #4,D2     continue shifting 4 more bits to the right to get the first bit of current opcode word
    LEA CombineOperation,A4 load address of the buffer into A4 for storing instruction to print
    JSR CheckEA     jump to subroutine to check effective address
    JSR JumpTable   jump to subroutine to check opcode
    LEA CombineOperation,A1 
    MOVE.B #13,D0    Display the NULL terminated string at (A1) with CR, LF.
    TRAP #15
    ADD.B #1,CurrentLine increment current line by one for printing limit
    BRA Address_Loop
    
PressEnter
*display message telling user to press enter
   MOVE.B #1,CurrentLine
   LEA PRESS_ENTER_MESSAGE,A1
   MOVE.B #13,D0
   TRAP #15
   
*input for enter
  MOVE.B #$20,D1 store emtpy space for trap task 6
  MOVE.B #6,D0
  TRAP #15
  
  BRA OpcodeProcess Branch back to opcode process
   
*-----------------------------------------------------------------------------------------------------------*
* Jump to subroutine that check effective address by splitting and shifting the opcode word. START
* EA        Mode
*---------------
* Dn    =    0
* An    =    1
*(An)   =    2
*(An)+  =    3
*-(An)  =    4
*#<data>=    7
*(www).L=    7
*(www).W=    7
* D2 currently store the first bit
* D3 for second bit
* D4 for third bit
* D5 for forth bit
CheckEA
    
    MOVE.W D1,D3    second bit ex AAAA BBBB CCCC DDDD
    LSL.W  #8,D3    shift current word value 8bit left CCCC DDDD 0000 0000
    LSL.W  #5,D3    shift current word value 5 bits left DDD0 0000 0000 0000
    LSR.W  #8,D3    shift current word value 8 bits right 0000 0000 DDD0 0000
    LSR.W  #5,D3    shift current word value 5 bits right 0000 0000 0000 0DDD

    *Done with D3 Source Register
    MOVE.W D1,D4    third bit ex AAAA BBBB CCCC DDDD
    LSR.W  #3,D4    shift current word value 3 bits right 000A AAAB BBBC CCCD
    LSL.W  #8,D4    shift current word value 8 bits left BBBC CCCD 0000 0000
    LSL.W  #5,D4    shift current word value 5 bits left CCD0 0000 0000 0000
    LSR.W  #8,D4    shift current word value 8 bits right 0000 0000 CCD0 0000
    LSR.W  #5,D4    shift current word value 5 bits right 0000 0000 0000 0CCD
    *Done with D4 Source Mode
    MOVE.W D1,D5    forth bit ex AAAA BBBB CCCC DDDD
    LSR.W  #6,D5    shift current word value 6 bits right 0000 00AA AABB BBCC
    LSL.W  #8,D5    shift current word value 8 bits left  AABB BBCC 0000 0000
    LSL.W  #5,D5    shift current word value 5 bits left BCC0 0000 0000 0000
    LSR.W  #8,D5    shift current word value 8 bits right 0000 0000 BCC0 0000 
    LSR.W  #5,D5    shift current word value 5 bits right 0000 0000 0000 0BCC
    *Done with D5 Destination Mode
    MOVE.W D1,D6    forth bit ex AAAA BBBB CCCC DDDD
    LSR.W  #8,D6    shift current word value 8 bits right 0000 0000 AAAA BBBB
    LSR.W  #1,D6    shift current word value 1 bits right  0000 0000 0AAA ABBB
    LSL.W  #8,D6    shift current word value 8 bits left  0AAA ABBB 0000 0000
    LSL.W  #5,D6    shift current word value 5 bits left BBB0 0000 0000 0000
    LSR.W  #8,D6    shift current word value 8 bits right 0000 0000 BBB0 0000 
    LSR.W  #5,D6    shift current word value 8 bits right 0000 0000 0000 0BBB
    *Done with D6 Destination Register

    RTS
*-----------------------------------------------------------------------------------------------------------*
* D2 store register number
* D7 store mode number
* EA        Mode
*---------------
* Dn    =    0
* An    =    1
*(An)   =    2
*(An)+  =    3
*-(An)  =    4
*#<data>=    7
*(www).L=    7
*(www).W=    7

RetrieveEA
    CMP.B #0,D7     Dn
    BEQ Dn
    
    CMP.B #1,D7     An
    BEQ An
    
    CMP.B #2,D7     (An)
    BEQ An_Indirect
    
    CMP.B #3,D7     (An)+
    BEQ An_Indirect_Plus
    
    CMP.B #4,D7     -(An)
    BEQ An_Indirect_Minus
    
    CMP.B #7,D7     #<data>,(www).L,(www).W
    BEQ Address_Data

Dn
    MOVE.B #$44,(A4)+ D
    MOVE.B D2,(A4)+ register number
    RTS

An
    MOVE.B #$41,(A4)+ A
    MOVE.B D2,(A4)+ register number
    RTS
An_Indirect
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    MOVE.B D2,(A4)+ register number
    MOVE.B #$28,(A4)+ )
    RTS
An_Indirect_Plus
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    MOVE.B D2,(A4)+ register number
    MOVE.B #$28,(A4)+ )
    MOVE.B #$2B,(A4)+ +
    RTS

An_Indirect_Minus
    MOVE.B #$2D,(A4)+ -
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    MOVE.B D2,(A4)+ register number
    MOVE.B #$28,(A4)+ )
    RTS

Address_Data






*-----------------------------------------------------------------------------------------------------------*


* Jump to subroutine that check effective address by splitting and shifting the opcode word. END
*-----------------------------------------------------------------------------------------------------------*


*-----------------------------------------------------------------------------------------------------------*
* Jump table subrountine that read and identify which instuction the opcode is belong to. START*
* Compare Opmode within D2 with the following listed opcode number
* Jump table list
* Name    Opcode
*----------------
*MOVE.B =   1
*MOVE.W =   3
*MOVE.L =   2
*MOVEM  =   4
*ADD    =   13(D)
*AND    =   12(C)
*CMP    =   11(B)
*JSR    =   4
*RTS    =   4
*BLT    =   6
*OR     =   8
*LSR    =   14(E)

JumpTable
    CMP.B #1,D2 MOVE.B
    BEQ MOVE_1
    
    CMP.B #2,D2 MOVE.L
    BEQ MOVE_2
    
    CMP.B #3,D2 MOVE.W
    BEQ MOVE_3
    
    CMP.B #4,D2 MOVEM, JSR, RTS
    BEQ MOVEM_JRS_RTS_4
    
    CMP.B #6,D2 BLT
    BEQ BLT_6
    
    CMP.B #8,D2 OR
    BEQ OR_8
    
    CMP.B #11,D2 CMP
    BEQ CMP_11
    
    CMP.B #12,D2 AND
    BEQ AND_12
    
    CMP.B #13,D2 ADD
    BEQ ADD_13
    
    CMP.B #14,D2 LSR
    BEQ LSR_14
    BRA DATA    instruction not found
    
Combine_Done   RTS
      
*-----------------------------------------------------------------------------------------------------------*
* D2 to store register number
MOVE_1
    MOVE.B #$4D,(A4)+   M
    MOVE.B #$4F,(A4)+   O
    MOVE.B #$56,(A4)+   V
    MOVE.B #$45,(A4)+   E
    MOVE.B #$2E,(A4)+   .
    MOVE.B #$42,(A4)+   B
    MOVE.B #$9,(A4)+   Tab for space
    
    *source
    MOVE.B D3,D2       move source register to D2
    MOVE.B D4,D7       move source mode to D7
    JSR RetrieveEA
    
    MOVE.B #$2C,(A4)+  *,
    
    *destination
    MOVE.B D6,D2       move destination register to D2
    MOVE.B D5,D7       move destination mode to D7
    JSR RetrieveEA
    BRA Combine_Done


*-----------------------------------------------------------------------------------------------------------*
    
MOVE_2
    MOVE.B #$4D,(A4)+   M
    MOVE.B #$4F,(A4)+   O
    MOVE.B #$56,(A4)+   V
    MOVE.B #$45,(A4)+   E
    MOVE.B #$2E,(A4)+   .
    MOVE.B #$42,(A4)+   L
    MOVE.B #$9,(A4)+   Tab for space
    
    *source
    MOVE.B D3,D2       move source register to D2
    MOVE.B D4,D7       move source mode to D7
    JSR RetrieveEA
    
    MOVE.B #$2C,(A4)+  *,
    
    *destination
    MOVE.B D6,D2       move destination register to D2
    MOVE.B D5,D7       move destination mode to D7
    JSR RetrieveEA
    BRA Combine_Done
    
*-----------------------------------------------------------------------------------------------------------*


MOVE_3
    MOVE.B #$4D,(A4)+   M
    MOVE.B #$4F,(A4)+   O
    MOVE.B #$56,(A4)+   V
    MOVE.B #$45,(A4)+   E
    MOVE.B #$2E,(A4)+   .
    MOVE.B #$42,(A4)+   W
    MOVE.B #$9,(A4)+   Tab for space
    
    *source
    MOVE.B D3,D2       move source register to D2
    MOVE.B D4,D7       move source mode to D7
    JSR RetrieveEA
    
    *destination
    MOVE.B #$2C,(A4)+  *,
    MOVE.B D6,D2       move destination register to D2
    MOVE.B D5,D7       move destination mode to D7
    JSR RetrieveEA
    BRA Combine_Done

*-----------------------------------------------------------------------------------------------------------*


MOVEM_JRS_RTS_4
      *Not complete
JSR
    MOVE.B #$4A,(A4)+ J
    MOVE.B #$53,(A4)+ S
    MOVE.B #$52,(A4)+ R
          *Not complete


RTS
    MOVE.B #$52,(A4)+ R
    MOVE.B #$54,(A4)+ T
    MOVE.B #$53,(A4)+ S    
          *Not complete

MOVEM
    MOVE.B #$4D,(A4)+ M
    MOVE.B #$4F,(A4)+ O
    MOVE.B #$56,(A4)+ V 
    MOVE.B #$45,(A4)+ E    
    MOVE.B #$4D,(A4)+ M    
         *Not complete

*-----------------------------------------------------------------------------------------------------------*

BLT_6
    MOVE.B #$42,(A4)+ B
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$54,(A4)+ T
      *Not complete


*-----------------------------------------------------------------------------------------------------------*

OR_8
    MOVE.B #$4F,(A4)+ O
    MOVE.B #$52,(A4)+ R
    MOVE.B #$2E,(A4)+ .
  *Not complete
    
*-----------------------------------------------------------------------------------------------------------*

CMP_11
    MOVE.B #$43,(A4)+ C
    MOVE.B #$4D,(A4)+ M
    MOVE.B #$50,(A4)+ P
    MOVE.B #$2E,(A4)+ .
      *Not complete

*-----------------------------------------------------------------------------------------------------------*


AND_12
    MOVE.B #$41,(A4)+ A
    MOVE.B #$4E,(A4)+ N
    MOVE.B #$44,(A4)+ D
    MOVE.B #$2E,(A4)+ .
  *Not complete

*-----------------------------------------------------------------------------------------------------------*


ADD_13
    MOVE.B #$41,(A4)+ A
    MOVE.B #$44,(A4)+ D
    MOVE.B #$44,(A4)+ D
    MOVE.B #$2E,(A4)+ .
  *Not complete

*-----------------------------------------------------------------------------------------------------------*


LSR_14
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$53,(A4)+ S
    MOVE.B #$52,(A4)+ R
    MOVE.B #$2E,(A4)+ .
      *Not complete

 *-----------------------------------------------------------------------------------------------------------*

    
DATA
    MOVE.B #$44,(A4)+ D
    MOVE.B #$41,(A4)+ A
    MOVE.B #$54,(A4)+ T
    MOVE.B #$41,(A4)+ A
  *Not complete

* Jump table subrountine that read and identify which instuction the opcode is belong to. END*
*-----------------------------------------------------------------------------------------------------------*

*   Display memory location
Display_Memory    
    MOVE.L A2,D1    Store unsigned number in D1 for display
    MOVE.B #16,D2   Set converted to number base 16
    MOVE.B #15,D0   Use to display unsinged number, therefore memory location
    TRAP #15
    MOVE.B #$9,D1
    MOVE.B #6,D0   Use to display unsinged number, therefore memory location
    TRAP #15
    RTS
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
*   Use D5 to store the final hex address
CHECKASCII 
    MOVE.B (A1)+,D2   read byte and byte and load it into D2 for checking and converting
        
    CMPI.B #$39,D2  compare value within D2 to 39
    BLT NUMBER      if D2 is less than 39, then it is a number

    CMPI.B #$39,D2 compare value within D2 to 39
    BGT LETTER     if D2 is greater than 39, then it is a letter

    
NUMBER
    CMPI.B #$30,D2 compare value within D2 to 30
    BLT NOTVALID   if D2 is less than 30, then it is not a number or letter
    
    SUBI.B #$30,D2
    BRA COMBINE    Branch to combine to begin the process


LETTER
    CMPI.B #$46,D2 compare value within D2 to 46
    BGT NOTVALID   if D2 is greater than 46 then it is out of hex for A-F
    
    SUBI.B #$37,D2
    BRA COMBINE    Branch to combine to begin the process
    
    

NOTVALID
    MOVEA.L #$00000000,A7 Error in conversion, set A7 to 000000 for error
    RTS  return from subroutine

COMBINE
    ADD.B D2,D3 Add hex from D2 to D3 for combining
    ADDI.B #1,D4 increament length by 1 each time
    CMP.B D1,D4  check if current length equal maximum length
    BEQ EXITJSR  Branch to exit subroutine when length are equal
    LSL.L #4,D3 shift 4 bit to the left for adding
    BRA CHECKASCII loop again to continue converting
    
EXITJSR
    MOVE.L D3,D5
    CLR.L D1
    CLR.L D2
    CLR.L D3
    CLR.L D4
    RTS  return from subroutine

*   Subrountine that reads a user input and save them to address register as hexadecimal number. END *
*-----------------------------------------------------------------------------------------------------------*
*---------------------------------------------EA-ROUTINE----------------------------------------------------*
EFFECTIVE_ADDRESS_DECODE
    MOVEM.L A0-A3/A5/D0-D5/D7,-(SP) Save the data from registers to the stack
    LEA EFFECTIVE_ADDRESS_INDEX,A1  Referencing the effective address table
    CLR.L   D1 Empty data register                 
    MOVE.W  D0,D2 Get copy of bits
    MOVE.B  #3,D1 Store bits to shift
    LSR.W   D1,D0 Shift to the right
    MULU    #6,D0 ????
    JSR     00(A1,D0) Jump to table
    MOVEM.L (SP)+,A0-A3/A5/D0-D5/D7 Restore data from stack
    RTS return
    
EFFECTIVE_ADDRESS_INDEX
    JMP     EFFECTIVE_ADRESS_INDEX000 Direct data register
    JMP     EFFECTIVE_ADRESS_INDEX001 Direct address register
    JMP     EFFECTIVE_ADRESS_INDEX010 Indirect address register
    JMP     EFFECTIVE_ADRESS_INDEX011 Indirect address register with post increment
    JMP     EFFECTIVE_ADRESS_INDEX100 Indirect address register with pre increment
    JMP     EFFECTIVE_ADRESS_INDEX101 Indirect address register using index
    JMP     EFFECTIVE_ADRESS_INDEX110 Immediate effective address
    JMP     EFFECTIVE_ADRESS_INDEX111 Not used
    
EFFECTIVE_ADRESS_INDEX000
    MOVE    D2,D0 Get effective address from D2
    ANDI    #7,D0 Grab address register
    *BSR    SEND DATA TO BUFFER
    RTS Return
    
EFFECTIVE_ADRESS_INDEX001
    MOVE    D2,D0 Get effective address from D2
    ANDI    #7,D0 Grab address register
    *BSR    SEND DATA TO BUFFER
    RTS Return
    
EFFECTIVE_ADRESS_INDEX010
    MOVE.W  #FIRST_BRACE,(A4)+ Open the first brace
    CLR.L   D0 Empty data register
    MOVE    D2,D0 Store bits
    ANDI    #7,D0 Grab address register
    *BSR    SEND DATA TO BUFFER
    MOVE.W  #LAST_BRACE,(A4)+ Close brace
    RTS return

EFFECTIVE_ADRESS_INDEX011
    MOVE.W  #FIRST_BRACE,(A4)+ Open the first brace
    CLR.L   D0 Empty data register
    MOVE    D2,D0 Store bits
    ANDI    #7,D0 Grab address register
    *BSR    SEND DATA TO BUFFER
    MOVE.W  #LAST_BRACE,(A4)+ Close brace
    MOVE.W  #ADD_SIGN,(A4)+ Add to the address buffer
    RTS return

EFFECTIVE_ADRESS_INDEX100
    MOVE.W  #SUBTRACT_SIGN,(A4)+ Add to the address buffer
    MOVE.W  #FIRST_BRACE,(A4)+ Open the first brace
    CLR.L   D0 Empty data register
    MOVE    D2,D0 Store bits
    ANDI    #7,D0 Grab address register
    *BSR    SEND DATA TO BUFFER
    MOVE.W  #LAST_BRACE,(A4)+ Close brace
    RTS return

EFFECTIVE_ADRESS_INDEX101
    MOVE.W  #MONEY_SIGN,(A4)+ Add to the address buffer
    MOVE.W  (A3)+,A0 
    MOVE.L  D0,D3
    CLR.L   D4
    MOVE.B  #4,D4
    *BSR    CONVERT TO ASCII
    MOVEA.L A3,A1
    MOVE.W  A1,(A4)+
    MOVE.W  #FIRST_BRACE,(A4)+
    CLR.L   D0
    MOVE    D2,D0
    ANDI    #7,D0
    *BSR    SEND DATA TO BUFFER
    *FINISH THIS
    
EFFECTIVE_ADRESS_Index110
    LEA SUBINDEX_JUMP_TABLE,A1 Load the subindex jump table
    MOVE    D2,D0 Store bits
    MULU    #6,D0 ????
    JSR     00(A1,D0) Jump to subindex jump table
    RTS return

EFFECTIVE_ADRESS_INDEX111
    LEA SUBINDEX_JUMP_TABLE,A1 Load the subindex jump table
    MOVE    D2,D0 Store bits
    ANDI    #7,D0 Get address register bits
    MULU    #6,D0 ????
    JSR     00(A1,D0) Jump to subindex jump table
    RTS return
    
SUBINDEX_JUMP_TABLE
    JMP EFFECTIVE_ADDRESS_SUBINDEX000
    JMP EFFECTIVE_ADDRESS_SUBINDEX001
    JMP EFFECTIVE_ADDRESS_SUBINDEX010
    JMP EFFECTIVE_ADDRESS_SUBINDEX011
    JMP EFFECTIVE_ADDRESS_SUBINDEX100
    JMP EFFECTIVE_ADDRESS_SUBINDEX101
    JMP EFFECTIVE_ADDRESS_SUBINDEX110
    JMP EFFECTIVE_ADDRESS_SUBINDEX111

EFFECTIVE_ADDRESS_SUBINDEX000

EFFECTIVE_ADDRESS_SUBINDEX001   

EFFECTIVE_ADDRESS_SUBINDEX010    

EFFECTIVE_ADDRESS_SUBINDEX011    

EFFECTIVE_ADDRESS_SUBINDEX100    

EFFECTIVE_ADDRESS_SUBINDEX101    

EFFECTIVE_ADDRESS_SUBINDEX110    

EFFECTIVE_ADDRESS_SUBINDEX111        

*---------------------------------------------EA-LIBRARY----------------------------------------------------*
FIRST_BRACE             DC.B    '(',0
LAST_BRACE              DC.B    ')',0
COMMA_SIGN              DC.B    ',',0
SLASH_SIGN              DC.B    '/',0
HASH_SIGN               DC.B    '#',0
MONEY_SIGN              DC.B    '$',0
TAB_SIGN                DC.B    '   ',0
ADD_SIGN                DC.B    '+',0
SUBTRACT_SIGN           DC.B    '-',0
WORD_EXTENSION          DC.B    '.W',0
LONGWORD_EXTENSION      DC.B    '.L',0
PROGRAM_COUNTER         DC.B    '(PC)',0
FIRST_BRACE_SIZE        DC.W    1
LAST_BRACE_SIZE         DC.W    1
COMMA_SIGN_SIZE         DC.W    1
SLASH_SIGN_SIZE         DC.W    1
HASH_SIGN_SIZE          DC.W    1
MONEY_SIGN_SIZE         DC.W    1
TAB_SIGN_SIZE           DC.W    1
ADD_SIGN_SIZE           DC.W    1
SUBTRACT_SIGN_SIZE      DC.W    1
WORD_EXTENSION_SIZE     DC.W    1
LONGWORD_EXTENSION_SIZE DC.W    1
PROGRAM_COUNTER_SIZE    DC.W    1
WORD_TO_ASCII           DS.W    1 


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
* Prompt user to either restart or quit the program.
END_RESTART
*......
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
  
STARTING_ADDRESS_MESSAGE   DC.B    'Please enter the starting address in hexadecimal length of 6: ',0
ENDING_ADDRESS_MESSAGE     DC.B    'Please enter the ending address hexadecimal length of 6: ',0
PRESS_ENTER_MESSAGE        DC.B    'Please press enter to display more',CR,LF,CR,LF,0
ERROR_MESSAGE_LENGTH_GREATER   DC.B    'Please re-enter the address with length less than 6',0
ERROR_MESSAGE_LENGTH_EQUAL     DC.B    'Please enter something here for the first address',0
StartingAddress     DC.L    1
EndingAddress       DC.L    1
PrintLimit          DC.B    20
CurrentLine         DC.B    1
CombineOperation    DC.L    1
    END    START        ; last line of source

    
    

