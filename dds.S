#include <avr/io.h>
.section .text

.global dds_save_ports
dds_save_ports:
  
  in r21, 0x18
  in r22, 0x1b
  ret

.global dds_isr
dds_isr:
  push r24
  
  ldi r24, 1
  and r24, r21
  cpi r24, 0
  breq skip_cycle
  pop r24
  rjmp cycle_dds_change  
  skip_cycle:

  ldi r24, 2
  and r24, r21
  cpi r24, 0
  breq skip_incr
  pop r24
  rjmp dds_increment
  skip_incr:

  ldi r24, 4
  and r24, r21
  cpi r24, 0
  breq skip_decr
  pop r24
  rjmp dds_decrement
  skip_decr:

  pop r24
  reti

.global dds_loop

dds_loop:
  ldi r31, hi8(sine)
  ldi r30, lo8(sine)
  
  ldi r28, 0x0
  ldi r29, 0x0
  
  ldi r24, 0xff
  ldi r25, 0x0f
  ldi r26, 0x00
  
  ldi r23, 0x00
  rjmp dds

.global dds_zero_output
dds_zero_output:
  push r24
  ldi r24, 0x0
  out 0x1b, r24
  pop r24
  ret

.global cycle_dds_change

cycle_dds_change:
  push r24
  mov r24, r23  
  adiw r24, 1
  mov r23, r24
  pop r24
  cpi r23, 3
  brsh clear_dds_change
  sei
  reti

clear_dds_change:
  ldi r23, 0x00
  reti

.global dds_increment

dds_increment:

  cpi r23, 0
  brne skip_call_0
  rcall dds_increment_0
  skip_call_0:
  
  cpi r23, 1
  brne skip_call_1
  rcall dds_increment_1
  skip_call_1:

  cpi r23, 2
  brne skip_call_2
  rcall dds_increment_2

  skip_call_2:

  sei
  reti

dds_increment_0:
  cpi r24, 0xff
  breq immediate_return
  adiw r24, 1
  ret

dds_increment_1:
  cpi r25, 0xff
  breq immediate_return
  push r24
  mov r24, r25
  adiw r24, 1
  mov r25, r24
  pop r24
  ret

dds_increment_2:
  cpi r26, 0x7f
  brsh immediate_return
  adiw r26, 1
  ret

immediate_return:
  ret


.global dds_decrement

dds_decrement:

  cpi r23, 0
  brne skip_call_decr_0
  rcall dds_decrement_0
  skip_call_decr_0:

  cpi r23, 1
  brne skip_call_decr_1
  rcall dds_decrement_1
  skip_call_decr_1:

  cpi r23, 2
  brne skip_call_decr_2
  rcall dds_decrement_2
  skip_call_decr_2:

  sei
  reti

dds_decrement_0:
  cpi r24, 1
  breq immediate_return
  sbiw r24, 1
  ret

dds_decrement_1:
  cpi r25, 0
  breq immediate_return
  push r24
  mov r24, r25
  sbiw r24, 1
  mov r25, r24
  pop r24
  ret

dds_decrement_2:
  cpi r26, 0
  breq immediate_return
  sbiw r26, 1
  ret


dds:
  add             r28,r24                 ; 1
  adc             r29,r25                 ; 1
  adc             r30,r26                 ; 1
  lpm                                             ; 3
  out             0x1b,r0                ; 1
  
  rjmp dds

