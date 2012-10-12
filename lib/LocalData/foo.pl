#!/usr/bin/perl

use strict;
use warnings;
use Switch;

my $input = '';

while ($input ne '6')
{
    clear_screen();

    print "1. system commands\n".
          "2. edit commands\n". 
          "3. admin commands\n". 
          "4. network commands\n". 
          "5. games\n".
          "6. exit\n";

    print "Enter your choice: ";
    $input = <STDIN>;
    chomp($input);

    switch ($input)
    {
        case '2'
        {
            $input = '';

            while ($input ne '4')
            {
                clear_screen();

                print "1. edit > option 1\n".
                      "2. edit > option 1\n".
                      "3. edit > option 3\n".
                      "4. return to main menu\n";

                print "Enter your choice: ";
                $input = <STDIN>;
                chomp($input);
            }

            $input = '';
        }

    }
}

exit(0);

sub clear_screen
{
    system("clear");
}
