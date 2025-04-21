`timescale 1ns / 1ps
module top(
input wire signed [15:0] x [0:7][0:7],
input sys_clk, sys_rst, start,
output reg done,
output logic [7:0] pixel_data [0:7][0:7]
);

//cos((2x+)*u*pi/)
localparam logic signed [15:0] cosine [0:7][0:7] = '{
'{16384,    16069,   15137,    13623,     11585,    9102,     6270,     3196       },
'{16384,    13623,   6270,    -3196,     -11585,    -16069,   -15137,   -9102   },
'{16384,    9102,   -6270,    -16069,     -11585,    3196,   15137,    13623   },
'{16384,    3196,   -15137,   -9102,     11585,     13623,   -6270,    -16069   },
'{16384,    -3196,   -15137,   9102,     11585,     -13623,  -6270,    16069  },
'{16384,    -9102,   -6270,    16069,     -11585,    -3196,  15137,    -13623  },
'{16384,    -13623 ,  6270,    3196,     -11585,    16069,  -15137,    9102     },
'{16384,    -16069 ,  15137,  -13623,     11585,    -9102,   6270,     -3196 }
};

//FSM parameters
typedef enum logic [1:0] {
IDLE = 2'b00,
LOAD = 2'b01,
BUSY = 2'b10,
DONE = 2'b11
}state_type;

state_type state;

reg [3:0] row_count, col_count, element, i, j;
reg signed [31:0] row_data_out [0:7][0:7];
reg signed [31:0] col_data_out [0:7][0:7];
logic signed [15:0] col_data_in [0:7][0:7];
reg signed [15:0] C_u;
reg signed [7:0] y [0:7][0:7];

always_comb begin
    if(row_count > 7) begin
        if(col_count < 8) begin
            for(int i=0; i<8; i++) begin
                for(int j=0; j<8; j++) begin
                    col_data_in[i][j] = (row_data_out[j][i] + 16384) >>> 15;  //32 bit to 16 bit
                end
            end
        end
        else begin
            for(int i=0; i<8; i++) begin
                for(int j=0; j<8; j++) begin
                    y[i][j] = (col_data_out[j][i] + 8388608) >>> 23;
                    pixel_data[i][j] = (y[i][j] * 128) >> 1;                         // y (-128 to 127) pixel_data(0 to 255)
                end
            end
        end
    end
    else begin
        for(int i=0; i<8; i++) begin
            for(int j=0; j<8; j++) begin
                pixel_data[i][j] = 0;                         
            end
        end
    end
end




//FSM transition logic using always_ff block
always_ff @(posedge sys_clk) begin
    if(sys_rst) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
               row_count <= 0;
               col_count <= 0;
               element <= 0;
               i <= 0;
               j <= 0; 
               done <= 0;
               state <= start? LOAD : IDLE;
            end
            LOAD: begin
                for(int i=0; i<8; i++) begin
                    for(int j=0; j<8; j++) begin
                        row_data_out[i][j] <= 0;
                        col_data_out[i][j] <= 0;
                    end
                end
                state <= BUSY;
            end
            BUSY: begin
                if(row_count < 8) begin
                    if(element < 8) begin
                        if(i < 8) begin
                            C_u = (i==0)? 11585 : 16384;
                            row_data_out[row_count][element] = row_data_out[row_count][element] + (x[row_count][i] * C_u * cosine[element][i]);
                            i <= i+1;
                        end
                        else begin
                            element <= element + 1;
                            i <= 0;
                        end
                    end
                    else begin
                        row_count <=row_count + 1;
                        element <= 0;
                    end
                end
                else if(col_count < 8) begin
                    if(element < 8) begin
                        if(j < 8) begin
                            C_u = (j==0)? 11585 : 16384;
                            col_data_out[col_count][element] = col_data_out[col_count][element] + (col_data_in[col_count][j] * C_u * cosine[element][j]);
                            j <= j+1;
                        end
                        else begin
                            element <= element + 1;
                            j <= 0;
                        end
                    end
                    else begin
                        col_count <=col_count + 1;
                        element <= 0;
                    end
                end
                else begin
                    state <= DONE;
                end
            end
            DONE: begin
                done <= 1;
                state <= DONE;
            end
        endcase
    end
end
endmodule
