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
	[--quiet   |-q]	"Quiet the live output (for automation)"
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
_nameserver              _avg  _min  +max (ms) _#resp
192.168.200.99              1     1     1          20
8.8.8.8                    21    13    50          20
8.8.4.4                    33    14   141          20
```

Verbose Test
```
-$ dnstestns.sh -i 50 -v
192.168.200.99              20    2    1    1    1    1    1    1    1    1
                             1    2    1    1    1    4    1    1    1    1
                             1    1   10    1    1    1    1    1    1    1
                             3    1    1    1    1    1    1    1    1    1
                             1    1    1    1    0    1    1    1    1    1

8.8.8.8                     16   39   40   40   41   42   40   42   39   14
                            40   39   39   15   41   40   16   15   39   39
                            39   32   37   44   52   45   54   16   25   37
                            15   42   43   41   39   17   42   39   14   14
                            63   39   14   40   14   39   26   14   39   15

8.8.4.4                     40   53   38   15   40   39   38   41   39   14
                            15   40   14   40   22   14   23   18   14   16
                            50   90   51   29   81   63   44   33   18   40
                            16   43   40   15   14   38   39   40   41   39
                            39   14   14   15   41   14   23   48   14   14

_nameserver               _avg  _min  _max (ms) _#resp
192.168.200.99               1     1    20          50
8.8.8.8                     33    14    63          50
8.8.4.4                     32    14    90          50
```

Credits
------------
Original Script: https://serverfault.com/questions/91063/how-do-i-benchmark-performance-of-external-dns-lookups
Why use PeZa's work instead of writing something this simple use other methods? His work is awesome! I found his storage method interesting and I dig his awk output. Always good to learn something new.
