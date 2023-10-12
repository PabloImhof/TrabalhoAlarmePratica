# README: TrabalhoAlarmePratica - Projeto de Alarme em FPGA

## Descrição

Este repositório foi criado para o desenvolvimento de um projeto prático de alarme usando VHDL e FPGA. Foi desenvolvido como parte de uma atividade de Prática Profissional.

## Funcionalidades

O projeto simula um sistema de alarme com as seguintes características:

1. **Estado AGUARDANDO**: 
   - O FPGA permanece neste estado até receber o comando de ativação.
   - O comando pode ser acionado pelo Botão S1 ou pelo Controle IR (tecla CH-).
  
2. **Estado ATIVO**:
   - Ao ativar, o LED 1 começa a piscar, indicando que o sistema de alarme está ligado.
   - Um aviso sonoro é emitido pelo buzzer como sinal de ativação.
   - Enquanto estiver ativo, o alarme pode ser desativado inserindo-se uma senha de 4 dígitos (padrão 1644) através do Controle IR.
   - A senha inserida será exibida nos 4 visores de 7 segmentos.
   - Após inserir a senha, é necessário pressionar o BTN S3 ou a tecla CH+ do IR para verificar a senha.
  
3. **Verificação de Senha**:
   - Se a senha for inserida incorretamente, os LEDs mostrarão o padrão 0101 e um sinal sonoro indicará erro. O sistema retornará ao estado anterior (Ativo ou Disparando).
   - Se a senha for correta, um sinal sonoro de desarme será emitido e o sistema retornará ao estado de AGUARDO.

4. **Disparo do Alarme**:
   - No estado ativo, pressionando o BTN S2 ou a tecla CH do IR simula-se a detecção de uma presença (como se fosse um sensor de presença).
   - O alarme será acionado, fazendo os LEDs piscarem intermitentemente.
   - O buzzer soará em duas frequências diferentes até que a senha correta seja inserida e o alarme seja desativado.

## Hardware Utilizado

- FPGA
- Botões (S1, S2, S3)
- Controle IR
- 4 visores de 7 segmentos
- LED
- Buzzer

## Linguagem

O código deste projeto foi desenvolvido em VHDL.

## Conclusão

Este projeto prático proporcionou uma oportunidade valiosa para aprender sobre o desenvolvimento de sistemas de alarme em FPGA usando VHDL. A simulação do sistema de alarme foi bem-sucedida e cumpriu todos os requisitos propostos.
