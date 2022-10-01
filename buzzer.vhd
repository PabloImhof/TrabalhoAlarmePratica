LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY buzzer IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        en : IN STD_LOGIC;
        buzz : OUT STD_LOGIC
    );
END buzzer;

ARCHITECTURE buzzer OF buzzer IS
    SIGNAL cnt : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL square : STD_LOGIC;

BEGIN
    buzz <= en AND square;
    PROCESS (clock, reset)
    BEGIN
        IF (reset = '1') THEN
            cnt <= (OTHERS => '0');
        ELSIF (rising_edge(clock)) THEN
            cnt <= cnt + '1';            
        END IF;
    END PROCESS;
    PROCESS (clock, reset)
    BEGIN
        IF (reset = '1') THEN
            square <= '0';
        ELSIF (rising_edge(clock)) THEN
            IF (cnt = (cnt'RANGE => '0')) THEN
                square <= NOT square;
            END IF;
        END IF;
    END PROCESS;
END buzzer;