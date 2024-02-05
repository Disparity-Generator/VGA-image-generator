library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity vga_bildgenerator is
  port (
    i_clock          : in    std_logic;
    i_reset_n        : in    std_logic;
    i_chosen_picture : in    std_logic_vector(1 downto 0);

    o_pixeldata : out   std_logic_vector(23 downto 0);
    o_valid     : out   std_logic;
    o_new_frame : out   std_logic
  );
end entity vga_bildgenerator;

architecture arch of vga_bildgenerator is

  signal r_current_col         : integer range 0 to 640;
  signal r_current_row         : integer range 0 to 480;
  signal r_current_pixel_count : integer range 0 to 307200;

  constant c_red   : std_logic_vector := "111111110000000000000000";
  constant c_green : std_logic_vector := "000000001111111100000000";
  constant c_blue  : std_logic_vector := "000000000000000011111111";

  constant c_max_rows : integer := 480;
  constant c_max_cols : integer := 640;

  signal w_current_pixel : std_logic_vector(23 downto 0);

begin

  --------------------------------
  -- Pixel, Row and Col Counter --
  --------------------------------

  proc_pixel_counter : process (i_reset_n, i_clock) is
  begin

    if (i_reset_n = '0') then
      r_current_pixel_count <= 0;
    elsif (rising_edge(i_clock)) then
      if (r_current_pixel_count < 307200) then
        r_current_pixel_count <= r_current_pixel_count + 1;
      else
        r_current_pixel_count <= 0;
      end if;
    end if;

  end process proc_pixel_counter;

  proc_height_width_counter : process (i_reset_n, i_clock) is
  begin

    if (i_reset_n = '0') then
      r_current_col <= 0;
      r_current_row <= 0;
    elsif (rising_edge(i_clock)) then
      if (r_current_col < c_max_cols - 1 and r_current_pixel_count /= 307200) then
        r_current_col <= r_current_col + 1;
      else
        r_current_col <= 0;

        if(r_current_row < c_max_rows) then
        r_current_row <= r_current_row + 1;
        else 
          r_current_row <= 0;
        end if;
      end if;
    end if;

  end process proc_height_width_counter;

  ---------------
  -- image mux --
  ---------------

  process (r_current_col, r_current_row) is
  begin

    case to_integer(unsigned(i_chosen_picture)) is

      ----------------------------------------------------
      -- regular pattern of red, green and blue squares --
      ----------------------------------------------------
      when 0 =>

        if ((r_current_col >= 0 and r_current_col < 25)
            
            or (r_current_col >= 75 and r_current_col < 100)
            
            or (r_current_col >= 150 and r_current_col < 175)
            
            or (r_current_col >= 225 and r_current_col < 250)
            
            or (r_current_col >= 300 and r_current_col < 325)
            
            or (r_current_col >= 375 and r_current_col < 400)
            
            or (r_current_col >= 450 and r_current_col < 475)
            or (r_current_col >= 525 and r_current_col < 550)
            or (r_current_col >= 600 and r_current_col < 625)
          ) then
          if (r_current_row > 200) then
            w_current_pixel <= c_red;
          else
            w_current_pixel <= c_green;
          end if;
        elsif (
               (r_current_col >= 25 and r_current_col < 50)
               
               or (r_current_col >= 100 and r_current_col < 125)
               
               or (r_current_col >= 175 and r_current_col < 200)
               
               or (r_current_col >= 250 and r_current_col < 275)
               
               or (r_current_col >= 325 and r_current_col < 350)
               
               or (r_current_col >= 400 and r_current_col < 425)
               or (r_current_col >= 475 and r_current_col < 500)
               or (r_current_col >= 550 and r_current_col < 575)
               or (r_current_col >= 625 and r_current_col < 650)
             ) then
          if (r_current_row > 200) then
            w_current_pixel <= c_blue;
          else
            w_current_pixel <= c_red;
          end if;
        elsif (
               (r_current_col >= 50 and r_current_col < 75)
               
               or (r_current_col >= 125 and r_current_col < 150)
               
               or (r_current_col >= 200 and r_current_col < 225)
               
               or (r_current_col >= 275 and r_current_col < 300)
               
               or (r_current_col >= 350 and r_current_col < 375)
               
               or (r_current_col >= 425 and r_current_col < 475)
               or (r_current_col >= 500 and r_current_col < 550)
               or (r_current_col >= 575 and r_current_col < 625)
               or (r_current_col >= 650)
             ) then
          if (r_current_row > 200) then
            w_current_pixel <= c_green;
          else
            w_current_pixel <= c_blue;
          end if;
        else
          w_current_pixel <= c_blue;
        end if;

      when 1 =>

        w_current_pixel <= std_logic_vector(to_unsigned(r_current_pixel_count, w_current_pixel'length));

      when others =>

        w_current_pixel <= std_logic_vector(to_unsigned(r_current_pixel_count, w_current_pixel'length));

    end case;

  end process;

  o_pixeldata <= w_current_pixel;
  o_valid     <= '1' when r_current_pixel_count < 307200 else
                 '0';
  o_new_frame <= '1' when r_current_pixel_count = 307200 else
                 '0';

end architecture arch;
