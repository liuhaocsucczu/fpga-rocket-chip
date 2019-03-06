module uart(
	input clock,
	input resetn,
	//full axi4 port from crossbar
    output        uart_axi4_aw_ready, 
    input         uart_axi4_aw_valid, 
    input  [3:0]  uart_axi4_aw_id, 
    input  [30:0] uart_axi4_aw_addr, 
    input  [7:0]  uart_axi4_aw_len, 
    input  [2:0]  uart_axi4_aw_size, 
    input  [1:0]  uart_axi4_aw_burst, 
    output        uart_axi4_w_ready, 
    input         uart_axi4_w_valid, 
    input  [63:0] uart_axi4_w_data, 
    input  [7:0]  uart_axi4_w_strb, 
    input         uart_axi4_w_last, 
    input         uart_axi4_b_ready, 
    output        uart_axi4_b_valid, 
    output [3:0]  uart_axi4_b_id, 
    output [1:0]  uart_axi4_b_resp, 
    output        uart_axi4_ar_ready, 
    input         uart_axi4_ar_valid, 
    input  [3:0]  uart_axi4_ar_id, 
    input  [30:0] uart_axi4_ar_addr, 
    input  [7:0]  uart_axi4_ar_len, 
    input  [2:0]  uart_axi4_ar_size, 
    input  [1:0]  uart_axi4_ar_burst, 
    input         uart_axi4_r_ready, 
    output        uart_axi4_r_valid, 
    output [3:0]  uart_axi4_r_id, 
    output [63:0] uart_axi4_r_data, 
    output [1:0]  uart_axi4_r_resp, 
    output        uart_axi4_r_last,

    input uart_RX,
    output uart_TX
	);

    assign uart_axi4_r_data[63:32] = uart_axi4_r_data[31:0];
    
    // provided ip is axilite, transform axi4 to axilite
    wire    [3:0]   lite_ar_id;          // be driven
    wire    [12:0]  lite_ar_addr;        
    wire            lite_ar_valid;       
    wire            lite_ar_ready;  
    wire    [3:0]   lite_r_id;           // =0
    wire    [31:0]  lite_r_data;         
    wire    [1:0]   lite_r_resp;         
    wire            lite_r_valid;        
    wire            lite_r_ready;   
    wire    [3:0]   lite_aw_id;          //be driven
    wire    [12:0]  lite_aw_addr;       
    wire            lite_aw_valid;       
    wire            lite_aw_ready;    
    wire    [31:0]  lite_w_data;         
    wire    [3:0]   lite_w_strb;         
    wire            lite_w_valid;        
    wire            lite_w_ready;    
    wire    [3:0]   lite_b_id;           // =0
    wire    [1:0]   lite_b_resp;         
    wire            lite_b_valid;        
    wire            lite_b_ready;        
    
    wire [3:0] uart_axi4_w_strb_half; // quite strange the strategy of strb, since we shrink the width from 64 to 32 , we choose that valid half of the strb.
    assign uart_axi4_w_strb_half = (uart_axi4_w_strb[7:4] == 0)? uart_axi4_w_strb[3:0]:uart_axi4_w_strb[7:4];

    nasti_lite_bridge bridge_inst (
    
    .clk    (clock),
    .rstn   (resetn),
    .lite_slave_ar_id          (lite_ar_id    ),
    .lite_slave_ar_addr        (lite_ar_addr  ),
    .lite_slave_ar_valid       (lite_ar_valid ),
    .lite_slave_ar_ready       (lite_ar_ready ),
    .lite_slave_r_id           (lite_r_id     ),
    .lite_slave_r_data         (lite_r_data   ),
    .lite_slave_r_resp         (lite_r_resp   ),
    .lite_slave_r_valid        (lite_r_valid  ),
    .lite_slave_r_ready        (lite_r_ready  ),
    .lite_slave_aw_id          (lite_aw_id    ),
    .lite_slave_aw_addr        (lite_aw_addr  ),
    .lite_slave_aw_valid       (lite_aw_valid ),
    .lite_slave_aw_ready       (lite_aw_ready ),
    .lite_slave_w_data         (lite_w_data   ),
    .lite_slave_w_strb         (lite_w_strb   ),
    .lite_slave_w_valid        (lite_w_valid  ),
    .lite_slave_w_ready        (lite_w_ready  ),
    .lite_slave_b_id           (lite_b_id     ),
    .lite_slave_b_resp         (lite_b_resp   ),
    .lite_slave_b_valid        (lite_b_valid  ),
    .lite_slave_b_ready        (lite_b_ready  ),
    //// ATTENTION this may cause problems
    // we gonna omit the high32 bit of a write request.
    .nasti_master_ar_id          (uart_axi4_ar_id    ),   
    .nasti_master_ar_addr        (uart_axi4_ar_addr[12:0]  ),   
    .nasti_master_ar_len         (uart_axi4_ar_len   ),   
    .nasti_master_ar_size        (uart_axi4_ar_size  ),   
    .nasti_master_ar_burst       (uart_axi4_ar_burst ),  
    .nasti_master_ar_valid       (uart_axi4_ar_valid ),   
    .nasti_master_ar_ready       (uart_axi4_ar_ready ),   
    .nasti_master_r_id           (uart_axi4_r_id     ),   
    .nasti_master_r_data         (uart_axi4_r_data[31:0]   ),   
    .nasti_master_r_resp         (uart_axi4_r_resp   ),   
    .nasti_master_r_last         (uart_axi4_r_last   ),   
    .nasti_master_r_valid        (uart_axi4_r_valid  ),   
    .nasti_master_r_ready        (uart_axi4_r_ready  ),
    .nasti_master_aw_id          (uart_axi4_aw_id    ),
    .nasti_master_aw_addr        (uart_axi4_aw_addr[12:0]  ),
    .nasti_master_aw_len         (uart_axi4_aw_len   ),
    .nasti_master_aw_size        (uart_axi4_aw_size  ),
    .nasti_master_aw_burst       (uart_axi4_aw_burst ),
    .nasti_master_aw_valid       (uart_axi4_aw_valid ),
    .nasti_master_aw_ready       (uart_axi4_aw_ready ),
    .nasti_master_w_data         (uart_axi4_w_data[31:0]   ), //// ATTENTION, this may cause problems, but it seems that AXI will copy the lower 32 bit data to the higher 32 ones, when send a 32bit data to 64bit bus
    .nasti_master_w_strb         (uart_axi4_w_strb_half   ),
    .nasti_master_w_last         (uart_axi4_w_last   ),
    .nasti_master_w_valid        (uart_axi4_w_valid  ),
    .nasti_master_w_ready        (uart_axi4_w_ready  ),
    .nasti_master_b_id           (uart_axi4_b_id     ),
    .nasti_master_b_resp         (uart_axi4_b_resp   ),
    .nasti_master_b_valid        (uart_axi4_b_valid  ),
    .nasti_master_b_ready        (uart_axi4_b_ready  )

    );
    
    axi_uart16550_0 uart16550_inst(

    .s_axi_aclk     (clock),
    .s_axi_aresetn  (resetn),
    .s_axi_awaddr   (lite_aw_addr),
    .s_axi_awvalid  (lite_aw_valid),
    .s_axi_awready  (lite_aw_ready),
    .s_axi_wdata    (lite_w_data),
    .s_axi_wstrb    (lite_w_strb),
    .s_axi_wvalid   (lite_w_valid),
    .s_axi_wready   (lite_w_ready),
    .s_axi_bresp    (lite_b_resp),
    .s_axi_bvalid   (lite_b_valid),
    .s_axi_bready   (lite_b_ready),
    .s_axi_araddr   (lite_ar_addr),
    .s_axi_arvalid  (lite_ar_valid),
    .s_axi_arready  (lite_ar_ready),
    .s_axi_rdata    (lite_r_data),
    .s_axi_rresp    (lite_r_resp),
    .s_axi_rvalid   (lite_r_valid),
    .s_axi_rready   (lite_r_ready),

    .sin (uart_RX),
    .sout (uart_TX),
    
    .freeze (1'b0),
    .rin (1'b1),
    .dcdn (1'b1),
    .dsrn (1'b1)
    
    );
endmodule
