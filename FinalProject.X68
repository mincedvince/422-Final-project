*A1 loading and displaying messages for trap
*D0 currently use for trap task
*D1 currently use to store string length
*Currently not use D2-D7, A2-A7
    ORG    $1000
START:                  ; first instruction of program
*   Welcome Message 
    LEA WELCOME_MESSAGE,A1 Print out welcome message
    MOVE.B #14,D0  Display the NULL terminated string at (A1) without CR, LF
    TRAP #15

*   Staring address message 
FIRST_ADDRESS    
    LEA STARTING_ADDRESS_MESSAGE,A1 print out prompt for first address
    MOVE.B #14,D0  Display the NULL terminated string at (A1) without CR, LF
    TRAP #15
    
    MOVE.B #2,D0 Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
    TRAP #15
    
*   Check length 
    CMPI #6,D1  Check if length is greater than 6
    BGT ERROR_LENGTH_GREATER    Branch to display error message 
    
    CMPI #0,D1
    BEQ ERROR_LENGTH_EQUAL      Branch to display error message
    
    JSR CHECKASCII   If not error jump to subroutine for conversion
    MOVE.L D5,StartingAddress store starting address into a storage
    CLR.L D5
    
SECOND_ADDRESS
    LEA ENDING_ADDRESS_MESSAGE,A1 print out prompt for first address
    MOVE.B #14,D0  Display the NULL terminated string at (A1) without CR, LF
    TRAP #15
    
    MOVE.B #2,D0 Read string from keyboard and store at (A1), NULL terminated, length retuned in D1.W (max 80)
    TRAP #15
    
*   Check length 
    CMPI #6,D1  Check if length is greater than 6
    BGT ERROR_LENGTH_GREATER    Branch to display error message 
    
    CMPI #0,D1
    BEQ ERROR_LENGTH_EQUAL      Branch to display error message
    
    JSR CHECKASCII   If not error jump to subroutine for conversion
    MOVE.L D5,EndingAddress store ending into a storage
    CLR.L D5
    
     
*-----------------------------------------------------------------------------------------------------------*
* Reading process that read each byte and break it down for it opcode
* 
    MOVEA.L StartingAddress,A2 move starting address into address register A2
    MOVEA.L EndingAddress,A3   move ending address into address register A3

*   A2 is currently use to store and increment starting address
*   A3 is currently use to store ending address   
*   D2-D7 is available to use
*   A4-A7 is available to use 
*   D1 is currently use to store word value
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
    
    
*   Get first most significant bit of opcode
*   Use D1 to temporary store the bit
    MOVE.W D1,D2    move current opcode word into D2 for shifting
    LSR.W #8,D2     max shift is 8 bit therefore shift current word 8 bits to rights
    LSR.W #4,D2     continue shifting 4 more bits to the right to get the first bit of current opcode word
    LEA CombineOperation,A4 load address of the buffer into A4 for storing instruction to print
    JSR CheckEA     jump to subroutine to check effective address
    JSR JumpTable   jump to subroutine to check opcode
    MOVE.B #$00,(A4)+
    LEA CombineOperation,A1 
    MOVE.B #13,D0    Display the NULL terminated string at (A1) with CR, LF.
    TRAP #15
    ADD.B #1,CurrentLine increment current line by one for printing limit
    ADDQ #2,A2   increment current memory location by 2 for the next word or byte.
    BRA Address_Loop
    
PressEnter
*display message telling user to press enter
   MOVE.B #1,CurrentLine
   LEA PRESS_ENTER_MESSAGE,A1
   MOVE.B #13,D0
   TRAP #15
   
*input for enter
  MOVE.B #$20,D1 store emtpy space for trap task 6
  MOVE.B #5,D0
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
   * MOVE.W D1,D3    second bit ex AAAA BBBB CCCC DDDD
   * LSL.W  #4,D3    shift current word value 4 bit left BBBB CCCC DDDD 0000
   * LSR.W  #8,D3    shift current word value 8 bits right 0000 0000 BBBB CCCC
   * LSR.W  #4,D3    shift current word value 4 bits right 0000 0000 0000 BBBB
    *Done with D3
   * MOVE.W D1,D4    third bit ex AAAA BBBB CCCC DDDD
   * LSL.W  #8,D4    shift current word value 8 bits left CCCC DDDD 0000 0000
   * LSR.W  #8,D4    shift current word value 8 bits right 0000 0000 CCCC DDDD
   * LSR.W  #4,D4    shift current word value 4 bits right 0000 0000 0000 CCCC
    *Done with D4
   * MOVE.W D1,D5    forth bit ex AAAA BBBB CCCC DDDD
   * LSL.W  #8,D5    shift current word value 8 bits left CCCC DDDD 0000 0000
   * LSL.W  #4,D5    shift current word value 4 bits left DDDD 0000 0000 0000
   * LSR.W  #8,D5    shift current word value 8 bits right 0000 0000 DDDD 0000
   * LSR.W  #4,D5    shift current word value 4 bits right 0000 0000 0000 DDDD
    *Done with D5
    
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
    JSR RegisterJumpTable
    MOVE.B D2,(A4)+ register number
    RTS

An
    MOVE.B #$41,(A4)+ A
    JSR RegisterJumpTable
    MOVE.B D2,(A4)+ register number
    RTS
An_Indirect
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    JSR RegisterJumpTable
    MOVE.B D2,(A4)+ register number
    MOVE.B #$29,(A4)+ )
    RTS
An_Indirect_Plus
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    JSR RegisterJumpTable
    MOVE.B D2,(A4)+ register number
    MOVE.B #$29,(A4)+ )
    MOVE.B #$2B,(A4)+ +
    RTS

An_Indirect_Minus
    MOVE.B #$2D,(A4)+ -
    MOVE.B #$28,(A4)+ (
    MOVE.B #$41,(A4)+ A
    JSR RegisterJumpTable
    MOVE.B D2,(A4)+ register number
    MOVE.B #$29,(A4)+ )
    RTS

Address_Data
    CMP.B #$0,D2 Word address
    BEQ WordAddress
    CMP.B #$1,D2 Longword address
    BEQ LongwordAddress
    CMP.B #$4,D2 immediate data
    BEQ ImmediateData
WordAddress
    MOVE.B  #$24,(A4)+ $ 
    * current address is at the start of the opcode word for example -->1234 5678
    ADDQ #2,A2 increment current reading address by 2 to get the next word or long value 1234 -->5678
    JSR WordDecodeEA
    SUBQ #2,A2
    RTS
    
LongwordAddress
    MOVE.B #$24,(A4)+ $
    ADDQ #2,A2 increment current reading address by 2 to get the next word or long value
    JSR LongDecodeEA
    SUBQ #2,A2
    RTS
ImmediateData
    MOVE.B #$23,(A4)+ #
    MOVE.B #$24,(A4)+ $
    CMP.B #1,D0 for byte
    BEQ byteID
    CMP.B #2,D0 for word
    BEQ wordID
    CMP.B #3,D0 for longword
    BEQ longID
    
byteID  
    ADDQ #2,A2  increment current reading address by 2 to get the next word or long value
    JSR ByteDecodeEA
    SUBQ #2,A2  reset for increment 
    *need to decode
    RTS
    
wordID
    ADDQ #2,A2  increment current reading address by 2 to get the next word or long value
    JSR WordDecodeEA
    SUBQ #2,A2 reset for increment
    *need to decode
    RTS

longID
    ADDQ #3,A2 increment current reading address by 2 to get the next word or long value
    JSR LongDecodeEA
    SUBQ #2,A2 reset for increment 
    *need to decode
    RTS
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
ToDATA BRA DATA    instruction not found
    
Combine_Done   RTS
      
RegisterJumpTable
    CMP.B #0,D2
    BEQ Register0
    CMP.B #1,D2
    BEQ Register1
    CMP.B #2,D2
    BEQ Register2
    CMP.B #3,D2
    BEQ Register3
    CMP.B #4,D2
    BEQ Register4
    CMP.B #5,D2
    BEQ Register5
    CMP.B #6,D2
    BEQ Register6
    CMP.B #7,D2
    BEQ Register7
Register0
    MOVE.B #$30,D2
    RTS
Register1
    MOVE.B #$31,D2
    RTS   
Register2
    MOVE.B #$32,D2
    RTS
Register3
    MOVE.B #$33,D2
    RTs
Register4
    MOVE.B #$34,D2
    RTS
Register5
    MOVE.B #$35,D2
    RTS

Register6
    MOVE.B #$36,D2
    RTS

Register7
    MOVE.B #$37,D2
    RTS

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
    MOVE.B #1,D0    

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

*Done
*-----------------------------------------------------------------------------------------------------------*
    
MOVE_2
    MOVE.B #$4D,(A4)+   M
    MOVE.B #$4F,(A4)+   O
    MOVE.B #$56,(A4)+   V
    MOVE.B #$45,(A4)+   E
    MOVE.B #$2E,(A4)+   .
    MOVE.B #$4C,(A4)+   L
    MOVE.B #$9,(A4)+   Tab for space
    MOVE.B #3,D0
    
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
    MOVE.B #$57,(A4)+   W
    MOVE.B #$9,(A4)+   Tab for space
    MOVE.B #2,D0

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


MOVEM_JRS_RTS_4
      *Not complete
      *Check for RTS
      CMP.W #$4E75,D1 Compare word value within D1 to 4E75
      BEQ RTS   if equal than it is RTS
      
      *Check for JSR
      MOVE.W D1,D0
      LSR.W #6,D0 get the first 10 binary 
      CMP.W #$013A,D0 compare word value within D1 to 013A
      BEQ JSR
      BRA ToDATA
      
JSR
    MOVE.B #$4A,(A4)+ J
    MOVE.B #$53,(A4)+ S
    MOVE.B #$52,(A4)+ R
    MOVE.B #$9,(A4)+   Tab for space

    *source
    MOVE.B D3,D2       move source register to D2
    MOVE.B D4,D7       move source mode to D7
    JSR RetrieveEA
    
        
    BRA Combine_Done


RTS
    MOVE.B #$52,(A4)+ R
    MOVE.B #$54,(A4)+ T
    MOVE.B #$53,(A4)+ S    
    BRA Combine_Done

MOVEM
    MOVE.B #$4D,(A4)+ M
    MOVE.B #$4F,(A4)+ O
    MOVE.B #$56,(A4)+ V 
    MOVE.B #$45,(A4)+ E    
    MOVE.B #$4D,(A4)+ M       


*-----------------------------------------------------------------------------------------------------------*

BLT_6
    MOVE.B #$42,(A4)+ B
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$54,(A4)+ T
    MOVE.B #$9,(A4)+  tab
CheckDisplacement
   MOVE.W D1,D2 store current word from D1 to D2
   LSL.W #8,D2 shift 8 bits to the left
   LSR.W #8,D2 shift 8 bits back to the right
   CMP.B #$00,D2 compare if the last to bits are 00 for displacement
   BEQ Positive_Displacement 16 bits
   BNE Negative_Displacement 8 bits
   
* Target=<PC>+2+displacement
Positive_Displacement
   ADD.L #2,A2 increment by 2 to get the next word
   MOVE.W (A2),D2 get the word displacement into D2
   MOVE.L A2,D1 move the current address to D1
   ADD.L #2,D1  add 2 to the current address
   ADD.L D2,D1  add current displacement to D1
   *swap word
   ROL.L #8,D1  rotate 8 bits left
   ROL.L #8,D1  rotate 8 bits left
   JSR DATA_CONVERT
   ROR.L #8,D1 rotate 8 bits right
   ROR.L #8,D1 rotate 8 bits right 
   JSR DATA_CONVERT
   RTS
   
* Target=<PC>+2+displacement
* negative
Negative_Displacement   
    NOT.B D2    ones complement of value within D2
    ADDQ #1,D2  add one to D2 for two complement
    MOVE.L A2,D1 move the current address to D1
    ADD.L #2,D1  add 2 to the current address
    SUB.L D2,D1 add current displacement to D1
*get first word first
    ROL.L #8,D1 rotate 8 bits left
    ROL.L #8,D1 rotate 8 bits left
    JSR DATA_CONVERT
*get second word
    ROR.L #8,D1 rotate 8 bits right
    ROR.L #8,D1 rotate 8 bits right
    JSR DATA_CONVERT
    RTS
            
*-----------------------------------------------------------------------------------------------------------*

OR_8
    MOVE.B #$4F,(A4)+ O
    MOVE.B #$52,(A4)+ R
    MOVE.B #$2E,(A4)+ .
    *Get Size and Syntax
    MOVE.B D5,D2    move destination mode from D5 to D2 for checking
    JMP  OPCODE_OPMODE_
    
*-----------------------------------------------------------------------------------------------------------*

CMP_11
    MOVE.B #$43,(A4)+ C
    MOVE.B #$4D,(A4)+ M
    MOVE.B #$50,(A4)+ P
    MOVE.B #$2E,(A4)+ .
    *Get Size and Syntax
    MOVE.B D5,D2    move destination mode from D5 to D2 for checking
    JMP  OPCODE_OPMODE_

*-----------------------------------------------------------------------------------------------------------*


AND_12
    MOVE.B #$41,(A4)+ A
    MOVE.B #$4E,(A4)+ N
    MOVE.B #$44,(A4)+ D
    MOVE.B #$2E,(A4)+ .
    *Get Size and Syntax
    MOVE.B D5,D2    move destination mode from D5 to D2 for checking
    JMP  OPCODE_OPMODE_

*-----------------------------------------------------------------------------------------------------------*

ADD_13
    MOVE.B #$41,(A4)+ A
    MOVE.B #$44,(A4)+ D
    MOVE.B #$44,(A4)+ D
    MOVE.B #$2E,(A4)+ .
    
    *Get Size and Syntax
    MOVE.B D5,D2    move destination mode from D5 to D2 for checking
    JMP OPCODE_OPMODE_
    
*-----------------------------------------------------------------------------------------------------------*


LSR_14
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$53,(A4)+ S
    MOVE.B #$52,(A4)+ R
    MOVE.B #$2E,(A4)+ .

    MOVE.B D5,D2    move destination mode from D5 to D2 for checking
    JMP OPCODE_OPMODE_

 *-----------------------------------------------------------------------------------------------------------*

    
DATA
    MOVE.B #$44,(A4)+ D
    MOVE.B #$41,(A4)+ A
    MOVE.B #$54,(A4)+ T
    MOVE.B #$41,(A4)+ A
    MOVE.B #$9,(A4)+ Tab
    JSR DATA_CONVERT
    RTS

*-----------------------------------------------------------------------------------------------------------*
OPCODE_OPMODE_
   CMP.B #0,D2 000 byte first syntax
   BEQ GetSize_0
   
   CMP.B #1,D2 001 word first syntax
   BEQ GetSize_1

   CMP.B #2,D2 010 long first syntax
   BEQ GetSize_2

   CMP.B #4,D2 100 byte second syntax
   BEQ GetSize_4

   CMP.B #5,D2 101 word second syntax
   BEQ GetSize_5

   CMP.B #6,D2 110 long second syntax
   BEQ GetSize_6

GetSize_0
    MOVE.B #$42,(A4)+ B
    MOVE.B #$9,(A4)+  Tab    
    MOVE.B #1,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7    
    JSR RetrieveEA
  
    MOVE.B #$2C,(A4)+ ,    
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done

GetSize_1
    MOVE.B #$57,(A4)+ W
    MOVE.B #$9,(A4)+  Tab
    MOVE.B #2,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7
    JSR RetrieveEA
    
    MOVE.B #$2C,(A4)+ ,    
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done
    
GetSize_2
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$9,(A4)+  Tab
    MOVE.B #3,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7
    JSR RetrieveEA
    
    MOVE.B #$2C,(A4)+ ,
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done

GetSize_4
    MOVE.B #$42,(A4)+ B
    MOVE.B #$9,(A4)+  Tab
    MOVE.B #1,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7
    JSR RetrieveEA
    MOVE.B #$2C,(A4)+ ,
    
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done
    
GetSize_5
    MOVE.B #$57,(A4)+ W
    MOVE.B #$9,(A4)+  Tab
    MOVE.B #2,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7
    JSR RetrieveEA
    MOVE.B #$2C,(A4)+ ,
    
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done

GetSize_6
    MOVE.B #$4C,(A4)+ L
    MOVE.B #$9,(A4)+  Tab
    MOVE.B #3,D0
    MOVE.B D3,D2 move source register to D2
    MOVE.B D4,D7 move source mode to D7
    JSR RetrieveEA
    MOVE.B #$2C,(A4)+ ,
    
    MOVE.B D6,D2
    MOVE.B #$0,D7
    JSR RetrieveEA
    BRA Combine_Done
 
*-----------------------------------------------------------------------------------------------------------*    
* Jump table subrountine that read and identify which instuction the opcode is belong to. END*
*-----------------------------------------------------------------------------------------------------------*

*   Display memory location
Display_Memory    
    *MOVE.L A2,D1    Store unsigned number in D1 for display
    *MOVE.B #16,D2   Set converted to number base 16
    *MOVE.B #15,D0   Use to display unsinged number, therefore memory location
    *TRAP #15
    MOVE.L A2,PrintMemory
    LEA PrintMemory,A5
    LEA MemBuffer,A6
    MOVE.B #0,D0 initialize for printing
MemLoop
    CMP.B #4,D0 if equal then loop is done
    BEQ MemDone
    MOVE.B (A5),D1 move current value for memory to D1 for converting first bit of byte
    MOVE.B (A5),D2 move current value for memory to D1 for converting second bit of byte
CheckByte
    *first bits
    LSR.B #4,D1 shift right to get rid of the second bit
    CMP.B #10,D1 compare 9 with value within D1
    BLT First_JumpNum if D1 is less than 9 then it is a number
    CMP.B #9,D1 compare 9 with value within D1
    BGT First_JumpLetter if D1 is greater than then it is a letter
Next
    *second bit
    LSL.B #4,D2 shift left to get rid of the first bit
    LSR.B #4,D2 shift right to get back to orginial position
    CMP.B #9,D2 compare 9 with value within D2
    BLT Second_JumpNum if D2 is less than 9 then it is a number
    CMP.B #9,D2    compare 9 with value within D2
    BGT Second_JumpLetter  if D2 is less than 9 then it is a letter

           
MemDone
    MOVE.B #$00,(A6)+ put null and the end
    LEA MemBuffer,A1
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.B #$9,D1   Tab
    MOVE.B #6,D0   Use to display unsinged number, therefore memory location
    TRAP #15
    
    CLR D1
    CLR D2
        
    RTS
    *continue here................
    
First_JumpLetter
    ADDI.B #55,D1 add 55 to current decimal to get the hex value 
*process example 'A' in decimal is 10 add 55 = 65 which is A in hex 
    MOVE.B D1,(A6)+ store current byte into the buffer
    BRA Next
    
First_JumpNum
    ADDI.B #$30,D1 add 30 to current decimal to get the hex value
*process example '0' in decimal is 0 add 30 = 30 which is 0 in hex
    MOVE.B D1,(A6)+
    BRA Next
    
Second_JumpLetter
    ADDI.B #55,D2
*process example 'A' in decimal is 10 add 55 = 65 which is A in hex 
    MOVE.B D2,(A6)+
    ADDQ #1,A5 increment to read next value
    ADDQ #1,D0 increment count to stop
    BRA MemLoop loop back
Second_JumpNum
    ADDI.B #$30,D2 add 30 to current decimal to get the hex value
*process example '0' in decimal is 0 add 30 = 30 which is 0 in hex
    MOVE.B D2,(A6)+
    ADDQ #1,A5 increment to read next value
    ADDQ #1,D0 increment count to stop
    BRA MemLoop loop back
    

    
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

*-----------------------------------------------------------------------------------------------------------*
*   Subroutine that decode effective address for word address, long address and immediate data for printing. START *
* D1 is currently use to store opcode but it is not used unless opcode is unidentified
* D0 is currently use to store flag for ea address but flag can be set again
* D2 is currently use to store instruction mode but can be set again
* D7 is currently use to store instruction register but can be set again
ByteDecodeEA
    CLR D1
    CLR D0
    MOVE.B #0,D7    initialize for printing
    MOVE.B #1,D2    flag for byte
Byte_Loop
    CMP.B #2,D7     if equal then loop is done
    BEQ EaDone
    MOVE.B (A2),D1  move current word value from A2 address to D1
    MOVE.B (A2),D0  move current word value from A2 address to D0
    BRA EA_CHECKASCII
WordDecodeEA
    CLR D1
    CLR D0
    MOVE.B #0,D7    initialize for printing
    MOVE.B #2,D2    flag for word
Word_Loop
    CMP.B #2,D7     if equal then loop is done
    BEQ EaDone
    MOVE.B (A2),D1  move current word value from A2 address to D1
    MOVE.B (A2),D0  move current word value from A2 address to D0
    BRA EA_CHECKASCII
LongDecodeEA
    CLR D1
    CLR D0
    MOVE.B #0,D7    initialize for printing
    MOVE.B #4,D2    flag for long
Long_Loop
    CMP.B #4,D7 if equal then loop is done
    BEQ EaDone  
    MOVE.B (A2),D1  move current word value from A2 address to D1
    MOVE.B (A2),D0  move current word value from A2 address to D0
    BRA EA_CHECKASCII
EA_CHECKASCII 
    *First
    LSR.B #4,D1 shift right to get rid of the second bit
    CMP.B #9,D1 compare 9 with value within D1
    BLT EA_First_JumpNum if D1 is less than 9 then it is a number
    CMP.B #9,D1 compare 9 with value within D1
    BGT EA_First_JumpLetter if D1 is greater than then it is a letter
EA_Next
    *Second
    LSL.B #4,D0 shift left to get rid of the second bit
    LSR.B #4,D0 shift right to get back to original position
    CMP.B #9,D0 compare 9 with value within D1
    BLT EA_Second_JumpNum if D1 is less than 9 then it is a number
    CMP.B #9,D0 compare 9 with value within D1
    BGT EA_Second_JumpLetter if D1 is greater than then it is a letter

EA_First_JumpNum
    ADDI.B #$30,D1
    MOVE.B D1,(A4)+
    BRA EA_Next

EA_First_JumpLetter
    ADDI.B #55,D1
    MOVE.B D1,(A4)+
    BRA EA_Next
    
EA_Second_JumpNum
    ADDI.B #$30,D0
    MOVE.B D0,(A4)+
    ADDQ   #1,A2    increment current address to read next byte
    ADDQ   #1,D7
    BRA    LoopTable 

EA_Second_JumpLetter
    ADDI.B #55,D0
    MOVE.B D0,(A4)+
    ADDQ   #1,A2    increment current address to read next byte
    ADDQ   #1,D7
    BRA LoopTable
    
LoopTable
    CMP.B #1,D2 if equal 1 then go to byte loop
    BEQ Byte_Loop
    CMP.B #2,D2 if equal 2 then go to word loop
    BEQ Word_Loop
    CMP.B #4,D2 if equal 4 then go to long loop
    BEQ Long_Loop
EaDone
    RTS
*   Subroutine that decode effective address for word address, long address and immediate data for printing. END *
*-----------------------------------------------------------------------------------------------------------*
    

*-----------------------------------------------------------------------------------------------------------*
* D2 currently store the first bit of opcode word
DATA_CONVERT
    MOVE.W D1,D2
    *get first bits
    LSR.W #8,D2   shift right 8 bits
    LSR.W #4,D2   shift right 4 bits
    JSR DataJump
    *get second bits
    MOVE.W D1,D2
    LSL.W #4,D2 shift left 4 bits to get rid of first value
    LSR.W #4,D2 shift right 4 bits back
    LSR.W #8,D2 shift right 8 bits
    JSR DataJump
    *get third bits
    MOVE.W D1,D2
    LSL.W #8,D2 shift left 8 bits to get rid of first,second value
    LSR.W #8,D2 shift right 8 bits back
    LSR.W #4,D2 shift right 4 right 
    JSR DataJump
    MOVE.W D1,D2
    LSL.W #8,D2 shift left 8 bits to get rid of first,second 
    LSL.W #4,D2 shift left 4 bits to get rid of third
    LSR.W #8,D2 shift right 8 bits back
    LSR.W #4,D2 shift left 4 bits back
    JSR DataJump
    RTS
DataJump
    CMP.B #10,D2
    BLT Data_Num
    CMP.B #9,D2
    BGT Data_Letter

Data_Num
    ADDI.B #$30,D2
    MOVE.B D2,(A4)+
    RTS
Data_Letter 
    ADDI.B #55,D2
    MOVE.B D2,(A4)+
    RTS
 
    






*-----------------------------------------------------------------------------------------------------------*

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
                DC.B '||                                                        ||',CR,LF
                DC.B '||   #####      ###    ##   ##                            ||',CR,LF
                DC.B '||  ##        ##   ##  ## ##                              ||',CR,LF
                DC.B '|| ## ####     #####   ####                               ||',CR,LF
                DC.B '|| ##    ##  ##    ##  ####                               ||',CR,LF
                DC.B '|| ##    ##  ##    ##  ## ##                              ||',CR,LF
                DC.B '||  #####     ######   ##  ##                             ||',CR,LF
                DC.B '||                                                        ||',CR,LF

                DC.B 'To start program please enter the starting and ending addresses asked below',CR,LF,CR,LF,0
  
STARTING_ADDRESS_MESSAGE   DC.B    'Please enter the starting address hexadecimal length of 6: ',0
ENDING_ADDRESS_MESSAGE     DC.B    'Please enter the ending address hexadecimal length of 6: ',0
PRESS_ENTER_MESSAGE        DC.B    'Please press enter to display more',CR,LF,CR,LF,0
ERROR_MESSAGE_LENGTH_GREATER   DC.B    'Please re-enter the address with length less than 6',0
ERROR_MESSAGE_LENGTH_EQUAL     DC.B    'Please enter something here for the first address',0
StartingAddress     DC.L    1
EndingAddress       DC.L    1
PrintLimit          DC.B    10
CurrentLine         DC.B    1
PrintMemory         DC.L    1
MemBuffer           DCB.B   9,0
EABuffer            DC.B    1
CombineOperation    DC.B    1

    END    START        ; last line of source




