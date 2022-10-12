LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY exe_6_top IS
    PORT (
        clock : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;

        btn_n : IN STD_LOGIC;

        led_n : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

        buzzer_o : OUT STD_LOGIC
    );
END exe_6_top;

ARCHITECTURE exe_6_top OF exe_6_top IS

    SIGNAL btn_n_sync : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;
    SIGNAL btn_sync : STD_LOGIC;
    SIGNAL led : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL btn_deb : STD_LOGIC;

    SIGNAL buzzer_en : STD_LOGIC;

    SIGNAL verifica : STD_LOGIC;

BEGIN

    reset <= NOT reset_n;
    led_n <= NOT led;

    verifica <= '0' WHEN led = "1111" else btn_deb;
    btn_sync <= NOT btn_n_sync;

    buzzer_en <= '1' WHEN led = "1111" ELSE '0';

    synch_btn : ENTITY work.synch_btn
        PORT MAP(
            clock => clock,
            async_i => btn_n,
            sync_o => btn_n_sync
        );
    
    debounce : ENTITY work.debounce
        PORT MAP(
            clock => clock,
            reset => reset,
            bounce_i => btn_sync,
            debounce_o => btn_deb
        );

    exe_4 : ENTITY work.exe_4
        PORT MAP(
            clock => clock,
            reset => reset,
            btn => btn_deb,
            led => led
        );

    buzzer : ENTITY work.buzzer
        PORT MAP(
            clock => clock,
            reset => reset,
            en => buzzer_en,
            buzz => buzzer_o
        );

END exe_6_top;