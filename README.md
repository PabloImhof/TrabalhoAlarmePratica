# TrabalhoAlarmePratica
Projeto de Alarme em FPGA 


Repositório a fim de desenvolver um projeto de alarme em VHDL utilizando um FPGA.
Prática Profissional, e trabalho em grupo.

Código feito em VHDL.

Onde simula um alarme da seguinte forma.

Estado AGUARDANDO o FPGA fica aguardando do comando LIGAR pelo Botão S1 ou pelo Controle IR tecla CH-

Ao clicar em um dos botões irá ser ATIVO o alarme onde o LED 1 fica piscando e 1 aviso sonoro é enviado pelo buzzer sinalizando que o mesmo está ligado.


No estado de ATIVO o alarme pode ser DESATIVADO através da inserção de senha de 4 dígitos 1644 utilizando o controle IR para informar a senha, que será mostrada nos 4 visores de 7 Segmentos.

Após informar a senha deve se clicar no BTN S3 ou CH+ do IR para verificação da senha.

Se incorreta a senha volta ao estado anterior a verificação (Ativo, ou Disparando) acende 0101 LED e sinaliza com sinal sonoro o erro.
Caso correta Sinaliza com sinal sonoro de DESARME e volta para o estado de AGUARDO.

Quando ativo o alarme pode se clicar no BTN S2 ou CH do IR para simular um sensor de presença onde o alarme irá disparar, piscando os led de forma intermitente e ficar disparando o buzzer em 2 frequências diferentes até que seja inserido a senha correta e desativado o alarme.

