module dec2hex(input [11:0] count, output reg [8:0] th,h,t,u);
	reg [7:0] th1,h1,t1,u1;
	
	always@(*) 
		begin
			th1=(count/1000);
			h1=(count/100)%10;
			t1=(count/10)%10;
			u1=count%10;	
			th={1'b1,(th1+8'h30)};
			h={ 1'b1,(h1+8'h30)};
			t={ 1'b1,(t1+8'h30)};
			u={ 1'b1,(u1+8'h30)};
		end
endmodule