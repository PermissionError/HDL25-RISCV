-makelib xcelium_lib/xilinx_vip -sv \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "C:/Xilinx/Vivado/2021.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_vip_v1_1_11 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/63b7/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/processing_system7_vip_v1_0_13 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/3007/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_processing_system7_0_0/sim/ip_integrator_processing_system7_0_0.v" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/sim/bd_d914.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_7 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_0/sim/bd_d914_one_0.v" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_d914_psr_aclk_0.vhd" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/c012/hdl/sc_switchboard_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_d914_arsw_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_d914_rsw_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_d914_awsw_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_d914_wsw_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_d914_bsw_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/ea34/hdl/sc_mmu_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_d914_s00mmu_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/4fd2/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_d914_s00tr_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/8047/hdl/sc_si_converter_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_d914_s00sic_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_d914_s00a2s_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/66be/hdl/sc_node_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_d914_sarn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_d914_srn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_d914_sawn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_d914_swn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_d914_sbn_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_d914_m00s2a_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_17/sim/bd_d914_m00arn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_18/sim/bd_d914_m00rn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_19/sim/bd_d914_m00awn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_20/sim/bd_d914_m00wn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_21/sim/bd_d914_m00bn_0.sv" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/93a6/hdl/sc_exit_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_22/sim/bd_d914_m00e_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_23/sim/bd_d914_m01s2a_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_24/sim/bd_d914_m01arn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_25/sim/bd_d914_m01rn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_26/sim/bd_d914_m01awn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_27/sim/bd_d914_m01wn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_28/sim/bd_d914_m01bn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_29/sim/bd_d914_m01e_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_30/sim/bd_d914_m02s2a_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_31/sim/bd_d914_m02arn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_32/sim/bd_d914_m02rn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_33/sim/bd_d914_m02awn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_34/sim/bd_d914_m02wn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_35/sim/bd_d914_m02bn_0.sv" \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/bd_0/ip/ip_36/sim/bd_d914_m02e_0.sv" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_25 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/e1e6/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_smartconnect_0_0/sim/ip_integrator_smartconnect_0_0.v" \
-endlib
-makelib xcelium_lib/axi_bram_ctrl_v4_1_6 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/3c31/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_axi_bram_ctrl_0_0/sim/ip_integrator_axi_bram_ctrl_0_0.vhd" \
  "../../../bd/ip_integrator/ip/ip_integrator_axi_bram_ctrl_1_0/sim/ip_integrator_axi_bram_ctrl_1_0.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_5 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_blk_mem_gen_0_0/sim/ip_integrator_blk_mem_gen_0_0.v" \
  "../../../bd/ip_integrator/ip/ip_integrator_blk_mem_gen_0_1/sim/ip_integrator_blk_mem_gen_0_1.v" \
-endlib
-makelib xcelium_lib/axi_lite_ipif_v3_0_4 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/interrupt_control_v3_1_4 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_gpio_v2_0_27 \
  "../../../../hdl_group_project.gen/sources_1/bd/ip_integrator/ipshared/a5bb/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ip/ip_integrator_axi_gpio_0_0/sim/ip_integrator_axi_gpio_0_0.vhd" \
  "../../../bd/ip_integrator/ip/ip_integrator_proc_sys_reset_0_0/sim/ip_integrator_proc_sys_reset_0_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/ip_integrator/ipshared/4897/rv-pl.v" \
  "../../../bd/ip_integrator/ip/ip_integrator_rv_pl_ip_0_0/sim/ip_integrator_rv_pl_ip_0_0.v" \
  "../../../bd/ip_integrator/sim/ip_integrator.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

