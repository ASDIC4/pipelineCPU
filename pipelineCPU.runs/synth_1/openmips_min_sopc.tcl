# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xa7a35tcsg324-1I

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir F:/Desktop/pipelineCPU/pipelineCPU.cache/wt [current_project]
set_property parent.project_path F:/Desktop/pipelineCPU/pipelineCPU.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo f:/Desktop/pipelineCPU/pipelineCPU.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/coe_files/1.coe
add_files F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/coe_files/inst_rom.coe
read_verilog F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/define.vh
read_verilog -library xil_defaultlib {
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/confreg.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/ctrl.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/data_ram.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/ex.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/ex_mem.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/hilo_reg.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/id.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/id_ex.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/if_id.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/inst_rom.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/mem.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/mem_wb.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/openmips.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/pc_reg.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/regfile.v
  F:/Desktop/pipelineCPU/pipelineCPU.srcs/sources_1/new/openmips_min_sopc.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc F:/Desktop/pipelineCPU/pipelineCPU.srcs/constrs_1/new/confreg_ports.xdc
set_property used_in_implementation false [get_files F:/Desktop/pipelineCPU/pipelineCPU.srcs/constrs_1/new/confreg_ports.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top openmips_min_sopc -part xa7a35tcsg324-1I


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef openmips_min_sopc.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file openmips_min_sopc_utilization_synth.rpt -pb openmips_min_sopc_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
