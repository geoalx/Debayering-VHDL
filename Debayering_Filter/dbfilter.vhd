----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.05.2022 14:32:23
-- Design Name: 
-- Module Name: dbfilter - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dbfilter is
generic (
    N: INTEGER := 32
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
end dbfilter;

architecture Behavioral of dbfilter is

component fifo_generator_0 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

component fifo_generator_1 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

component fifo_generator_2 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

component fifo_generator_3 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

component fifo_generator_4 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

signal full,notrst : std_logic;

type arr is array(2 downto 0) of std_logic_vector(9 downto 0);
type win is array(2 downto 0) of arr;

signal window: win := (others => (others => (others => '0')));
signal out0,out1,out2 : std_logic_vector(7 downto 0);
signal flag_left,flag_up,flag_right,flag_down : std_logic_vector(9 downto 0);
signal val0,val1,val2 : std_logic;
--signal counth,countv,acounth,acountv,cycle_counter : std_logic_vector(11 downto 0) := (others => '0');
signal cycle_counter : std_logic_vector(integer(ceil(log2(real(N*N)))) downto 0) := (others => '0');
signal counth2,countv2,counth,countv,acounth,acountv :std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0) := (others => '0');
signal flag_new_image,flag_image_start: std_logic := '0';

signal tempout1: std_logic_vector(7 downto 0):= (others => '0');
type temp_type is array(1 downto 0) of std_logic_vector(7 downto 0);
signal tempout0 : temp_type := (others => (others => '0'));    

signal R_temp,G_temp,B_temp : std_logic_vector (9 downto 0);
signal tempcen : std_logic_vector(7 downto 0);

begin

notrst <= not rst;
FIFO32: 
if N=32 generate 
            FIFO0: fifo_generator_0 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>pixel,dout=>out0);
            FIFO1: fifo_generator_0 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out0,dout=> out1);
            FIFO2: fifo_generator_0 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out1,dout=> out2);
end generate FIFO32;

FIFO16:
if N=16 generate
            FIFO0: fifo_generator_1 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>pixel,dout=>out0);
            FIFO1: fifo_generator_1 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out0,dout=> out1);
            FIFO2: fifo_generator_1 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out1,dout=> out2);
end generate FIFO16;

FIFO64:
if N=64 generate
            FIFO0: fifo_generator_2 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>pixel,dout=>out0);
            FIFO1: fifo_generator_2 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out0,dout=> out1);
            FIFO2: fifo_generator_2 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out1,dout=> out2);
end generate FIFO64;

FIFO128:
if N=128 generate
            FIFO0: fifo_generator_3 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>pixel,dout=>out0);
            FIFO1: fifo_generator_3 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out0,dout=> out1);
            FIFO2: fifo_generator_3 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out1,dout=> out2);
end generate FIFO128;

FIFO1024:
if N=1024 generate
            FIFO0: fifo_generator_4 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>pixel,dout=>out0);
            FIFO1: fifo_generator_4 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out0,dout=> out1);
            FIFO2: fifo_generator_4 port map(clk=>clk,srst=>notrst,wr_en=>valid_in,rd_en=>valid_in,full=>open,empty=>open,din=>out1,dout=> out2);
end generate FIFO1024;





process(clk,rst)
begin

if rst = '0' then
    valid_out <= '0';
    counth <= (others=>'0');
    countv <= (others=>'0');
    acounth <= (others=>'0');
    acountv <= (others=>'0');
    cycle_counter <= (others => '0');
    window <= (others => (others => (others => '0')));
    flag_left <= (others => '0');
    flag_up <= (others => '0');
    flag_down <= (others => '0');
    flag_right <= (others => '0');
    flag_new_image <= '0';
    flag_image_start <= '0';
    tempout1 <= (others=>'0');
    tempout0 <= (others => (others=>'0'));
    R <= (others => '0');
    G <= (others => '0');
    B <= (others => '0');
    R_temp <= (others => '0');
    G_temp <= (others => '0');
    B_temp <= (others => '0');
            
    
elsif clk'event and clk = '1' then
if(new_image='1' and valid_in='1') then

flag_new_image <= '1';
cycle_counter <= (others => '0');
end if;
image_finished <='0';
    if ( to_integer(unsigned(counth2)) = N-2 and to_integer(unsigned(countv2)) > N-6) or (to_integer(unsigned(counth2)) > N-2) then
        valid_out <= '1';
    elsif counth = 0 and countv = 0 then
        valid_out <= '0';
    else 
        valid_out <= valid_in;
    end if;
    if flag_new_image = '1' and valid_in = '1' then
        cycle_counter <= cycle_counter +1;
    end if;
    
    
    if to_integer(unsigned(cycle_counter)) = 2*N+3 then
        flag_new_image <='0';
        flag_image_start <= '1';
        counth <= (others => '0');
        countv <= (others => '0');
        acounth <= (others => '0');
        acountv <= (0 => '1',others => '0'); 
        flag_up <= (others => '0');
        flag_left <= (others=>'0');
        flag_down <= (others => '1');
        flag_right <= (others=>'1');
    end if;

     
    
        if (valid_in = '1') or ((to_integer(unsigned(counth2)) = N-2 and to_integer(unsigned(countv2)) > N-6) or (to_integer(unsigned(counth2)) > N-2)) then
        -- input_logic
        if not (out0 = "XXXXXXXX") then
                for j in 2 downto 1 loop
                    window(0)(j) <= window(0)(j-1);
                end loop;
                tempout0(1) <= tempout0(0);
                tempout0(0) <= out0;
                window(0)(0) <= "00"&tempout0(1);
        end if;
         if not (out1 = "XXXXXXXX") then
            for j in 2 downto 1 loop
                window(1)(j) <= window(1)(j-1);
            end loop;
            tempout1 <= out1;
        window(1)(0) <= "00"&tempout1;
     end if;
     if not (out2 = "XXXXXXXX") then
        for j in 2 downto 1 loop
            window(2)(j) <= window(2)(j-1);
        end loop;
    window(2)(0) <= "00"&out2;
     end if;
     
 -- end_input_logic
        if (flag_image_start = '1') then
       
     -- control logic
    if acountv = 0 then
    flag_left <= (others => '0');
    else  flag_left <= (others => '1');
    end if;
    
  
    if to_integer(unsigned(acounth)) = 0 then
    flag_up <= (others => '0');
    else  flag_up <= (others => '1');
    end if;
    
    if to_integer(unsigned(acountv)) = N-1 then
    flag_right <= (others => '0');
    else  flag_right <= (others => '1');
    end if;
   
    if to_integer(unsigned(acounth)) = N-1 then
    flag_down <= (others => '0');
    else  flag_down <= (others => '1');
    end if;
   -- end_control_logic
    countv <= acountv;
    counth <= acounth;
    acountv <= acountv + 1;
    if acountv = N - 1 then
    acounth <= acounth + 1;
    acountv <= (others => '0');
    end if;
    if countv2= N-1 and counth2 = N-1 then
        image_finished <= '1';
        flag_image_start <= '0';
    end if;
    counth2 <= counth;
    countv2 <= countv;

    if counth(0)='0' then 
        
        --green_with_up red
        if  countv(0) = '0' then
            G_temp <= window(1)(1);
            R_temp <= window(0)(1) + (window(2)(1) and flag_up);
            B_temp <= window(1)(0) + (window(1)(2) and flag_left);
           
        --blue
        else  
           B_temp <= window(1)(1);
           G_temp <= window(0)(1) + (window(1)(0) and flag_right) + window(1)(2) + (window(2)(1)and flag_up);
           R_temp <= (window(0)(0) and flag_right) + window(0)(2) + (window(2)(0) and (flag_up and flag_right)) + (window(2)(2)and flag_up);
       
        end if;
              
    else 
        --red
        if countv(0) = '0' then
            R_temp <= window(1)(1);
            G_temp <= (window(0)(1) and flag_down) + window(1)(0) + (window(1)(2) and flag_left) + (window(2)(1));
            B_temp <= ((window(0)(0) and flag_down) + (window(0)(2) and (flag_left and flag_down)) + window(2)(0) + (window(2)(2) and flag_left));
           
         
     --green with up blue
        else 
            G_temp <= window(1)(1);
            R_temp <= ((window(1)(0) and flag_right) + window(1)(2));
            B_temp <= (window(0)(1) and flag_down) + window(2)(1);
            
        end if;
                
    end if;
    if counth2(0)='0' then 
        
    --green_with_up red
    if  countv2(0) = '0' then
        G <= G_temp(7 downto 0);
        R <= R_temp(8 downto 1);
        B <= B_temp(8 downto 1);
    --blue
    else           
        G <= G_temp(9 downto 2);
        R <= R_temp(9 downto 2);
        B <= B_temp(7 downto 0);
    end if;
   
   else 
       --red
       if countv2(0) = '0' then
       
           G <= G_temp(9 downto 2);
           R <= R_temp(7 downto 0);
           B <= B_temp(9 downto 2);
    --green with up blue
       else 
       
           G <= G_temp(7 downto 0);
           R <= R_temp(8 downto 1);
           B <= B_temp(8 downto 1);
       end if;
   end if;
   else 
    valid_out <= '0';
    end if;
        
 end if;
end if;
end process;
 
end Behavioral;
