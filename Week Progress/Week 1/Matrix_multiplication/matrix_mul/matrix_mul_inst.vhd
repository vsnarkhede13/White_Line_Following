	component matrix_mul is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component matrix_mul;

	u0 : component matrix_mul
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

