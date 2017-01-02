library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity IoView is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        ce           : in  std_logic;

        -- host interface (JtagHub or UART or ....)
        DataInValid  : in  std_logic;
        DataIn       : in  std_logic_vector(7 downto 0);

        DataOutReady : in  std_logic;
        DataOutValid : out std_logic;
        DataOut      : out std_logic_vector(7 downto 0);

        --- Input & Ouput--------
        ProbeInputs  : in  std_logic_vector;
        ProbeOutputs : out std_logic_vector
    );
end entity;

architecture struct of IoView is

    component IoViewController is
        port(
            clk          : in  std_logic;
            rst          : in  std_logic;
            ce           : in  std_logic;
            DataInValid  : in  std_logic;
            DataIn       : in  std_logic_vector(7 downto 0);
            DataOutReady : in  std_logic;
            DataOutValid : out std_logic;
            DataOut      : out std_logic_vector(7 downto 0);
            Input        : in  std_logic_vector;
            Output       : out std_logic_vector
        );
    end component IoViewController;

    component Escape is
        port(
            clk          : in  std_logic;
            rst          : in  std_logic;
            ce           : in  std_logic;
            DataInValid  : in  std_logic;
            DataIn       : in  std_logic_vector(7 downto 0);
            DataOutValid : out std_logic;
            DataOut      : out std_logic_vector(7 downto 0);
            reset        : out std_logic
        );
    end component Escape;

    signal Data         : std_logic_vector(7 downto 0);
    signal DataValid    : std_logic;
    signal reset        : std_logic;
begin

    ctr : component IoViewController
        port map(
            clk          => clk,
            rst          => reset,
            ce           => ce,
            DataInValid  => DataValid,
            DataIn       => Data,
            DataOutReady => DataOutReady,
            DataOutValid => DataOutValid,
            DataOut      => DataOut,
            Input        => ProbeInputs,
            Output       => ProbeOutputs
        );

    esc : component Escape
        port map(
            clk          => clk,
            rst          => rst,
            ce           => ce,
            DataInValid  => DataInValid,
            DataIn       => DataIn,
            DataOutValid => DataValid,
            DataOut      => Data,
            reset        => reset
        );

end architecture struct;