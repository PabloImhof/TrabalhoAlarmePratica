LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY main_top IS
    PORT (
        clock : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;
        btn1_n : IN STD_LOGIC;
        btn2_n : IN STD_LOGIC;
        btn3_n : IN STD_LOGIC;

        led_n : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        buzzer_o : OUT STD_LOGIC
    );
END main_top;

ARCHITECTURE main_top OF main_top IS
    SIGNAL reset : STD_LOGIC;
    SIGNAL led : STD_LOGIC_VECTOR(3 DOWNTO 0);

    --Botão de negação do sincronizador
    SIGNAL btn1_n_sync : STD_LOGIC;
    SIGNAL btn2_n_sync : STD_LOGIC;
    SIGNAL btn3_n_sync : STD_LOGIC;

    --Sincronizador dos Botões
    SIGNAL btn1_sync : STD_LOGIC;
    SIGNAL btn2_sync : STD_LOGIC;
    SIGNAL btn3_sync : STD_LOGIC;

    --Botão dos debouncer
    SIGNAL btn1_deb : STD_LOGIC;
    SIGNAL btn2_deb : STD_LOGIC;
    SIGNAL btn3_deb : STD_LOGIC;

    SIGNAL buzzer_en : STD_LOGIC;
    SIGNAL valid : STD_LOGIC;
    SIGNAL prime : STD_LOGIC;

    SIGNAL blockBtn1 : STD_LOGIC;
    SIGNAL blockBtn2 : STD_LOGIC;
    SIGNAL blockBtn3 : STD_LOGIC;

BEGIN
    reset <= NOT reset_n;
    led_n <= NOT led;
    btn1_sync <= NOT btn1_n_sync;
    btn2_sync <= NOT btn2_n_sync;
    btn3_sync <= NOT btn3_n_sync;

    PROCESS (valid, buzzer_en)
    BEGIN
        IF valid = '1' THEN--verificar professor se for 0 ou 1.
            blockBtn1 <= '0';
            blockBtn2 <= '0';
        ELSE
            blockBtn1 <= btn1_deb;
            blockBtn2 <= btn2_deb;
        END IF;
        IF (buzzer_en = '1') THEN
            blockBtn3 <= '0';
        ELSE
            blockBtn3 <= btn3_deb;
        END IF;

    END PROCESS;

    --Botão 1
    synch_1 : ENTITY work.synch_btn
        PORT MAP(
            clock => clock,
            async_i => btn1_n,
            sync_o => btn1_n_sync
        );
    debounce_1 : ENTITY work.debounce
        PORT MAP(
            clock => clock,
            reset => reset,
            bounce_i => btn1_sync,
            debounce_o => btn1_deb
        );
    --Botão 2
    synch_2 : ENTITY work.synch_btn
        PORT MAP(
            clock => clock,
            async_i => btn2_n,
            sync_o => btn2_n_sync
        );
    debounce_2 : ENTITY work.debounce
        PORT MAP(
            clock => clock,
            reset => reset,
            bounce_i => btn2_sync,
            debounce_o => btn2_deb
        );
    --Botão 3
    synch_3 : ENTITY work.synch_btn
        PORT MAP(
            clock => clock,
            async_i => btn3_n,
            sync_o => btn3_n_sync
        );
    debounce_3 : ENTITY work.debounce
        PORT MAP(
            clock => clock,
            reset => reset,
            bounce_i => btn3_sync,
            debounce_o => btn3_deb
        );

    exe_4 : ENTITY work.exe_4
        PORT MAP(
            clock => clock,
            reset => reset,
            btnInc => blockBtn1,
            btnDec => blockBtn2,
            led => led
        );
    LogicaPrimo : ENTITY work.LogicaPrimo
        PORT MAP(
            clock => clock,
            reset => reset,
            data_i => led,
            en_i => blockBtn3,
            valid_o => valid,
            prime_o => prime
        );

    AtivaBuzzer : ENTITY work.AtivaBuzzer
        PORT MAP(
            clock => clock,
            reset => reset,
            valid_in => valid,
            prime_in => prime,
            buzzer_out => buzzer_en
        );

    buzzer : ENTITY work.buzzer
        PORT MAP(
            clock => clock,
            reset => reset,
            en => buzzer_en,
            buzz => buzzer_o
        );
END main_top;