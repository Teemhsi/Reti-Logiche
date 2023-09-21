library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

entity project_reti_logiche is
--  Port ( );
-- INGRESSI DEL COMPONENETE
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_w     : in std_logic;
-- USCITE DEL COMPONENETE
        o_z0    : out std_logic_vector(7 downto 0);
        o_z1    : out std_logic_vector(7 downto 0);
        o_z2    : out std_logic_vector(7 downto 0);
        o_z3    : out std_logic_vector(7 downto 0);
        o_done  : out std_logic;
-- INTERFACCE CON LA MEMORIA RAM
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in  std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic := '0';
        o_mem_en    : out std_logic := '1'
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
-- leggo W e separo canale d'uscita/indrizzo memeoria ram
-- leggo dalla memoria il dato
-- lo salvo in un registro
-- individuo il canale d'uscita
-- trascrivo il dato in uscita e metto DONE = 1
    type state_type IS (IDLE,LETTURA_CANALE, CHECKER, READ_RAM, WAIT_RAM,SET_RAM, WRITE_OUT, DONE);
    SIGNAL state_curr, state_next : state_type;
    
    SIGNAL i_w_aux  : std_logic := '0';
    SIGNAL o_z0_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z1_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z2_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z3_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z0_reg : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z1_reg : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z2_reg : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z3_reg : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z0_reg_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z1_reg_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z2_reg_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_z3_reg_aux : std_logic_vector (7 downto 0) := "00000000";
    SIGNAL o_done_aux   : std_logic := '0';
    
    SIGNAL o_mem_addr_aux, o_mem_addr_reg, o_mem_addr_reg_aux  : std_logic_vector (15 downto 0) := "0000000000000000";
    SIGNAL i_mem_data_aux   : std_logic_vector (7 downto 0) := "00000000";
    
    
    SIGNAL input_1,input_1_aux  : std_logic_vector(15 DOWNTO 0) := "0000000000000000";
    SIGNAL store,store_aux  : std_logic_vector(17 DOWNTO 0) := "000000000000000000";
    SIGNAL count, count_aux    : integer range -1 to 18 := 0;
    SIGNAL input_canale, input_canale_aux : std_logic_vector(1 downto 0) := (others => '0');
    SIGNAL dato_mem, dato_mem_aux   : std_logic_vector(7 downto 0) := "00000000";
begin
    PROCESS(i_clk,i_rst)
    BEGIN
        if(i_rst = '1') THEN
            state_curr <= IDLE;
            count <= 0;
            input_1 <= "0000000000000000";
            store <= "000000000000000000";
            input_canale <= "00";
            dato_mem <= "00000000";
            o_z0_reg <= "00000000";
            o_z1_reg <= "00000000";
            o_z2_reg <= "00000000";
            o_z3_reg <= "00000000";
            o_mem_en <= '1';
            o_mem_we <= '0';
            o_mem_addr_reg <= "0000000000000000";
        ELSIF (rising_edge(i_clk)) THEN
            o_done <= o_done_aux;
            o_z0 <= o_z0_aux;
            o_z1 <= o_z1_aux;
            o_z2 <= o_z2_aux;
            o_z3 <= o_z3_aux;
            o_mem_en <= '1';
            o_mem_we <= '0';
            o_mem_addr <= o_mem_addr_aux;
            state_curr <= state_next;
            count <= count_aux;
            input_1 <= input_1_aux;
            input_canale <= input_canale_aux;
            dato_mem <= dato_mem_aux;
            store <= store_aux;
            o_z0_reg <= o_z0_reg_aux;
            o_z1_reg <= o_z1_reg_aux;
            o_z2_reg <= o_z2_reg_aux;
            o_z3_reg <= o_z3_reg_aux;
            o_mem_addr_reg <=  o_mem_addr_reg_aux;
        END IF;
     END PROCESS;
     
        PROCESS (i_start,store, state_curr,dato_mem, i_w, i_mem_data, input_1,count, input_canale,o_z0_reg, o_z1_reg, o_z2_reg, o_z3_reg, o_mem_addr_reg)
        BEGIN
            o_done_aux <= '0';
            o_mem_addr_aux <= "0000000000000000";
            o_z0_aux <= "00000000";
            o_z1_aux <= "00000000";
            o_z2_aux <= "00000000";
            o_z3_aux <= "00000000";
            
            state_next <= state_curr;
            count_aux <= count;
            input_1_aux <= input_1;
            dato_mem_aux <= i_mem_data;
            input_canale_aux <= input_canale;
            store_aux <= store;
             o_z0_reg_aux <= o_z0_reg;
             o_z1_reg_aux <= o_z1_reg;
             o_z2_reg_aux <= o_z2_reg;
             o_z3_reg_aux <= o_z3_reg;
             o_mem_addr_aux <= o_mem_addr_reg;
            
            CASE state_curr IS
                WHEN IDLE =>
                        IF(i_start = '1') THEN
                                state_next <= LETTURA_CANALE;
                                count_aux <= count +1;
                                store_aux(17-count) <= i_w;
                        END IF;
                        
                WHEN LETTURA_CANALE => 
                    if(i_start = '0' ) then
                        state_next <= CHECKER;
                    elsif(count < 18) then
                        count_aux <= count +1;
                        store_aux(17-count) <= i_w;
                    END IF;
                 WHEN CHECKER =>
                        input_canale_aux(0) <= store(16);
                        input_canale_aux(1) <= store(17);
                          input_1_aux <= std_logic_vector(SHIFT_RIGHT(unsigned (store(15 downto 0)),18-count));
                          state_next <= SET_RAM;                     
                 WHEN SET_RAM =>
                        o_mem_addr_reg_aux <= input_1;
                        state_next <= READ_RAM;
                                              
                 WHEN READ_RAM  =>
                    state_next <= WAIT_RAM;
                    
                 WHEN WAIT_RAM =>
                    state_next <= WRITE_OUT;   
                      
                 WHEN WRITE_OUT =>
                    state_next <= DONE;    
                    CASE input_canale IS
                    WHEN "00" =>
                         o_z0_reg_aux <= i_mem_data;     
                    WHEN "01" =>
                         o_z1_reg_aux <= i_mem_data;
                    WHEN "10" =>
                         o_z2_reg_aux <= i_mem_data;                                                        
                    WHEN others =>
                         o_z3_reg_aux <= i_mem_data;
                    END CASE;
                  
                 WHEN DONE =>
                    o_done_aux <= '1';
                    o_mem_addr_reg_aux <=  o_mem_addr_reg;
                    o_z0_aux <= o_z0_reg;
                    o_z1_aux <= o_z1_reg;
                    o_z2_aux <= o_z2_reg;
                    o_z3_aux <= o_z3_reg;
                    if(i_start = '0') THEN
                        state_next <= IDLE;
                        dato_mem_aux <= "00000000";
                        count_aux <= 0;
                                       
                        input_1_aux <= "0000000000000000";
                        input_canale_aux <= "00";
                        store_aux <= "000000000000000000";
                        --o_mem_addr_aux <= "0000000000000000";
                    END IF;       
            END CASE;
            
        END PROCESS;

end Behavioral;
