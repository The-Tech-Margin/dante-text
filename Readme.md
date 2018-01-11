# Dante Text

This repository stores the source text files and database utilities for the [Dartmouth Dante Project (DDP)](https://dante.Dartmouth.EDU). (For information about the PHP files comprising the DDP website, refer to the dante-web repository.)

The DDP is a full-text searchable database of 77 commentaries on Dante's *Divine Comedy,* written in Italian, Latin, and English from Dante's time to the present. The database also contains the original text of the poem, itself. 

This repository comprises a number of directories and subdirectories:

##### Alexandria-Archive/
A set of directories and subdirectories from an earlier instance of the DDP, hosted on a now-defunct server named alexandria.Dartmouth.EDU. These files are of historic interest only; none are currently in use.
##### Commentaries/
A set of directories, each containing one of the commentaries, plus a directory named "poem" containing the text of the *Divine Comedy.* Each of these directories in turn contains subdirectories named *inf, purg,* and *para* corresponding to the three canticas of the poem: *Inferno, Purgatorio,* and *Paradiso*. (Not all commentaries contain all three canticas.) Each cantica directory in turn contains source text files named *01.e, 02.e,* and so forth corresponding to the 33 or 34 cantos in that cantica. The \*.e files are editable text files from the commentary - hence ".e." Other *nn*.\* files are temporary files generated when the text files are loaded into the database.

The commentary directories and subdirectories also contain makefiles used by the make(1) utility to load the commentary text into the database. The structure of the makefiles is described below.
##### README-Files/
A set of additional README files that document additional aspects of the DDP.
##### SQL/
A collection of SQL scripts are used to create the database, to add and delete database rows, and to query the database. Scripts with the .sql suffix are used with the Oracle SQL\*PLUS utility, while those with the .ldr suffix are used with the Oracle SQLLDR utility. 
##### Sed/
A collection of sed(1) scripts used in the past to help transform the original commentary text files into the *nn*.e files in the commentary directories. These scripts are not used in routine database management; they might be useful if a new commentary gets added to the DDP.
##### Testfiles/
A collection of text files representing different character encodings such as UTF-8 and ISO8859. These files are not used in routine database management.
##### Webapp-Archive/
A small collection of home directory files from the previous DDP server webapp.Dartmouth.EDU. They are mostly of historic interest, though some may be useful for configuring editors and login shells.
##### bin/
A collection of executables that are invoked by the commentary makefiles to load text into the database, plus a few handy scripts used to annotate work on the DDP. *This directory should by the the PATH environment variable of anyone maintaining the database.*
##### lib/
An archive of files used to load previous instances of the DDP. These files are of historic interest only.
##### src/
This directory contains source files for the lex(1) executables in the bin directory, plus a few other small C programs useful in processing DDP data files.


### Setup for local maintenance and development

1. Install the Oracle Instant Client. This gets you the Oracle sqlplus and sqlldr utilities.
    - Go to http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html
    - Accept the agreement
    - Download and install:
        - Instant Client Package - Basic
        - Instant Client Package - SQL*Plus
        - Instant Client Package - WRC: Workload Replay Client
    - Add the resulting directory to your shell's PATH variable.
1. Get a current copy of the Dartmouth *tnsnames.ora* file and install it in the network/admin subdirectory of the Instant Client directory.
1. Make sure you have the following Unix utilities in your PATH: Perl(1), lex(1) or flex(1), vi(1) or other text editor, make(1).
1. Create a working directory and clone this repository into it

    ```
    mkdir $HOME/Dante/dante-text
    cd $HOME/Dante/dante-text
    git clone git@git.dartmouth.edu:dante/dante-text.git
    ```
1. Make sure the executables in the repo's bin directory are valid on your computer. Recompile them if necessary. Then make sure the bin directory is in your PATH.

1. Add the appropriate environment variables to your login shell profile. For example:
    ```
    #
    # Environment variables needed (or just handy) for working on the Dante Project.
    #

    # The location of the Oracle tnsnames.ora file:
    TNSNAMES=$HOME/instantclient_12_2/network/admin/tnsnames.ora

    PATH=$PATH:/Developer/usr/bin:$HOME/bin:$HOME/instantclient_12_2:$HOME/Dante/dante-text/bin:.
    export PATH

    SQLPATH=$HOME/Dante/dante-text/SQL
    export SQLPATH

    # The LD_LIBRARY_PATH variable may not be needed, but this was on webapp, so...
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/instantclient_12_2
    export LD_LIBRARY_PATH

    # NLS_LANG is used by Oracle to specify the default language of the database.
    NLS_LANG=American_America.AL32UTF8
    export NLS_LANG

    # Definitions for git(1) to use for commits.
    GIT_AUTHOR_NAME="Stephen Campbell"
    export GIT_AUTHOR_NAME
    GIT_AUTHOR_EMAIL="dante.project@Dartmouth.EDU"
    export GIT_AUTHOR_EMAIL
    ```

### Commentary makefile structure

##### Strategy

The repository's *Commentaries* directory and all its commentary- and cantica-level subdirectories each contain a file named *Makefile*. The purpose of the makefiles is to allow you to use the Unix make(1) utility to load text changes into the DDP database after editing any of the ".e" files. At the commentary level, this would be the *desc.e* file, which contains the bibliographic description of the commentary; at the cantica level, it would be the *nn*.e files corresponding to the cantos of that cantica.

The makefiles at the top and commentary levels support recursive invocation of make(1) into the lower directories. Thus you can edit as many ".e" files in as many directories as needed and then invoke make(1) at the highest directory level common to all your changes. For example if you have changes to make in the Purgatory and Paradiso of the Hollander commentary, you might do the following:
    ```
    cd Commentaries/hollander/purg
    vi 05.e 20.e
    cd ../para
    vi 14.e
    cd ..
    make DBNAME=tin PW=the-password
    ```

This will recursively do a make(1) in *Commentaries/hollander* and all three canticas of Hollander, though there will be "nothing to be done" in *Commentaries/hollander* and *inf*.

##### Makefile Components

Because the structure of the commentary directories is uniform and the logic of the make process is similar throughout, we have extracted the bulk of the makefile text into a few component files at the top *Commentaries* level and designed the actual Makefile files to *include* those common components. Here's how it works. 

 - Each commentary directory contains a file named *Desc.mk*. This short file contains definitions of make(1) variables that describe that particular commentary. For example, the Hollander's *Desc.mk* file is
    ```
    #
    # hollander
    #
    comm_id		:= 20005
    comm_name	:= hollander
    comm_lang	:= us
    canticas	:= inf purg para
    ```
 - At the top *Commentaries* level are three component files named *Poem.mk, Commentary.mk,* and *Cantica.mk*. These components provide make(1) variable definitions and targets appropriate for the *poem* directory, the commentary-level directories, and the cantica directories, respectively. They contain *include* commands for the appropriate *Desc.mk* file. Finally they *include* the file *Common.mk*.
 -  The file named *Common.mk* at the top level contains the commands that actually preprocess the ".e" files into a form acceptable to Oracle and then invoke the Oracle utility programs to load the data. There is a section in *Common.mk* for each type of data: commentary description files (*desc.e*), and poem and commentary text files (*nn*.e).
 -  The file named *Userid.mk* contains commands to process the DBNAME and PW command line parameters that are needed for many of the make(1) functions. It gets *included* by other component files.
 -  At each level of the *Commentaries* directory tree is a file named *Makefile*. This is the file that make(1) expects to find. At the top level it simply recursively invokes make(1) in each subdirectory. At the lower levels it simply invokes the appropriate *\*.mk* file from the top level.
 - The makefiles also support utility targets in addition to the default "all" target. These include "dat" to generate the preprocessed data files from the .e files but without loading the results, "reindex" to regenerate the text index after you reload text, "up-to-date" to touch(1) all the *.log files so that it appears that all data is loaded (which may be the case if you just cloned this repository), and "clean" to remove all preprocessed and log files, making it appear that no data is loaded.

### Making updates to the DDP text

 1. *You will need to be on campus or using the VPN for the following steps.* Routine updates typically consist of minor editorial changes such as correcting typos in the commentary texts. The procedure is to go to the commentary subdirectory where the change is needed, edit the *nn*.e file containing the affected text, and do a make(1) command to reload the text into the Oracle database. For example, if there were a typo in the Hollander commentary's text about Inferno, canto 1, line 50, you might do the following:

    ```
    cd $HOME/Dante/dante-text/Commentaries/hollander/inf
    vim 01.e
        # Fix the typo after finding the text about line 50.
    make DBNAME=tin PW=dbpassword
    ```

 2. If you have modified text in one of the commentaries, you need to regenerate the full text index for the database. (If all you did was modify one of the commentary description files, desc.e, then you do not need to reindex.) To reindex the database, do the following:
    ```
    make DBNAME=tin PW=dbpassword reindex
    ```

 3. Test the results by browsing to the test website at [https://dante-dev.Dartmouth.EDU](https://dante-dev.Dartmouth.EDU) and searching for the modified piece of commentary text.

### Deploying text updates

1. Once satisfied with the changes, use touch(1) on the edited ".e" files and repeat the make(1) specifying DBNAME=copper with the appropriate database password.

1. Use git to push your changes up to [https://git.dartmouth.edu/](https://git.dartmouth.edu/).
    ```
    # Tell Git to pick up and track any changes made
    cd $HOME/Dante/dante-text
    git add .
    
    # Commit your changes locally
    git commit -m "Fixed typo in Hollander Inf 1"
    
    # Push your change up
    git push
    ```
