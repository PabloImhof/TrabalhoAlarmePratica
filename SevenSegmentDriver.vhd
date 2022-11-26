library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SevenSegmentDriver is
	port(
		clk_i  : in std_logic;
		rst_ni : in std_logic;

		en_i   : in std_logic_vector(3 downto 0);
		dots_i : in std_logic_vector(3 downto 0);
		seg0_i : in std_logic_vector(6 downto 0);
		seg1_i : in std_logic_vector(6 downto 0);
		seg2_i : in std_logic_vector(6 downto 0);
		seg3_i : in std_logic_vector(6 downto 0);

		seg_no  : out std_logic_vector(7 downto 0);
		sel_no  : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of SevenSegmentDriver is
	signal cntr : std_logic_vector(15 downto 0);
	signal seg  : std_logic_vector(7 downto 0);
	signal sel  : std_logic_vector(3 downto 0);
begin

	sel_no <= not (sel and en_i);
	seg_no <= not seg;

	process(clk_i, rst_ni)
	begin
		if(rst_ni = '1') then
			cntr <= (others => '0');
		elsif(rising_edge(clk_i)) then
			cntr <= cntr + '1';
			if(cntr = x"C350") then
				cntr <= (others => '0');
			end if;
		end if;
	end process;

	process(clk_i, rst_ni)
	begin
		if(rst_ni = '1') then
			sel <= "0001";
		elsif(rising_edge(clk_i)) then
			if(cntr = (cntr'range => '0')) then
				sel(3 downto 1) <= sel(2 downto 0);
				sel(0) <= sel(3);
			end if;
		end if;
	end process;

	process(sel, seg0_i, seg1_i, seg2_i, seg3_i, dots_i)
	begin
		case(sel) is               -- Concatenação
			when "0001" => seg <= seg0_i & dots_i(0);
			when "0010" => seg <= seg1_i & dots_i(1);
			when "0100" => seg <= seg2_i & dots_i(2);
			when "1000" => seg <= seg3_i & dots_i(3);
			when others => seg <= (others => '0');
		end case;
	end process;

end architecture;
