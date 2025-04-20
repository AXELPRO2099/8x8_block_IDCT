`timescale 1ns / 1ps

module idct_tb;
    //Inputs
    reg clk;
    reg reset;
    reg start;
    reg signed [15:0] coeff_in [0:7][0:7];
    //Outputs
    wire [7:0] pixel_out [0:7][0:7];
    wire done;
    //internals signals
    wire [1:0] state_wire; 
    wire [3:0] row_count, col_count, r_element, i, j;
    wire signed [31:0] col_data [0:7][0:7];
    wire signed [31:0] row_data [0:7][0:7];

    // Test vectors
    //Test input 1
    reg signed [15:0] test_input [0:7][0:7] = '{
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd1024,    16'd0,    16'd0,   16'd0},
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},       //Checkerboard inputs
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},
    '{16'd1024, 16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0},
    '{16'd0,    16'd0,    16'd0,    16'd0,   16'd0,       16'd0,    16'd0,   16'd0}
    };
    
    //Test input 2
    /*reg signed [15:0] test_input [0:7][0:7] = '{
    '{16'd0, 16'd1024, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},                             //Single AC input
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
    '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0}
    };*/
    /*
    
    //Test Input 3
    reg signed [15:0] test_input [0:7][0:7] = '{
        '{16'd1024, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},                         //DC input
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0},
        '{16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0}
    };*/

    // Expected output (all 128 due to DC coefficient only)
    
    //Expected Output 1
    reg [7:0] expected_output [0:7][0:7] = '{
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128},
    '{ 16'd128, 16'd0, 16'd0, 16'd128, 16'd128, 16'd0, 16'd0, 16'd128}
    };
    
    ////Expected Output 2
    /*reg [7:0] expected_output [0:7][0:7] = '{
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0},
    '{16'd128, 16'd0, 16'd192, 16'd64, 16'd64, 16'd192, 16'd128, 16'd0}
};*/

    //Expected Output 3
    /*reg [7:0] expected_output [0:7][0:7] = '{
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128},
        '{8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128, 8'd128}
    };*/
    
    // top level module instantiation as DUT
    top dut (
        .sys_clk(clk),
        .sys_rst(reset),
        .start(start),
        .x(coeff_in),
        .done(done),
        .pixel_out(pixel_out)
    );

    // Internal signals to monitor
    assign state_wire = dut.state;
    assign col_data = dut.col_data_out;
    assign row_data = dut.row_data_out;
    assign col_count = dut.col_count;
    assign row_count = dut.row_count;
    assign r_element = dut.r_element;
    assign i = dut.i;
    assign j = dut.j;

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initial condition
        reset = 1;
        start = 0;
        
        //data_in
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                coeff_in[i][j] = 0;
            end
        end

        // Apply reset for a longer duration (5 clock cycles)
        #50 reset = 0;

        // giving test input
        #10;
        
        
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                coeff_in[i][j] = test_input[i][j];
            end
        end

        // Pulse start for 1 clock cycle
        #10 start = 1;
        #10 start = 0;

        // Simulation take 12 us for complete process
        #15000;
        //$display("Simulation reached 2000 ns.");
        $finish;

        
        
    end

    // Monitor
    initial begin
        $monitor("Time=%0t: done=%b, pixel_out[0][0]=%h, state=%s, row=%0d, col=%0d, element=%0d, col_data=%h, row_data=%h, i=%d, j=%d",
                 $time, done, pixel_out[0][0], dut.state, row_count, col_count, r_element, col_data[0][0], row_data[0][0], i, j);
    end
endmodule