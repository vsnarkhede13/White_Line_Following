	component hello_world is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component hello_world;

	u0 : component hello_world
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

