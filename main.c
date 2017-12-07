#define F_CPU 8000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/power.h>
#include <avr/interrupt.h>
#include <stdint.h>

extern void dds_zero_output(void);
extern void dds_isr();
extern void dds_save_ports(void);
extern void dds_loop(void);
extern void dds_increment(void);
extern void dds_decrement(void);
extern void dds_cycle_change(void);

ISR(PCINT0_vect, ISR_NAKED){
  cli();
  dds_save_ports();  
  dds_zero_output();
  asm("rjmp dds_isr");
}
ISR_ALIAS(PCINT1_vect, PCINT0_vect);

int
main (void)
{
    // No clock division of internal 8 mhz oscillator
    clock_prescale_set(clock_div_1);

    DDRA = _BV(DDA0);
    DDRA |= _BV(DDA1);
    DDRA |= _BV(DDA2);
    DDRA |= _BV(DDA3);
    DDRA |= _BV(DDA4);
    DDRA |= _BV(DDA5);
    DDRA |= _BV(DDA6);
    // DDA7 is input

    DDRB = 0x0; //All of DDRB is input

    // The following pins trigger interrupts
    //PCINT10
    //PCINT7
    //PCINT8
    //PCINT9

    PCMSK0 |= (1 << PCINT7);
    PCMSK1 |= (1 << PCINT8);
    PCMSK1 |= (1 << PCINT9);
    PCMSK1 |= (1 << PCINT10);
    
    // Enable PCINT0 and PCINT1 vector entries
    GIMSK |= (1 << 4);
    GIMSK |= (1 << 5);

    sei();
    
    dds_loop();
}
