/* 
 * File:   newmain.c
 * Author: bruhe
 *
 * Denne koden er skrevet spesifikt for å sende en karakter fra USART3 til USART1
 * 
 * pinout:
 * USART3 Rx - PB1
 * USART3 Tx - PB0
 * USART1 Tx - PC0
 * USART1 Rx - PC1
 * 
 * 
 * Created on January 20, 2025, 12:05 PM
 */
#define F_CPU 4000000UL
#define USART3_BAUD_RATE(BAUD_RATE) ((float)(F_CPU * 64 / (16 *(float)BAUD_RATE)) + 0.5)
#define USART1_BAUD_RATE(BAUD_RATE) ((float)(F_CPU * 64 / (16 *(float)BAUD_RATE)) + 0.5)

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <util/delay.h>
#include <string.h>
#include <avr/interrupt.h>


/*
 * 
 */

void USART3_init(void);
void USART3_sendChar(char c);
void USART3_sendString(char *str);
uint8_t USART3_read();
static int USART3_printChar(char c, FILE *stream);

void USART1_init(void);
void USART1_sendChar(char c);
void USART1_sendString(char *str);
uint8_t USART1_read();
static int USART1_printChar(char c, FILE *stream);

volatile uint8_t usart1_rx_byte;
volatile uint8_t usart1_rx_flag = 0;


void USART3_init(void)
{
    PORTB.DIR &= ~PIN1_bm;
    PORTB.DIR |= PIN0_bm;

    USART3.BAUD = (uint16_t)USART3_BAUD_RATE(9600);
    USART3.CTRLB |= USART_TXEN_bm;
    USART3.CTRLB |= USART_RXEN_bm;
 
    static FILE USART_stream = FDEV_SETUP_STREAM(USART3_printChar, NULL, _FDEV_SETUP_WRITE);
    //stdout = &USART_stream;
}

void USART1_init(void)
{
    PORTC.DIR &= ~PIN1_bm;   // PC1 = RX
    PORTC.DIR |= PIN0_bm;    // PC0 = TX
    
    USART1.BAUD = (uint16_t)USART1_BAUD_RATE(9600);

    USART1.CTRLA = USART_RXCIE_bm;          // Enable RX Complete interrupt
    USART1.CTRLB = USART_RXEN_bm | USART_TXEN_bm; // Enable RX + TX

    // Enable global interrupts
    sei();
}

ISR(USART1_RXC_vect)
{
    usart1_rx_byte = USART1.RXDATAL;
    usart1_rx_flag = 1;
}


void USART3_sendChar(char c){
    while (!(USART3.STATUS & USART_DREIF_bm))
    {
        ;
    }
    USART3.TXDATAL = c;
}

void USART1_sendChar(char c)
{
    while (!(USART1.STATUS & USART_DREIF_bm))
    {
        ;
    }
    USART1.TXDATAL = c;
}
uint8_t USART3_read(){
    while (!(USART3.STATUS & USART_RXCIF_bm)) 
    {
        ;
    }
    return USART3.RXDATAL;
}

int USART1_read_nonblocking(uint8_t *data)
{
    if (usart1_rx_flag) {
        usart1_rx_flag = 0;
        *data = usart1_rx_byte;
        return 1;        // New byte available
    }
    return 0;            // No new data
}

static int USART3_printChar(char c, FILE *stream)
{
    USART3_sendChar(c);
    return 0;
}
static int USART1_printChar(char c, FILE *stream){
    USART1_sendChar(c);
    return 0;
}

void USART3_sendString(char *str){
    for(size_t i = 0; i < strlen(str); i++){
        USART3_sendChar(str[i]);
    }
}

void USART1_sendString(char *str){
    for(size_t i = 0; i < strlen(str); i++){
        USART1_sendChar(str[i]);
    }
}


int main(void){
    USART3_init();
    USART1_init();

    PORTB.DIRSET = PIN2_bm;   // LED pin
    PORTB.OUTCLR = PIN2_bm;   // LED OFF initially

    uint8_t c;
    uint8_t i;
    while (1)
    {
        //USART1_read_nonblocking(&c);
        ++i;
        c = i + '0';
        USART1_sendChar(c);
        
        if (USART1_read_nonblocking(&c))
        {
            // Printer motatt karakter i terminalen 
            USART3_sendChar(c);
        }
        _delay_ms(1000);
    }
}
