This tape contains 101 files.  This file is first, then 34 cantos of
the Inferno, 33 cantos of Purgatory, and 33 files of Paradiso.  Each
file consists of 512-byte blocks of ASCII text.  The last block of
each file is generally shorter than 512 bytes.  Within each block
are variable-length records representing lines of text.  Each line
ends with an ASCII linefeed character.  Lines may span blocks.  The
files were written on a Unix system with the command

	dd  if=datafile  of=/dev/rmt0

and could be read with the same command but with the options
reversed.  Here is the dump of the initial part of the second file
on the tape, which is Canto 1 of Inferno.  The character "\n" is a
linefeed; "\t" is a tab.

0000000    |   C   A   N   T   O       1       I   N   F   E   R   N   O
0000020    ~  \n  \n  \t   |   P   r   o   e   m   i   o   .   ~        
0000040    S   o   g   l   i   o   n   o       g   e   n   e   r   a   l
0000060    m   e   n   t   e       g   l   i       h   u   o   m   i   n
0000100    i   ,       c   h   e       a   l   l   a  \n   v   e   r   a
0000120        v   i   a       d   e   l   l   a       v   i   r   t   @
0000140    u       s   i       i   n   d   r   i   z   z   a   n   o   ,
0000160        c   i   @   o       f   a   r   e       n   o   n       n
0000200    e   '       p   r   i   m   i       a   n   n   i  \n   d   e
0000220    l   l   '   e   t   @   a       l   o   r   o   ,       n   e
0000240        n   e       g   l   i       u   l   t   i   m   i       d

etc.  Characters "|", "@", "~", and so on represent either font
changes or precede accented characters.  They may be globally
removed without serious loss of information.
