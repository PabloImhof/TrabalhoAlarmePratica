LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY debounce IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        bounce_I : IN STD_LOGIC;

        debounce_o : OUT STD_LOGIC
    );
END debounce;

ARCHITECTURE debounce OF debounce IS

    SIGNAL timer : STD_LOGIC_VECTOR (21 DOWNTO 0);
    SIGNAL state : STD_LOGIC;

BEGIN

    debounce_o <= state;

    PROCESS (clock, reset)
    BEGIN
        IF (reset = '1') THEN
            timer <= (0 => '1', OTHERS => '0');
            state <= '0';
        ELSIF (rising_edge(clock)) THEN
            IF (bounce_i /= state AND timer = "0000000000000000000000") THEN
                state <= bounce_i;
                timer <= (0 => '1', OTHERS => '0');
            ELSIF (timer /= "0000000000000000000000") THEN
                timer <= timer + '1';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;