library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity JtagHub is
    generic(
        MFF_LENGTH : natural
    );
    port(
        clk                   : in  std_logic;
        ce                    : in  std_logic;

        data_dwn              : out std_logic_vector(7 downto 0);

        data_dwn_ready_la     : in  std_logic;
        data_dwn_ready_ioview : in  std_logic;
        data_dwn_ready_gdb    : in  std_logic;
        data_dwn_ready_wfg    : in  std_logic;

        data_dwn_valid_la     : out std_logic;
        data_dwn_valid_ioview : out std_logic;
        data_dwn_valid_gdb    : out std_logic;
        data_dwn_valid_wfg    : out std_logic;

        data_up_ready_la      : out std_logic;
        data_up_ready_ioview  : out std_logic;
        data_up_ready_gdb     : out std_logic;
        data_up_ready_wfg     : out std_logic;

        data_up_valid_la      : in  std_logic;
        data_up_valid_ioview  : in  std_logic;
        data_up_valid_gdb     : in  std_logic;
        data_up_valid_wfg     : in  std_logic;

        data_up_la            : in  std_logic_vector(7 downto 0);
        data_up_ioview        : in  std_logic_vector(7 downto 0);
        data_up_wfg           : in  std_logic_vector(7 downto 0);
        data_up_gdb           : in  std_logic_vector(7 downto 0)
    );
end entity;

architecture structure of JtagHub is
    function get_data_from_jtag_host(unused : integer) return integer;
    attribute foreign of get_data_from_jtag_host : function is "VHPIDIRECT get_data_from_jtag_host";
    function get_data_from_jtag_host(unused : integer) return integer is
    begin
        assert false severity failure;
    end get_data_from_jtag_host;

    procedure set_data_to_jtag_host(data : integer);
    attribute foreign of set_data_to_jtag_host : procedure is "VHPIDIRECT set_data_to_jtag_host";
    procedure set_data_to_jtag_host(data : integer) is
    begin
        assert false severity failure;
    end set_data_to_jtag_host;

    signal data_dwn_ready  : std_logic_vector(3 downto 0);
    signal enable_o        : std_logic_vector(3 downto 0);
    signal data_in_ready_o : std_logic_vector(3 downto 0);
    signal data_in_valid   : std_logic_vector(3 downto 0);
    type data_in_t         is array (3 downto 0) of std_logic_vector(7 downto 0);
    signal data_in         : data_in_t;

begin
    data_dwn_ready <= data_dwn_ready_wfg & data_dwn_ready_gdb & data_dwn_ready_ioview & data_dwn_ready_la;
    data_in_valid <= data_up_valid_wfg & data_up_valid_gdb & data_up_valid_ioview & data_up_valid_la;
    data_in <= (3 => data_up_wfg, 2 => data_up_gdb, 1 => data_up_ioview, 0 => data_up_la);
    process(clk)
        variable data_temp_dwn : std_logic_vector(15 downto 0);
        variable data_temp_up  : std_logic_vector(15 downto 0);

        variable data_pending  : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            if ce = '1' then
                if data_pending = "UUUU" then
                    data_pending := x"0";
                end if;
                if data_pending = x"0" then
                    data_temp_dwn := std_logic_vector(to_unsigned(get_data_from_jtag_host(0), data_temp_dwn'length));

                    data_dwn <= data_temp_dwn(7 downto 0);
                    data_pending := data_temp_dwn(11 downto 8);
                end if;

                enable_o <= (others => '0');
                case data_pending is
                when x"C" => if data_dwn_ready(0) = '1' and enable_o(0) = '0' then enable_o(0) <= '1'; data_pending := x"0"; end if;
                when x"A" => if data_dwn_ready(1) = '1' and enable_o(1) = '0' then enable_o(1) <= '1'; data_pending := x"0"; end if;
                when x"9" => if data_dwn_ready(2) = '1' and enable_o(2) = '0' then enable_o(2) <= '1'; data_pending := x"0"; end if;
                when x"B" => if data_dwn_ready(3) = '1' and enable_o(3) = '0' then enable_o(3) <= '1'; data_pending := x"0"; end if;
                when others => data_pending := x"0";
                end case;

                data_in_ready_o <= (others => '1');
                if data_in_valid(0) = '1' and data_in_ready_o(0) = '1' then
                    data_in_ready_o(0) <= '0';
                    data_temp_up := x"0C" & data_in(0);
                    set_data_to_jtag_host(to_integer(to_01(unsigned(data_temp_up))));
                end if;
                if data_in_valid(1) = '1' and data_in_ready_o(1) = '1' then
                    data_in_ready_o(1) <= '0';
                    data_temp_up := x"0A" & data_in(1);
                    set_data_to_jtag_host(to_integer(to_01(unsigned(data_temp_up))));
                end if;
                if data_in_valid(2) = '1' and data_in_ready_o(2) = '1' then
                    data_in_ready_o(2) <= '0';
                    data_temp_up := x"09" & data_in(2);
                    set_data_to_jtag_host(to_integer(to_01(unsigned(data_temp_up))));
                end if;
                if data_in_valid(3) = '1' and data_in_ready_o(3) = '1' then
                    data_in_ready_o(3) <= '0';
                    data_temp_up := x"0B" & data_in(3);
                    set_data_to_jtag_host(to_integer(to_01(unsigned(data_temp_up))));
                end if;
            end if;
        end if;
    end process;
    data_dwn_valid_la     <= enable_o(0);
    data_dwn_valid_ioview <= enable_o(1);
    data_dwn_valid_gdb    <= enable_o(2);
    data_dwn_valid_wfg    <= enable_o(3);
    data_up_ready_la      <= data_in_ready_o(0);
    data_up_ready_ioview  <= data_in_ready_o(1);
    data_up_ready_gdb     <= data_in_ready_o(2);
    data_up_ready_wfg     <= data_in_ready_o(3);

end architecture structure;
