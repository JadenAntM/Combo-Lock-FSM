# Combo-Lock-FSM

Ive created a moore finite state machine that is programmed in Verilog. This is a combination lock where the user has to input a certain combination. This is using the FPGA De1-s0c board.

Functions: 
- The user can input their desired password using the 4 input switches
- The lock will not be able to be opened unless the user inputs the correct password
- Doors will open the when the right input is set and the enter key is pressed
- The user can set a new password if the correct password input is set and the change key is pressed. The user can then set their desired password
- If the user presses enter twice and the password input is wrong then the alarm will be activated
