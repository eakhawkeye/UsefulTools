UsefulTools - DNS Test Nameservers
===================
A useful tool for testing response times of nameservers. 


Usage
-------------
Simply run the command to test your current (/etc/resolv.conf) nameservers against google.com for 20 iterations. For more details or to change any part of the test use the arguments listed in the help output (included below).

```
  Usage: dnstestns.sh [-n|-f] [-t] [-i]
	[--name    |-n]	"Nameserver"
	[--file    |-f]	"Nameservers File (line separated)"
	[--site    |-s]	"Site name to resolve"
	[--iter    |-i]	"Number of tests per nameserver"
	[--verbose |-v]	"Show verbose information"

	Default Values: (if missing any parameter)
	  File:	   /etc/resolv.conf
	  Target:  www.google.com
	  Iter:	   20
```

Example
-------------
Basic Test
```
-$ dnstestns.sh
192.168.200.99:      average     3     min     1     max    41 ms 20 responses
8.8.8.8:             average    36     min    12     max    48 ms 20 responses
8.8.4.4:             average    34     min    14     max    41 ms 20 responses

```

Verbose Test
```
-$ dnstestns.sh -v
192.168.200.99:             42    1    1    1    1    1    1    1    1    1
                             1    1    1    1    1    1    1    1    1    1

8.8.8.8:                    40   39   39   42   27   25   44   40   40   15
                            16   47   40   50   16   14   40   39   41   22

8.8.4.4:                    41   39   39   39   40   14   39   56   52   14
                            40   40   40   39   17   61   40   41   41   16


192.168.200.99       average     3     min     1     max    42 ms 20 responses
8.8.8.8:             average    33     min    14     max    50 ms 20 responses
8.8.4.4:             average    37     min    14     max    61 ms 20 responses
```

Credits
------------
Original Script: https://serverfault.com/questions/91063/how-do-i-benchmark-performance-of-external-dns-lookups
