#!/bin/bash
ssh -i verticatf.sshkey -o stricthostkeychecking=false `terraform output vertica_basename`@`terraform output vertica_console_ip`

