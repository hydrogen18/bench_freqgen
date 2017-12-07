#include <avr/io.h>
.section .text

.global dds_isr
dds_isr:
  in r21, 0x18
  
  rcall dds_zero_output

  push r24 ; save r24 since it is used here
  
  ldi r24, 1
  and r24, r21
  cpi r24, 1
  breq skip_cycle  
  pop r24
  rcall cycle_dds_change  
  push r24
  ldi r24, 1 ; 1 blink
  rjmp end_dds_isr

  skip_cycle:

  ldi r24, 2
  and r24, r21
  cpi r24, 2
  breq skip_incr
  pop r24
  rcall dds_increment
  push r24
  ldi r24, 2 ; 2 blinks
  rjmp end_dds_isr

  skip_incr:

  ldi r24, 4
  and r24, r21
  cpi r24, 4
  breq skip_decr
  pop r24
  rcall dds_decrement
  push r24
  ldi r24, 3 ; 3 blinks 
  rjmp end_dds_isr

  skip_decr:
  ; Nothing ran for whatever reason
  ldi r24, 4 ; 4 blinks
  ; r24 still on the stack

  end_dds_isr:
  ; Save registers, r24 is already on the stack
  push r23
  push r25
  push r26
  push r27
  push r28
  push r29
  push r30
  push r31

  ; r24 is first and only arg to this C function, already set
  rcall blink_led
  
  ; Restore registers
  pop r31
  pop r30
  pop r29
  pop r28
  pop r27
  pop r26
  pop r25
  pop r23
  pop r24
  ret

.global dds_zero_output
dds_zero_output:
  push r24
  ldi r24, 0x60
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
  ret

clear_dds_change:
  ldi r23, 0x00
  ret

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

  ret

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

  ret

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

.global dds_loop
dds_loop:
  ldi r31, hi8(sine)
  ldi r30, lo8(sine)  

  ldi r29, 0x0
  ldi r28, 0x0
  
  ldi r24, 0x9c
  ldi r25, 0x3f
  ldi r26, 0x06
  
  ldi r23, 0x00

  sei
  rjmp dds

dds:
  add             r28,r24                 ; 1
  adc             r29,r25                 ; 1
  adc             r30,r26                 ; 1
  lpm                                             ; 3
  out             0x1b,r0                ; 1
  
  rjmp dds

