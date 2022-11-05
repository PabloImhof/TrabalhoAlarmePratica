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

    senha_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

    led_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    buzz_out : OUT STD_LOGIC
);
END alarme;

ARCHITECTURE alarme OF alarme IS
    TYPE stateFSM IS (DESARMADO, ARMADO, DISPARANDO);
    SIGNAL FSM : stateFSM;
    CONSTANT SENHA : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; -- SENHA 2

BEGIN

    PROCESS (clock, reset)
    BEGIN
        IF reset = '0' THEN
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
                    IF (btn2 = '1') THEN
                        FSM <= DISPARANDO;
                    ELSIF (btn3 = '1' AND SENHA = senha_in) THEN
                        FSM <= DESARMADO;
                    ELSIF (btn3 = '1' AND SENHA /= senha_in) THEN
                    --aqui poderia pescar os led
                    -- e dar um bipe diferente
                        FSM <= DISPARANDO;
                    END IF;

                WHEN DISPARANDO =>
                    buzz_out <= '1';
                    IF (btn3 = '1' AND SENHA = senha_in) THEN
                        FSM <= DESARMADO;
                        -- ELSIF (btn3 = '1' AND SENHA /= senha_in) THEN
                        -- --aqui poderia pescar os led
                        -- -- e dar um bipe diferente
                    END IF;

            END CASE;

        END IF;

    END PROCESS;
END alarme;