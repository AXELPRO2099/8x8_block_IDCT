`timescale 1ns / 1ps

module top(
input wire signed [15:0] x [0:7][0:7],
input sys_clk, sys_rst, start,
output logic done,
output logic [7:0] pixel_out [0:7][0:7]
);

typedef enum logic [1:0] {
IDLE = 2'b00,
LOAD = 2'b01,
BUSY = 2'b10,
DONE = 2'b11
}states_t;
states_t state;

localparam logic signed [15:0] cosine [0:7][0:7] = '{
// u   0          1        2          3         4         5         6         7                x
    '{16384,    16069,   15137,    13623,     11585,    9102,     6270,     3196   },         // 0    
    '{16384,    13623,   6270,    -3196,     -11585,    -16069,   -15137,   -9102  },         // 1 
    '{16384,    9102,   -6270,    -16069,     -11585,    3196,   15137,    13623   },         // 2  
    '{16384,    3196,   -15137,   -9102,     11585,     13623,   -6270,    -16069  },         // 3   
    '{16384,    -3196,   -15137,   9102,     11585,     -13623,  -6270,    16069   },         // 4 
    '{16384,    -9102,   -6270,    16069,     -11585,    -3196,  15137,    -13623  },         // 5 
    '{16384,    -13623 ,  6270,    3196,     -11585,    16069,  -15137,    9102    },         // 6 
    '{16384,    -16069 ,  15137,  -13623,     11585,    -9102,   6270,     -3196   }          // 7   
};

reg signed [15:0] C_u;
reg [3:0] row_count, col_count, r_element, i, j;
//logic signed [15:0] x [0:7][0:7];
reg signed [31:0] row_data_out [0:7][0:7];
logic signed [15:0] col_data_in [0:7][0:7];
reg signed [31:0] col_data_out [0:7][0:7];
reg signed [7:0] y [0:7][0:7];
/*
generate
    if(row_count > 7) begin
        for (genvar i = 0; i < 8; i++) begin : row_init
            for (genvar j = 0; j < 8; j++) begin : col_init
                // Assign values based on indices
                assign col_data_in[i][j] = (row_data_out[j][i] + 16384) >>> 15;
            end
        end
    end
    if(col_count
    for (genvar i = 0; i < 8; i++) begin : final_row_init
        for (genvar j = 0; j < 8; j++) begin : final_col_init
            // Assign values based on indices
            assign pixel_out[i][j] = (col_data_out[j][i] + 8388608) >>> 23;
        end
    end
endgenerate*/

always_comb begin
    /*for(int i = 0; i < 8; i++) begin
        for(int j = 0; j < 8; j++) begin
            pixel_out[i][j] = (y[i][j] + 128)>> 1;
        end
    end*/
    if(row_count > 7) begin
        if(col_count < 8) begin
        //if(row_count > 7) begin
            for (int i = 0; i < 8; i++) begin 
                for (int j = 0; j < 8; j++) begin 
                    // Assign values based on indices
                    
                    col_data_in[i][j] = (row_data_out[j][i] + 16384) >>> 15;
                end
            end
        end
        else begin
            for (int i = 0; i < 8; i++) begin 
                for (int j = 0; j < 8; j++) begin 
                    // Assign values based on indices
                    y[i][j] = (col_data_out[j][i] + 8388608) >>> 23;
                    pixel_out[i][j] = (y[i][j] * 128) >> 1;
                end
            end
        end
    end
    else begin
        for (int i = 0; i < 8; i++) begin : row_init
            for (int j = 0; j < 8; j++) begin : col_init
                // Assign values based on indices
                pixel_out[i][j] = 0;
            end
        end
    end
    /*else if(col_count > 7 && row_count > 7) begin
        for (int i = 0; i < 8; i++) begin : row_init
            for (int j = 0; j < 8; j++) begin : col_init
                // Assign values based on indices
                pixel_out[i][j] = (col_data_out[j][i] + 8388608) >>> 23;
            end
        end
    end*/
    //else begin
    
    /*    for (int i = 0; i < 8; i++) begin : row_init
            for (int j = 0; j < 8; j++) begin : col_init
                // Assign values based on indices
                pixel_out[i][j] = 0;
            end
        end
    end*/
    //if(col_count>7) begin
    //end
end

always_ff @(posedge sys_clk) begin
    if(sys_rst) begin
        state <= IDLE;
    end
    /*else if(start) begin
        state <= LOAD;
    end*/
    else begin
        case(state) 
            IDLE: begin
                done <= 0;
                r_element <= 0;
                //c_element <= 0;
                row_count <= 0;
                col_count <= 0;
                i <= 0;
                j <= 0;
                for(int i=0; i<8; i++) begin
                    for(int j=0; j<8; j++) begin
                        row_data_out[i][j] <= 0;
                        col_data_out[i][j] <= 0;
                    end
                end
                state <= start? LOAD : IDLE;
                
                
            end
            LOAD: begin
                state <= BUSY;
            end
            BUSY: begin
                if(row_count < 8)begin
                    if(r_element < 8) begin
                        //row_data_out[row_count][r_element] = 0;
                        //for(int i=0; i<8; i++) begin
                        if(i < 8) begin
                            C_u = (i==0)? 11585 : 16384;
                            /*if(i==0) begin
                                row_data_out[row_count][r_element] = row_data_out[row_count][r_element] +(x[row_count][i] * 11585 * cosine[r_element][i]);
                            end
                            else begin*/
                            row_data_out[row_count][r_element] = row_data_out[row_count][r_element] +(x[row_count][i] * C_u * cosine[r_element][i]);
                            //end
                            i <= i + 1;
                        end
                        else begin
                            r_element <= r_element + 1;
                            i <= 0;
                        end
                    end
                    else begin 
                        row_count <= row_count + 1;
                        r_element <= 0;
                        //i <= 0;
                    end
                end
                else if(col_count < 8) begin 
                    if(r_element < 8) begin
                        //col_data_out[col_count][r_element] = 0;
                        //for(int i=0; i<8; i++) begin
                        if(j<8) begin
                            C_u = (j==0)? 11585 : 16384;
                            /*if(i==0) begin
                                col_data_out[col_count][r_element] = col_data_out[col_count][r_element] +(col_data_in[col_count][i] * 11585 * cosine[r_element][i]);
                            end
                            else begin*/
                            col_data_out[col_count][r_element] = col_data_out[col_count][r_element] +(col_data_in[col_count][i] * C_u * cosine[r_element][i]);
                            j <= j + 1;
                            //end
                        end
                        else begin
                            r_element <= r_element + 1;
                            j <= 0;
                        end
                    end
                    else begin 
                        col_count <= col_count + 1;
                        r_element <= 0;
                        //j <= 0;
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
