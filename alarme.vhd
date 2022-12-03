LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY alarme IS PORT (
    clock : IN STD_LOGIC;
    reset : IN STD_LOGIC;

    btn1 : IN STD_LOGIC;
    btn2 : IN STD_LOGIC;
    btn3 : IN STD_LOGIC;

    btn1_ir_in : IN STD_LOGIC;
    btn2_ir_in : IN STD_LOGIC;
    btn3_ir_in : IN STD_LOGIC;

    senhavsr0_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr1_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr2_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr3_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    led_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    div_out : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
    buzz_out : OUT STD_LOGIC

);
END alarme;

ARCHITECTURE alarme OF alarme IS
    TYPE stateFSM IS (DESARMADO, ARMADO, DISPARANDO);
    SIGNAL FSM : stateFSM;

    CONSTANT SENHAVSR1 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100"; -- SENHA 4
    CONSTANT SENHAVSR2 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100"; -- SENHA 4
    CONSTANT SENHAVSR3 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110"; -- SENHA 6
    CONSTANT SENHAVSR4 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001"; -- SENHA 1
    --led
    SIGNAL cntr_sec : STD_LOGIC_VECTOR(25 DOWNTO 0);
    --buzz
    SIGNAL cntr_buzz : STD_LOGIC_VECTOR(25 DOWNTO 0);
    SIGNAL cntrDisp : STD_LOGIC;
    TYPE stateFSMbuzzer IS (AGUARDA, LIGA, DESLIGA, DISPARA);
    SIGNAL FSMBUZZER : stateFSMBUZZER;
    SIGNAL LED : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    led_out <= LED;
    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            FSM <= DESARMADO;
            LED <= (OTHERS => '0');
            cntr_sec <= (OTHERS => '0');

        ELSIF rising_edge(clock) THEN
            cntr_sec <= cntr_sec + '1'; --contador para piscar led
            CASE FSM IS
                WHEN DESARMADO =>                    
                    LED <= (OTHERS => '0');
                    IF (btn1 = '1' OR btn1_ir_in = '1') THEN
                        FSM <= ARMADO;
                    END IF;

                WHEN ARMADO =>                    
                    IF (cntr_sec > x"2000000") THEN --se maior que valor apaga led e menor liga, fazendo piscar
                        LED <= "0000";
                    ELSE
                        LED <= "0001";
                    END IF;

                    IF (btn2 = '1' OR btn2_ir_in = '1') THEN
                        FSM <= DISPARANDO;
                    ELSIF ((btn3 = '1' OR btn3_ir_in = '1') AND (senhavsr0_in = SENHAVSR1 AND senhavsr1_in = SENHAVSR2 AND senhavsr2_in = SENHAVSR3 AND senhavsr3_in = SENHAVSR4)) THEN
                        FSM <= DESARMADO;

                    ELSIF ((btn3 = '1' OR btn3_ir_in = '1') AND (senhavsr0_in /= SENHAVSR1 OR senhavsr1_in /= SENHAVSR2 OR senhavsr2_in /= SENHAVSR3 OR senhavsr3_in /= SENHAVSR4)) THEN
                        LED <= "0101";
                        FSM <= ARMADO;                        
                    END IF;

                WHEN DISPARANDO =>                    
                    IF (cntr_sec > x"2000000") THEN --se maior que valor apaga led e menor liga, fazendo piscar
                        LED <= "0000";
                    ELSE
                        LED <= "1111";
                    END IF;

                    IF ((btn3 = '1' OR btn3_ir_in = '1') AND (senhavsr0_in = SENHAVSR1 AND senhavsr1_in = SENHAVSR2 AND senhavsr2_in = SENHAVSR3 AND senhavsr3_in = SENHAVSR4)) THEN
                        FSM <= DESARMADO;

                    ELSIF ((btn3 = '1' OR btn3_ir_in = '1') AND (senhavsr0_in /= SENHAVSR1 OR senhavsr1_in /= SENHAVSR2 OR senhavsr2_in /= SENHAVSR3 OR senhavsr3_in /= SENHAVSR4)) THEN
                        LED <= "0101";
                        FSM <= DISPARANDO;                        
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    --BUZZER
    PROCESS (clock, reset)
    BEGIN
        IF (reset = '1') THEN
            buzz_out <= '0';
            FSMBUZZER <= AGUARDA;
            cntr_buzz <= (OTHERS => '0');
            cntrDisp <= '0';

        ELSIF rising_edge(clock) THEN
            cntr_buzz <= cntr_buzz + '1';
            CASE FSMBUZZER IS

                WHEN AGUARDA =>
                    buzz_out <= '0';
                    cntrDisp <= '0';

                    IF FSM = ARMADO THEN
                        FSMBUZZER <= LIGA;
                        cntr_buzz <= (OTHERS => '0');
                    END IF;

                WHEN LIGA =>
                    div_out <= "000000010011100010000";
                    IF (cntrDisp = '0') THEN
                        buzz_out <= '1';
                        IF (cntr_buzz = x"2000000") THEN
                            cntrDisp <= '1';
                        END IF;
                    ELSE
                        buzz_out <= '0';

                        --erro dai 1 bip
                        IF (LED = "0101") THEN
                            buzz_out <= '1';
                        END IF;
                    END IF;

                    IF FSM = DISPARANDO THEN
                        FSMBUZZER <= DISPARA;

                    ELSIF (FSM = DESARMADO) THEN
                        FSMBUZZER <= DESLIGA;

                        cntr_buzz <= (OTHERS => '0');
                    END IF;

                WHEN DISPARA =>
                    buzz_out <= '1';
                    IF (cntr_buzz > x"2000000") THEN
                        div_out <= "000000001001110001000";
                    ELSE
                        div_out <= "001100001101010000000";
                    END IF;

                    IF (FSM = DESARMADO) THEN
                        FSMBUZZER <= DESLIGA;
                        cntr_buzz <= (OTHERS => '0');
                    END IF;

                    --erro dai 1 bip
                    IF (LED = "0101") THEN
                        div_out <= "000000010011100010000";
                        buzz_out <= '1';
                    END IF;

                WHEN DESLIGA =>
                    div_out <= "000000010011100010000";
                    buzz_out <= '1';
                    IF (cntr_buzz > x"2000000") THEN                     
                        buzz_out <= '0';

                        IF (FSM = DESARMADO) THEN
                            FSMBUZZER <= AGUARDA;
                        END IF;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

END alarme;