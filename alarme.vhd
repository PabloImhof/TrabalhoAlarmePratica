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

    -- senha_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr0_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr1_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr2_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    senhavsr3_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    led_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    buzz_out : OUT STD_LOGIC
);
END alarme;

ARCHITECTURE alarme OF alarme IS
    TYPE stateFSM IS (DESARMADO, ARMADO, DISPARANDO);
    SIGNAL FSM : stateFSM;
    -- CONSTANT SENHA : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; -- SENHA 2

    CONSTANT SENHAVSR1 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100"; -- SENHA 4
    CONSTANT SENHAVSR2 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110"; -- SENHA 6
    CONSTANT SENHAVSR3 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001"; -- SENHA 1
    CONSTANT SENHAVSR4 : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"; -- SENHA 0
BEGIN

    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            FSM <= DESARMADO;
            led_out <= (OTHERS => '0');

        ELSIF rising_edge(clock) THEN

            CASE FSM IS
                WHEN DESARMADO =>
                    buzz_out <= '0';
                    led_out <= (OTHERS => '0');
                    --7segmentos zerar
                    IF (btn1 = '1') THEN
                        FSM <= ARMADO;
                    END IF;

                WHEN ARMADO =>
                    led_out <= "0001";
                    buzz_out <= '0';
                    IF (btn2 = '1') THEN
                        FSM <= DISPARANDO;
                    ELSIF (btn3 = '1' AND (senhavsr0_in = SENHAVSR1 AND senhavsr1_in = SENHAVSR2 AND senhavsr2_in = SENHAVSR3 AND senhavsr3_in = SENHAVSR4)) THEN
                        FSM <= DESARMADO;
                    ELSIF (btn3 = '1' AND (senhavsr0_in /= SENHAVSR1 OR senhavsr1_in /= SENHAVSR2 OR senhavsr2_in /= SENHAVSR3 OR senhavsr3_in /= SENHAVSR4)) THEN
                        led_out <= "0101";
                        buzz_out <= '1';
                        -- e dar um bipe diferente
                        FSM <= ARMADO;
                    END IF;

                WHEN DISPARANDO =>
                    buzz_out <= '1';
                    led_out <= "1111";
                    IF (btn3 = '1' AND (senhavsr0_in = SENHAVSR1 AND senhavsr1_in = SENHAVSR2 AND senhavsr2_in = SENHAVSR3 AND senhavsr3_in = SENHAVSR4)) THEN
                        FSM <= DESARMADO;
                    ELSIF (btn3 = '1' AND (senhavsr0_in /= SENHAVSR1 OR senhavsr1_in /= SENHAVSR2 OR senhavsr2_in /= SENHAVSR3 OR senhavsr3_in /= SENHAVSR4)) THEN
                        led_out <= "0101";
                        buzz_out <= '0';
                        -- e dar um bipe diferente
                        FSM <= DISPARANDO;
                    END IF;

            END CASE;

        END IF;

    END PROCESS;
END alarme;