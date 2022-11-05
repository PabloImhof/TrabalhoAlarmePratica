library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ir is
	port(
		clk		: in std_logic;
		rst		: in std_logic;

		ir 		: in std_logic;

		intr	: out std_logic;
		command : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rlt of ir is
	type fsm_t is (IDLE, LEAD_9, LEAD_4, DATA);
	-- attribute enum_encoding of fsm_t : type is "one-hot"; -- Testar se ok
    signal state      : fsm_t;
	signal next_state : fsm_t;

	signal prev_ir : std_logic;
	signal ir_pos  : std_logic;
	signal ir_neg  : std_logic;
	signal ir_edg  : std_logic;

	signal cntr_9  : std_logic;
	signal cntr_4  : std_logic;
	signal cntr_h  : std_logic;
	signal cntr_l  : std_logic;

	signal err_flag : std_logic;

	signal data_cnt : std_logic_vector( 5 downto 0);
	signal cntr     : std_logic_vector(18 downto 0);
	signal receive  : std_logic_vector(31 downto 0);
begin

	-- Detector de bordas
	ir_pos <= (not prev_ir) and ir;	-- Subida
	ir_neg <= prev_ir and (not ir); -- Descida
	ir_edg <= ir_pos or ir_neg;		-- Qualquer uma das duas

	-- Verificação de contagem de tempo
	cntr_9 <= '1' when (cntr > x"5BBA0") else '0';				-- 450'000 pulsos
	cntr_4 <= '1' when (cntr > x"25990" and cntr < x"47C70") else '0';	-- 225'000 pulsos
	cntr_h <= '1' when (cntr > x"103C4" and cntr < x"18C7C") else '0';	--  84'375 pulsos
	cntr_l <= '1' when (cntr >  x"2904" and cntr <  x"B1BC") else '0';	--  28'125 pulsos
	
	-- Armazenar valor antigo do IR para o detector de borda
	process(clk, rst)
	begin
		if(rst = '1') then
			prev_ir <= '0';
		elsif(rising_edge(clk)) then
			prev_ir <= ir;
		end if;
	end process;

	-- F = 50.000.000 (50 MHz)
	-- p = 1/50MHz = 20 ns
	-- >>>> 9 ms
	-- c = 9 ms / 20 ns = 0.009/0.000000020 = 450'000
	-- 2^16 - 1 = 65536 - 1 = 65'535
	-- 2^17 - 1 = 13...
	-- 2^18 - 1 = 26x....
	-- 2^19 - 1 = 524'287
	-- Portanto, 19 bits é suficiente para armazenar a contagem até 450k
	process(clk, rst)
	begin
		if(rst = '1') then
			cntr <= (others => '0');
		elsif(rising_edge(clk)) then
			if(ir_edg = '1') then
				cntr <= (others => '0');
			else
				cntr <= cntr + '1';
			end if;
		end if;
	end process;

	-- Decodificação de estados da máquina de estados
	process(state, ir, cntr_9, cntr_4, data_cnt, err_flag, prev_ir)
	begin
		case(state) is
			when IDLE =>
				if(ir = '0') then	-- Aguarda pulso 0
					next_state <= LEAD_9;
				else
					next_state <= IDLE;
				end if;
			when LEAD_9 =>
				-- ir_pos?
				if(ir = '1') then	-- Aguarda pulso 1
					if(cntr_9 = '1') then	-- Verifica se passou tempo correto
						next_state <= LEAD_4;
					else
						next_state <= IDLE;
					end if;
				else
					next_state <= LEAD_9;
				end if;
			when LEAD_4 =>
				-- ir_neg?
				if(ir = '0') then	-- Aguarda pulso 0
					if(cntr_4 = '1') then	-- Verifica se passou tempo correto
						next_state <= DATA;
					else
						next_state <= IDLE;
					end if;
				else
					next_state <= LEAD_4;
				end if;
			when DATA =>
				-- Volta para o aguardo quando finalizou a recepção ou ocorreu erro
				-- and ir_pos
				if(data_cnt = x"20" and ir = '1' and prev_ir = '1') then
					next_state <= IDLE;
				elsif(err_flag = '1') then
					next_state <= IDLE;
				else
					next_state <= DATA;
				end if;
		end case;
	end process;

	-- Troca de estados da máquina de estados
	process(clk, rst)
	begin
		if(rst = '1') then
			state <= IDLE;
		elsif(rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;

	-- Controla a recepção de dados
	process(clk, rst)
	begin
		if(rst = '1') then
			receive <= (others => '0');
			err_flag <= '0';
			data_cnt <= (others => '0');
		elsif(rising_edge(clk)) then
			if(state = DATA) then
				if(ir_pos = '1') then
					if(cntr_l = '0') then
						err_flag <= '1';
					end if;
				elsif(ir_neg = '1') then
					if(cntr_h = '1') then
						receive(0) <= '1';
					elsif(cntr_l = '1') then
						receive(0) <= '0';
					else
						err_flag <= '1';
					end if;
					receive(31 downto 1) <= receive(30 downto 0);
					data_cnt <= data_cnt + '1';
				end if;
			else
				receive <= (others => '0');
				data_cnt <= (others => '0');
				err_flag <= '0';
			end if;
		end if;
	end process;

	-- Controla a saída
	process(clk, rst)
	begin
		if(rst = '1') then
			intr <= '0';
			command <= (others => '0');
		elsif(rising_edge(clk)) then
			if(data_cnt = x"20" and ir = '1' and prev_ir = '1' and state = DATA) then
				command <= receive(15 downto 8);
				intr <= '1';
			else
				intr <= '0';
			end if;
		end if;
	end process;
end architecture;
