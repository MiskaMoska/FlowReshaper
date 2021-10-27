`timescale 1ns/1ns

module test_FlowReshaper();
reg ena,clk,rstn;
wire rd_en;
wire [19:0] ram_addr;
reg [7:0] ram_dout;
wire [7:0] wr_data;
integer file_id; 
reg wr_en_1;

(* ramstyle = "AUTO" *) reg [7:0] data_ram [0:76799]; 
always@(posedge clk or negedge rstn) begin
    if(~rstn) ram_dout <= 0;
    else ram_dout <= data_ram[ram_addr];
end

initial begin
    $readmemh("F:/vivado_proj/FlowReshaper/srcs_opt/test.txt",data_ram);
    file_id = $fopen("F:/vivado_proj/FlowReshaper/srcs_opt/test_output.txt");
    ena = 0;clk = 0;rstn = 1;
    # 33 rstn = 0;
    # 70 rstn = 1;
    # 10 ena = 1;
    # 30 ena = 0;
    #2000000 
    $fclose(file_id);
    $stop;
end

always #2.5 clk = ~clk;

always@(posedge clk)
begin
    wr_en_1 <= wr_en;
    if(wr_en_1)
        $fwrite(file_id, "%h\n", wr_data);
end

FlowReshaper reshaper(
    .clk                       (clk),
    .rstn                      (rstn),
    .rd_en                     (rd_en),
    .rd_addr                   (ram_addr),
    .rd_data                   (ram_dout),
    .wr_en                     (wr_en),
    .wr_addr                   (),
    .wr_data                   (wr_data),
    .ena                       (ena)
);


endmodule