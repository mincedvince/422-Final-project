Deliverable: You must submit item 1, item 2, item 3, and item 4 in Final Project, and item 5 to Confidential Individual Evaluation (try not to zip)

1.
Source code: Please submit your source file (.X68). Your source file name should be, <Team name>.X68

If you have multiple files, you may zip all files, and name your zip file as <Team name>.zip. PLEASE ONLY ZIP .X68 FILES!

2.
Testing file: modify the testing files (demo_test.X68) download   so that it can properly run with your program.

3.
Documentation. 

Single line spacing, any font with 11 pts. 
Should include all the following sections and make it as one documentation. 

1) Program description: This is a write-up of 1 to 2 pages about your program.  Describe your design philosophy, flow chart, 
any algorithms that you were especially proud of, any algorithms that you got from other sources ( copied, downloaded, etc. ). 
The program description should also cover any limitations that you are aware of.

2) Specification: 1~2 pages. Clearly describe what your program can do,  and list your design and implementation 
specifications. List the required opcode and addressing modes. 

3) Test Plan: 1~2 pages. This is a description of how you tested the program. It should also contain a description of your 
team’s coding standards. Describe how you modified the demo_test program and why.

4) Exception report: This is your opportunity to describe problems that you’ve encountered but couldn't fix, or chose not to 
fix. Anything that you feel deviates from your intended program. Also, this is where you can describe what you were able to 
complete in the time allotted versus what the assignment asked for. This should definitely include the results of your testing if 
you found defects but didn't fix them. In an ideal situation, I should be able to just read your documentation and your source 
listing and give you a grade, without needing to run the program. Of course, I will run the program, but I hope that you get the idea.

5) Team assignments and report: A description of how you organized your team’s tasks. That is, "Who did what and how". 
You should specify the amount of the coding, as a percentage, the member did in the project. This information is VERY important
as it will be a source for the separate grading.

4.
Project demo video: You have to make a video that demonstrate your program running with a testing file.
It should include the followings  (you can make it as slides and record it)

List of I/O, opcode and EAs that have been completed
List of the works that have not been completed
Demonstrate your program. Should show very clearly how to run your program, what testing file is used, what inputs you 
gave, and show the outputs. Note that the demo file include most of, but not all of, the required opcodes. 
Any problems that you had, or any comments

5.
Confidential evaluation report : Note that this is a separate file to be submitted individually. (Confidential Individual Evaluation)
Each member of the team submits their own evaluation.

What you did on the project
What the other team members did on the project
An estimate of the percentage of the project that you contributed
An estimate of the percentage of the project that each of your team mates completed

Your individual grade on the project may be different from the project grade as a whole. If other team members report that
someone is not doing their fair share, then I will use that information, along with your statements to adjust the grades of the 
individual team members. Thus, if any member or members of a project group feels that the other team member(s) are not doing, 
or did not do, their fair share of the work the student should contact the instructor as soon as possible. 

Most cases, a team will share the same grade, but there will be exceptions if necessary.

Each team member's project point is first given based on final product. Then, based on the confidential evaluation report, 
members whose contribution are too low, will have additional point reduction.

6.
The program will be carefully tested for all required op-code and EAs. Here are some examples where points are deduced.
1) If your program did not disassemble any of the 3 additional op-codes, you will got program point 0 out of 70
2) Program cannot assemble into listing file: program point is 0 out of 70
3) Program crashes on non-required opcode or EA: -5
4) Program crashes on each required opcode or EA: -7 each
5) Each required op-code or EA which is not properly disassembled: -5 each
6) Program does not print the address of each instruction: -5
7) Program does not print results as one screen at a time: -5
8) Program does not have options to restart or finish: -5

The documentation should include enough information about your program, and clearly describe your product in general. 
Especially, since each group have different op-code options, clearly describe about them. Also the exception report should 
provide all the exceptions of your program. Missing some exception cases mean you did not test thoroughly, and will cause some points off. 


Progress report 1

1. Make a table that matches all the required opcode/EA with the machine code. Please include the table in your report. 
2. Start designing the program by providing a simple flow-chart. At this moment, it might not be easy to design details.
So this time, provide a flow-chart to start with, and you will have a chance to revise.


Progress report 2

1. Make a subroutine that reads a user input (starting and ending address) and save them to Address registers as 
a hexadecimal numbers. Remember you can use up trap task #14, so you cannot automatically convert the user input 
as hexadecimal number. You have to make a subroutine that reads the user input as string, and convert it to hexadecimal.  
2. Please start with a flowchart for this portion and submit the flow-chart AND the source file (.X68).
The flowchart will help me understand your code, and also help you verify your code logic. The flowchart should be 
included into your report. Source file should be separate. You can have an alternative way to convert it as an hexadecimal.
If any of them is missing, this submission is considered incomplete.
