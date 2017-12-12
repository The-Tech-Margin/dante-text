From steve@avalon.dartmouth.edu Mon Jun 20 13:52:39 1994
Received: by baker.dartmouth.edu (5.65/DEC-Ultrix/4.3)
	id AA02933; Mon, 20 Jun 1994 13:52:38 -0400
Received: from localhost by avalon.dartmouth.edu (5.65/DEC-Ultrix/4.3)
	id AA21852; Mon, 20 Jun 1994 13:52:35 -0400
Message-Id: <9406201752.AA21852@avalon.dartmouth.edu>
To: BOBH@baker.dartmouth.edu
Subject: Re: glitch? 
In-Reply-To: Your message of "Mon, 20 Jun 94 12:25:02 EDT."
             <9406201625.AA27602@baker.dartmouth.edu> 
Reply-To: Stephen.Campbell@Dartmouth.EDU
Date: Mon, 20 Jun 94 13:52:29 -0400
From: Stephen Campbell <steve@avalon.dartmouth.edu>
X-Mts: smtp
Status: R

Bob,

These are all determined by the capabilities (or lack thereof) of the BRS database
manager that underlies DDP.  They are all related to the way BRS builds its indices
or to the searching features BRS offers.  At present I do not expect them to change.

								Steve


> Noticed today that if one tries to do an expand on a word not
> in dictionary that includes a wildcard, one gets a null result.
> 
> Is this intentional? merely necessary? a glitch that can be
> fixed?  If either of the first two, we need to add this to the
> manual.
> 
> E.g., for you to try:
> 
> 	compatibilitmn
> 
> as opposed to:
> 
> 	compat?bilitmn
> 
> Anotehr issue someone brought up last night: do we have any
> plans of building greater BRS flexibility into our searches?
> E.g., being able to search for later parts of words?
> 
> E.g., for an ending:
> 
> 	$mente
> 
> This is, as you know, currently impossible.
> 
> Or what about a part of a word?
> 
> E.g., for a recurring syllable mid-word:
> 
> 	$non$
> 
> All for now.  Bob

