// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:rv_pl_ip:1.0
// IP Revision: 2

(* X_CORE_INFO = "rv_pl_ip,Vivado 2021.2" *)
(* CHECK_LICENSE_TYPE = "ip_integrator_rv_pl_ip_0_0,rv_pl_ip,{}" *)
(* CORE_GENERATION_INFO = "ip_integrator_rv_pl_ip_0_0,rv_pl_ip,{x_ipProduct=Vivado 2021.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=rv_pl_ip,x_ipVersion=1.0,x_ipCoreRevision=2,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,ADDR_WIDTH=12}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module ip_integrator_rv_pl_ip_0_0 (
  clk,
  resetn,
  i_clkb,
  i_enb,
  i_web,
  i_addrb,
  i_dinb,
  i_doutb,
  d_clkb,
  d_enb,
  d_web,
  d_addrb,
  d_dinb,
  d_doutb
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET resetn, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN ip_integrator_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 resetn RST" *)
input wire resetn;
output wire i_clkb;
output wire i_enb;
output wire [3 : 0] i_web;
output wire [31 : 0] i_addrb;
output wire [31 : 0] i_dinb;
input wire [31 : 0] i_doutb;
output wire d_clkb;
output wire d_enb;
output wire [3 : 0] d_web;
output wire [31 : 0] d_addrb;
output wire [31 : 0] d_dinb;
input wire [31 : 0] d_doutb;

  rv_pl_ip #(
    .ADDR_WIDTH(12)
  ) inst (
    .clk(clk),
    .resetn(resetn),
    .i_clkb(i_clkb),
    .i_enb(i_enb),
    .i_web(i_web),
    .i_addrb(i_addrb),
    .i_dinb(i_dinb),
    .i_doutb(i_doutb),
    .d_clkb(d_clkb),
    .d_enb(d_enb),
    .d_web(d_web),
    .d_addrb(d_addrb),
    .d_dinb(d_dinb),
    .d_doutb(d_doutb)
  );
endmodule
