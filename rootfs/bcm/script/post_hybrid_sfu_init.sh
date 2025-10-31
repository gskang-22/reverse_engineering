#!/bin/sh

#FR ALU02050354
wan0_dal_miss_cfg(){	
  bs /bdmf/configure port/index=wan0 cfg={emac=none,dal_miss_action=forward}
}

wan0_dal_miss_cfg
