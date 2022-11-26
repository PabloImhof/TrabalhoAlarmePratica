library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SevenSegmentDecoder is
	port(
		bcd_i : in std_logic_vector(3 downto 0);

		seg_o : out std_logic_vector(6 downto 0)
	);
end entity;

architecture rtl of SevenSegmentDecoder is
begin

	--     a
	--  f     b
	--     g
	--  e     c
	--     d

	process(bcd_i)
	begin
		case(bcd_i) is
			when "0000" => seg_o <= "1111110";
			when "0001" => seg_o <= "0110000";
			when "0010" => seg_o <= "1101101";
			when "0011" => seg_o <= "1111001";
			when "0100" => seg_o <= "0110011";
			when "0101" => seg_o <= "1011011";
			when "0110" => seg_o <= "1011111";
			when "0111" => seg_o <= "1110000";
			when "1000" => seg_o <= "1111111";
			when "1001" => seg_o <= "1111011";
			when others => seg_o <= "0000000";
		end case;
	end process;

end architecture;
