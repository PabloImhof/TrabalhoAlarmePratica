LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY trabalho1 IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        btn1 : IN STD_LOGIC;-- BTN 88 INCREMENTO BOTÃO
        btn2 : IN STD_LOGIC;-- BTN 89 ARMAR ALARME
        btn3 : IN STD_LOGIC;-- BTN 90 SIMULA PIR
        btn4 : IN STD_LOGIC;-- BTN 91 DESARMAR(VERIFICA SENHA)

        -- os botões vai tem que receber do debounce
        led1 : OUT STD_LOGIC;
        led2 : OUT STD_LOGIC;
        led3 : OUT STD_LOGIC;
        led4 : OUT STD_LOGIC;
        -- a ativação do buzzer vai mandar o sinal para outro processo.
        buzz : OUT STD_LOGIC

    );
END trabalho1;

ARCHITECTURE trabalho1 OF trabalho1 IS

    TYPE stateFSM IS (DESARMADO, ARMADO, DISPARANDO);
    SIGNAL FSM : stateFSM;
    CONSTANT SENHA : STD_LOGIC_VECTOR (15 DOWNTO 0) := "1011"; -- SENHA 11
    SIGNAL dig : STD_LOGIC_VECTOR(25 DOWNTO 0);
    -- SIGNAL AUX_DATA : STD_LOGIC_VECTOR (3 DOWNTO 0);
    -- SIGNAL CONTADOR : STD_LOGIC_VECTOR (3 DOWNTO 0);

    --tem que fazer vários processos separados e juntar em 1 top
    --1 somente de led piscando ou alternando.
    --- 1 do buzzer disparando.

BEGIN

    PROCESS (clock, reset)
    BEGIN
        led1 <= dig(25);
        led2 <= dig(24);
        led3 <= dig(23);
        led4 <= dig(22);

        IF reset = '0' THEN
            led1 <= dig(0);
            led2 <= dig(0);
            led3 <= dig(0);
            led4 <= dig(0);
            FSM <= DESARMADO;

        ELSIF rising_edge(clock) THEN

            CASE FSM IS
                WHEN DESARMADO =>
                    led1 <= dig(0);
                    led2 <= dig(0);
                    led3 <= dig(0);
                    led4 <= dig(0);
                    IF (btn2 = '1') THEN
                        FSM <= ARMADO;
                    END IF;

                WHEN ARMADO =>
                    IF (btn3 = '1') THEN
                        dig <= dig + '1'; -- ATRIBUIU +1 PARA dig e começar a alterar os led
                        FSM <= DISPARANDO;

                    END IF;
                WHEN DISPARANDO =>
                    led1 <= dig(25);
                    led2 <= dig(25);
                    led3 <= dig(25);
                    led4 <= dig(25);
                    --DISPARA BUZZER

            END CASE;

        END IF;

    END PROCESS;

END trabalho1;