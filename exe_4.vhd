LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY exe_4 IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        btn : IN STD_LOGIC;

        led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END exe_4;

ARCHITECTURE exe_4 OF exe_4 IS
    SIGNAL pressed : STD_LOGIC;
    SIGNAL cnt : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
    led <= cnt;
    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            cnt <= (OTHERS => '0');
            pressed <= '0';

        ELSIF rising_edge(clock) THEN
            IF btn = '1' AND pressed = '0' THEN
                cnt <= cnt + '1';
                pressed <= '1';
            END IF;
            IF btn = '0' AND pressed = '1' THEN
                pressed <= '0';
            END IF;
        END IF;
    END PROCESS;

END exe_4;