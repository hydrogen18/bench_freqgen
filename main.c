#define F_CPU 8000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/power.h>
#include <avr/interrupt.h>
#include <stdint.h>

extern void dds_isr(void);
extern void dds_zero_output(void);

ISR(PCINT1_vect, ISR_NAKED){
  cli();
  dds_isr();
  sei();
  reti();
}
//ISR_ALIAS(PCINT1_vect, PCINT0_vect);

#define LED_PIN 0x40

void blink_led(uint8_t count){
  //Setting the pin low turns on the LED

  for(;count != 0; count--){
    PORTA ^= LED_PIN;
    _delay_ms(125);
    PORTA ^= LED_PIN;
    _delay_ms(125);
  }

}

int
main (void)
{
    // No clock division of internal 8 mhz oscillator
    clock_prescale_set(clock_div_1);

    dds_zero_output();

    DDRA = _BV(DDA0);
    DDRA |= _BV(DDA1);
    DDRA |= _BV(DDA2);
    DDRA |= _BV(DDA3);
    DDRA |= _BV(DDA4);
    DDRA |= _BV(DDA5);
    DDRA |= _BV(DDA6);
    // DDA7 is input

    

    //Enable pull up on all pins
    //All of DDRB is input
    PORTB |= (1 << 0); 
    PORTB |= (1 << 1);
    PORTB |= (1 << 2);
    DDRB = 0x0; 
    

    // The following pins trigger interrupts
    //PCINT10
    //PCINT7
    //PCINT8
    //PCINT9

    //PCMSK0 |= (1 << PCINT7);
    PCMSK1 |= (1 << PCINT8);
    PCMSK1 |= (1 << PCINT9);
    PCMSK1 |= (1 << PCINT10);
    
    // Enable PCINT0 and PCINT1 vector entries
    //GIMSK |= (1 << 4);
    GIMSK |= (1 << 5);

    blink_led(4);
    
    dds_loop();
}
