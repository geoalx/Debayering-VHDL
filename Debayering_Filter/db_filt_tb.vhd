----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2022 22:18:33
-- Design Name: 
-- Module Name: db_filt_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity db_filt_tb is
generic (
    F:integer := 32
);
end db_filt_tb;

architecture Behavioral of db_filt_tb is

component dbfilter is
generic (
    N: INTEGER := F
);
Port ( new_image : in std_logic;
valid_in : in std_logic;
clk : in std_logic;
rst : in std_logic;
pixel : in std_logic_vector(7 downto 0);
image_finished : out std_logic;
valid_out : out std_logic;
R : out std_logic_vector(7 downto 0);
G : out std_logic_vector(7 downto 0);
B : out std_logic_vector(7 downto 0));
end component;

file image,res: text;
signal clk : std_logic := '1';
signal rst : std_logic := '1';
signal pixel : std_logic_vector(7 downto 0);
signal R,G,B : std_logic_vector (7 downto 0);
signal new_image,valid_out,image_finished : std_logic;
signal valid_in : std_logic:='1';

begin
    
    UUT : dbfilter port map (pixel=>pixel,G=>G,R=>R,B=>B,rst=>rst,clk=>clk,valid_in=>valid_in,new_image=>new_image,valid_out=>valid_out,image_finished=>image_finished);
    --rst <= '1' after 3000ns;
    clk <= not clk after 10ns;
process
variable fline,resline : line;
variable data : integer;
variable counter:integer:=0;
variable file_status:file_open_status;
begin

file_open(image,"C:\Xilinx\lab5_final\lab5\lab5.srcs\sim_1\new\test.txt",read_mode);
file_open(res,"C:\Xilinx\lab5_final\lab5\lab5.srcs\sim_1\new\results_fpga.txt",write_mode);

readline(image,fline);
            read(fline,data);
            new_image <= '1';
            pixel <= std_logic_vector(to_unsigned(data,8));
            wait until clk'event and clk='1';
            new_image <= '0';

while (not endfile(image)) loop
            counter := counter+1;
            if(counter > 2*F+6 and valid_out = '1') then
                write(resline,to_integer(unsigned(R)));
                write(resline,' ');
                write(resline,to_integer(unsigned(G)));
                write(resline,' ');
                write(resline,to_integer(unsigned(B)));
                writeline(res,resline);
            end if;
            readline(image,fline);
            read(fline,data);
            if(data = 500) then
                data := 0;
                valid_in <= '0';
            end if;
            pixel <= std_logic_vector(to_unsigned(data,8));
            wait until clk'event and clk='1';
            valid_in <= '1';

    end loop;
    for i in 0 to 2*F+7 loop
                write(resline,to_integer(unsigned(R)));
                write(resline,' ');
                write(resline,to_integer(unsigned(G)));
                write(resline,' ');
                write(resline,to_integer(unsigned(B)));
                writeline(res,resline);
                wait until clk'event and clk='1';
    end loop;
    
    wait;

    file_close(image);
    file_close(res);
    
    wait;
   
end process;


end Behavioral;
