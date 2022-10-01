LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY synch_btn IS
    PORT (
        clock : IN STD_LOGIC;
        async_i : IN STD_LOGIC;

        sync_o : OUT STD_LOGIC
    );
END synch_btn;

ARCHITECTURE synch_btn OF synch_btn IS
    SIGNAL sig : STD_LOGIC;

BEGIN

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) THEN
            sig <= async_i;
            sync_o <= sig;
        END IF;
    END PROCESS;

END synch_btn;