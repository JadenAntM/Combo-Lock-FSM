module combolock(CLOCK_50, Validate, Resetn, Modify, output_display, d3, d2, d1, d0, modifypulse, validatepulse);

    integer attempt_count = 0;
    input d3, d2, d1, d0;
    input CLOCK_50, Validate, Resetn, Modify;
    output [1:7] output_display;
    output modifypulse, validatepulse;
    reg [1:0] state;
    reg [3:0] code = 4'b0110;
    parameter idle = 2'b00, access= 2'b01, set_new = 2'b10, alert = 2'b11;
    
    signalcondition modify_trigger(CLOCK_50, Modify, modifypulse);

    signalcondition validate_trigger(CLOCK_50, Validate, validatepulse);

    displayconverter display_state(state, output_display);
    
    always @(negedge Resetn, posedge CLOCK_50)
    begin 
        if (Resetn == 0)
        begin 
            state <= idle;
            attempt_count = 0;
            code <= 4'b0110;
        end 
        else
            case(state)
                idle: if(validatepulse == 1)
                        if(code == {d3, d2, d1, d0})
                        begin 
                            attempt_count = 0;
                            state <= access;
                        end
                        else
                            if(attempt_count > 0)
                                state <= alert; 
                            else
                                attempt_count = attempt_count + 1;
                                
                     else if(modifypulse == 1 & {d3, d2, d1, d0} == code)
                        state <= set_new;
                        
                access: if(validatepulse == 1)
                                  state <= idle;
                
                set_new: if(validatepulse == 1 | modifypulse == 1)
                          begin 
                            code <= {d3, d2, d1, d0};
                            state <= idle;
                          end
            endcase
    end
    
endmodule 

module inputcond(CLOCK_50, Activation, triggered_pulse);
    input CLOCK_50, Activation;
    reg [1:0] current_state, Next_state;
    output triggered_pulse;
    parameter Active = 2'b00, Triggered = 2'b01, Held = 2'b10;
    
    always@(negedge Activation, posedge CLOCK_50)
    begin
        case(current_state)
            Active: if(Activation == 0) Next_state = Activation;
                    else Next_state = Triggered;
            
            Triggered: if (Activation == 0) Next_state = Activation;
                       else Next_state = Held;
            Held: if (Activation == 0) Next_state = Activation;
                  else Next_state = Held;
            
            default: Next_state= 2'bxx;
        endcase
    end
    
    always@(posedge CLOCK_50)
    begin
        current_state <= Next_state;
    end
    
    assign triggered_pulse = (current_state == Triggered);
    
endmodule

module hexdisp (convert_state, converted_display);
    input [1:0] convert_state;
    output reg [1:7] converted_display;
    
    always @(convert_state)
    begin
        case(convert_state)
            2'b00: converted_display = 7'b1111110;

            2'b01: converted_display = 7'b1100010;

            2'b10: converted_display = 7'b1101010;

            2'b11: converted_display = 7'b0001000;
        endcase
    end
endmodule
