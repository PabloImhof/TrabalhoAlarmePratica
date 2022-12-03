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
        --LED
        led_n : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        --BUZZER
        buzzer_o : OUT STD_LOGIC;
        --VISOR
        seg_no : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sel_no : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END main_alarme_top;

ARCHITECTURE main_alarme_top OF main_alarme_top IS

    SIGNAL reset : STD_LOGIC;
    SIGNAL reset_bouncer_in : STD_LOGIC;
    SIGNAL reset_bouncer_out : STD_LOGIC;
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
    SIGNAL btn1_ir : STD_LOGIC;
    SIGNAL btn2_ir : STD_LOGIC;
    SIGNAL btn3_ir : STD_LOGIC;
    --buzzer
    SIGNAL buzzer_en : STD_LOGIC;
    SIGNAL buzzer_out_alarme : STD_LOGIC;
    SIGNAL div : STD_LOGIC_VECTOR (20 DOWNTO 0);
    --7segmentos valor anodo
    SIGNAL seg0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL seg2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL seg3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    --recebe o numero PARA ele e devolve o numero montado nos anodos.
    SIGNAL vsr0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL vsr1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL vsr2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL vsr3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL enable : STD_LOGIC_VECTOR(3 DOWNTO 0); --quantos digitos liga no visor

    SIGNAL cntr : STD_LOGIC_VECTOR(3 DOWNTO 0); --conta a casa que deve colocar o numero no visor
    SIGNAL cntr_ir : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL limpar : STD_LOGIC;

BEGIN
    --inverter sinais por causa do FPGA
    reset_bouncer_in <= NOT reset_n;
    reset <= reset_bouncer_out;

    led_n <= NOT led;
    btn1_sync <= NOT btn1_n_sync;
    btn2_sync <= NOT btn2_n_sync;
    btn3_sync <= NOT btn3_n_sync;
    buzzer_en <= buzzer_out_alarme;

    --apaga visor que não tem valor
    PROCESS (cntr, vsr0, vsr1, vsr2, vsr3)
    BEGIN
        IF (cntr > "0011") THEN
            enable <= "1111";
        ELSIF (cntr = "0011") THEN
            enable <= "0111";
        ELSIF (cntr = "0010") THEN
            enable <= "0011";
        ELSIF (cntr = "0001") THEN
            enable <= "0001";
        ELSIF (cntr = "0000" AND vsr0 /= "0000") THEN
            enable <= "0000";
        ELSE
            enable <= "0000";
        END IF;
    END PROCESS;

    --recebe IR transforma em BINARIO e atribui "PASSA" valor
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

    PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            vsr0 <= (OTHERS => '0');
            vsr1 <= (OTHERS => '0');
            vsr2 <= (OTHERS => '0');
            vsr3 <= (OTHERS => '0');
            cntr <= (OTHERS => '0');
            btn1_ir <= '0';
            btn2_ir <= '0';
            btn3_ir <= '0';
            limpar <= '0';

        ELSIF rising_edge(clock) THEN
            --esse cntr por que ficava travado o valor no btn do ir -- reseta o valor recebido pelo ir
            cntr_ir <= cntr_ir + 1;
            IF (cntr_ir = "0000000000000000000000" OR interrupcao_o = '1') THEN
                btn1_ir <= '0';
                btn2_ir <= '0';
                btn3_ir <= '0';
                limpar <= '0';
                IF (btn3_ir = '1' OR limpar = '1' ) THEN
                    vsr0 <= (OTHERS => '0');
                    vsr1 <= (OTHERS => '0');
                    vsr2 <= (OTHERS => '0');
                    vsr3 <= (OTHERS => '0');
                    cntr <= (OTHERS => '0');
                END IF;
            END IF;

            IF (btn3_deb = '1') THEN
                limpar <= '1';
            END IF;

            IF interrupcao_o = '1' THEN
                IF dig = "1111" THEN -- se digito não for numero é comando  
                    CASE command_o IS
                        WHEN x"A2" =>
                            btn1_ir <= '1';
                        WHEN x"62" =>
                            btn2_ir <= '1';
                        WHEN x"E2" =>
                            btn3_ir <= '1';
                        WHEN OTHERS =>
                            vsr0 <= (OTHERS => '0');
                            vsr1 <= (OTHERS => '0');
                            vsr2 <= (OTHERS => '0');
                            vsr3 <= (OTHERS => '0');
                            cntr <= (OTHERS => '0');
                    END CASE;

                ELSE -- se não comando recebe direto digito
                    --fazer contador que conta o numero de vezes que clicou no dig
                    cntr <= cntr + 1;
                    IF (cntr <= "0011") THEN

                        IF (cntr = "0000") THEN
                            vsr0 <= dig;
                        END IF;

                        IF (cntr = "0001") THEN
                            vsr1 <= vsr0;
                            vsr0 <= dig;
                        END IF;

                        IF (cntr = "0010") THEN
                            vsr2 <= vsr1;
                            vsr1 <= vsr0;
                            vsr0 <= dig;
                        END IF;

                        IF (cntr = "0011") THEN
                            vsr3 <= vsr2;
                            vsr2 <= vsr1;
                            vsr1 <= vsr0;
                            vsr0 <= dig;
                        END IF;

                    ELSE
                        cntr <= (OTHERS => '0');
                        vsr0 <= (OTHERS => '0');
                        vsr1 <= (OTHERS => '0');
                        vsr2 <= (OTHERS => '0');
                        vsr3 <= (OTHERS => '0');
                    END IF;

                END IF;
            END IF;
        END IF;
    END PROCESS;

    --debouncer reset, pois estava ficando ativado na placa.
    debounce_reset : ENTITY work.debounce
        PORT MAP(
            clock => clock,
            reset => '0',
            bounce_i => reset_bouncer_in,
            debounce_o => reset_bouncer_out
        );

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

    dec0 : ENTITY work.SevenSegmentDecoder
        PORT MAP(
            bcd_i => vsr0,
            seg_o => seg0
        );

    dec1 : ENTITY work.SevenSegmentDecoder
        PORT MAP(
            bcd_i => vsr1,
            seg_o => seg1
        );

    dec2 : ENTITY work.SevenSegmentDecoder
        PORT MAP(
            bcd_i => vsr2,
            seg_o => seg2
        );

    dec3 : ENTITY work.SevenSegmentDecoder
        PORT MAP(
            bcd_i => vsr3,
            seg_o => seg3
        );

    driver : ENTITY work.SevenSegmentDriver
        PORT MAP(
            clk_i => clock,
            rst_ni => reset,
            en_i => enable, --quantas casas ligadas
            dots_i => "0000", -- aonde é o ponto
            seg0_i => seg0, -- recebe o valor ja pronto e montado dos anodo do DECODER
            seg1_i => seg1, -- recebe o valor ja pronto e montado dos anodo do DECODER
            seg2_i => seg2, -- recebe o valor ja pronto e montado dos anodo do DECODER
            seg3_i => seg3, -- recebe o valor ja pronto e montado dos anodo do DECODER
            seg_no => seg_no, -- manda o valor
            sel_no => sel_no -- manda qual é a casa
        );

    alarme : ENTITY work.alarme
        PORT MAP(
            clock => clock,
            reset => reset,
            btn1 => btn1_deb,
            btn2 => btn2_deb,
            btn3 => btn3_deb,
            btn1_ir_in => btn1_ir,
            btn2_ir_in => btn2_ir,
            btn3_ir_in => btn3_ir,
            senhavsr0_in => vsr0,
            senhavsr1_in => vsr1,
            senhavsr2_in => vsr2,
            senhavsr3_in => vsr3,
            led_out => led,
            buzz_out => buzzer_out_alarme,
            div_out => div
        );

    --só fica invertendo o sinal do buzzer para sair o som
    buzzer : ENTITY work.buzzer
        PORT MAP(
            clock => clock,
            reset => reset,
            en => buzzer_en,
            in_div => div,
            buzz => buzzer_o
        );

END main_alarme_top;