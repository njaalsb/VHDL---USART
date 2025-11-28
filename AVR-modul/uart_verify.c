/*
 * File:   uart_verify.c
 * Author: elisemariehals
 *
 * Created on November 28, 2025, 10:51 AM
 * 
 * Denne koden sender en testbyte til FGPA over UART. 
 * Den mottar så en byte tilbake og sammenligner denne med både den sendte verdien og en lagret referanseverdi.
 * Hvis resultatet er riktig lyser LED, hvis ikke riktig blinker LED-en for å indikere feil.  
 */

#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <string.h>
#include <util/delay.h>
#include <stdint.h>

#define F_CPU 4000000UL 
#define USART3_BAUD_RATE(BAUD_RATE) ((float)(F_CPU * 64 / (16 * (float)BAUD_RATE)) + 0.5)


#define LED_PIN PIN5_bm  //PF5


void LED_init(void) {
    PORTF.DIRSET = LED_PIN;   // PF5 som utgang
    PORTF.OUTSET = LED_PIN;   // LED av (active-low)
}

void LED_green(void) {
    PORTF.OUTCLR = LED_PIN;   // LED på (fast lys)
}

void LED_red(void) {
    //Blinkefeil: send 3 blink
    for (uint8_t i = 0; i < 3; i++) {
        PORTF.OUTCLR = LED_PIN;   // ON
        _delay_ms(150);
        PORTF.OUTSET = LED_PIN;   // OFF
        _delay_ms(150);
    }
}


void USART3_init(void);
void USART3_sendChar(char c);
void USART3_sendString(char * str);
uint8_t USART3_receiveChar(void);


void LED_init(void);
void LED_green(void);
void LED_red(void);

// Initialiserer USART3

void USART3_init(void) {
    
    PORTB.DIRCLR = PIN1_bm;   // RX inn
    PORTB.DIRSET = PIN0_bm;   // TX ut

    
    PORTB.PIN1CTRL = PORT_PULLUPEN_bm;
    
    // Sett baud-rate
    USART3.BAUD = (uint16_t)USART3_BAUD_RATE(9600);
    
    // 8N1, asynkron, UART-formatet, ingen paritet 
    USART3.CTRLC =
        USART_CMODE_ASYNCHRONOUS_gc |
        USART_PMODE_DISABLED_gc     |
        USART_SBMODE_1BIT_gc        |
        USART_CHSIZE_8BIT_gc;

    // Enable TX og RX
    USART3.CTRLB = USART_TXEN_bm | USART_RXEN_bm;
 }

void USART3_sendChar(char c){
    while (!(USART3.STATUS & USART_DREIF_bm)) {
        ; // vent til sendebuffer er tom
    }
    USART3.TXDATAL = c;
}

void USART3_sendString(char* str){
    while (*str != '\0') {
        USART3_sendChar(*str);
        str++;
    }
}

uint8_t USART3_receiveChar(void) {
    // Vent til en byte er mottatt
    while (!(USART3.STATUS & USART_RXCIF_bm)) {
        ; // vent
    }
    // Returner mottatt byte
    return USART3.RXDATAL;
}

int main(void) {
    USART3_init();
    LED_init();
    
    uint8_t sent   = 0x55;   // Byte som sendes til FPGA
    uint8_t saved  = 0x42;   // Referansebyte
    uint8_t received;

    while(1){

        // Send byte til FPGA
        USART3_sendChar(sent);

        // Les svar fra FPGA
        received = USART3_receiveChar();

        // Verifikasjonslogikk
        if (received == sent) {
            LED_green();      // OK – FPGA echoer byte
        }
        else if (received == saved) {
            LED_green();      // OK – FPGA sender kjent referansebyte
        }
        else {
            LED_red();        // FEIL – FPGA sender noe annet
        }

        _delay_ms(200);
    }
}