`timescale 1ns / 1ps

module doubdab_8bits(
    input [7:0] b_in,
    output [11:0] bcd_out
    );

//
// Fill in the connections and wires to implement the double-dabble algorithm
//  
//   
    dd_add3 u1 ();
    
    dd_add3 u2 ();

    dd_add3 u3 ();
    
    dd_add3 u4 ();
    dd_add3 u6 ();
    
    dd_add3 u5 ();
    dd_add3 u7 ();
     
endmodule
