LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY main_alarme_top IS
    PORT (
        clock : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;
        btn1_n : IN STD_LOGIC;
        btn2_n : IN STD_LOGIC;
        btn3_n : IN STD_LOGIC;
        ir_in : IN STD_LOGIC;

        --visor falta
        led_n : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        buzzer_o : OUT STD_LOGIC
    );
END main_alarme_top;

ARCHITECTURE main_alarme_top OF main_alarme_top IS

    SIGNAL reset : STD_LOGIC;
    SIGNAL led : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL dig : STD_LOGIC_VECTOR(3 DOWNTO 0);

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
    --IR
    SIGNAL ir_sync : STD_LOGIC;
    SIGNAL interrupcao_o : STD_LOGIC;
    SIGNAL command_o : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --buzzer
    SIGNAL buzzer_en : STD_LOGIC;
    SIGNAL buzzer_out_alarme : STD_LOGIC;
BEGIN

    --inverter sinais por causa do FPGA
    reset <= NOT reset_n;
    led_n <= NOT led;
    btn1_sync <= NOT btn1_n_sync;
    btn2_sync <= NOT btn2_n_sync;
    btn3_sync <= NOT btn3_n_sync;
    buzzer_en <= buzzer_out_alarme;

    PROCESS (command_o)
    BEGIN
        CASE command_o IS
            WHEN x"68" => dig <= "0000";
            WHEN x"30" => dig <= "0001";
            WHEN x"18" => dig <= "0010";
            WHEN x"7A" => dig <= "0011";
            WHEN x"10" => dig <= "0100";
            WHEN x"38" => dig <= "0101";
            WHEN x"5A" => dig <= "0110";
            WHEN x"42" => dig <= "0111";
            WHEN x"4A" => dig <= "1000";
            WHEN x"52" => dig <= "1001";
            WHEN OTHERS => dig <= "1111";
        END CASE;
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
    --IR Sincronizador
    synch_IR : ENTITY work.synch_btn
        PORT MAP(
            clock => clock,
            async_i => ir_in,
            sync_o => ir_sync
        );

    ir : ENTITY work.ir
        PORT MAP(
            clk => clock,
            rst => reset,
            ir => ir_sync,
            intr => interrupcao_o,
            command => command_o
        );

    buzzer : ENTITY work.buzzer
        PORT MAP(
            clock => clock,
            reset => reset,
            en => buzzer_en,
            buzz => buzzer_o
        );

    -- aqui tem rever toda a logica 
    alarme : ENTITY work.alarme
        PORT MAP(
            clock => clock,
            reset => reset,
            btn1 => btn1_deb,
            btn2 => btn2_deb,
            btn3 => btn3_deb,
            senha_in => dig,
            led_out => led,
            buzz_out => buzzer_out_alarme
        );
END main_alarme_top;