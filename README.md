# VHDL USART prosjekt
![VHDL](https://img.shields.io/badge/VHDL-543978?style=for-the-badge)
![Intel](https://img.shields.io/badge/Intel-0071C5?style=for-the-badge&logo=intel&logoColor=white)
![FPGA](https://img.shields.io/badge/FPGA-0071C5?style=for-the-badge)

I dette prosjektet har det blitt skrevet en USART i VHDL. Prosjektet er laget for utviklingskortet DE-10, med FPGA Altera MAX 10M50DAF484C7G. Prosjektet er verifisert ved bruk av AVR128DB48 og ESP32. Dette har blitt gjort i faget innvevde systemer (IELS3012). Implementasjonen støtter 9600 baud rate, og kan bytte mellom to moduser, loop-back og sending av karakterer ved bruk av knappetrykk. 

## Systemoversikt 
Implementasjonen består av følgende delsystemer:
- Top level entitet
- Baud generator
- Sampler
- Transmitter 
- Uart control