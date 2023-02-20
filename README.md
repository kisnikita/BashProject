1\. Task IOS (2022)
====================

Task description
===========

The aim of the task is to create a shell script for the analysis of records of persons with proven covid-19 coronavirus infection in the Czech Republic. The script will filter the records and provide basic statistics according to the user's input.
Script Interface Specification


**Name**

*   `corona.sh` - analyzer of records of persons with proven covid-19 coronavirus infection

**How to use**

*   `./corona.sh [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]`

**OPTIONS**

*   `COMMAND` can be one of:
    *   `infected` — counts the number of infected.
    *   `merge` — merges several files with records into one, preserving the original order (the header will be in the output only once).
    *   `gender` — lists the number of infected for each gender.
    *   `age` — lists statistics on the number of people infected by age (more details below).
    *   `daily` — lists statistics of infected people for each day.
    *   `monthly` — lists statistics of infected people for each month.
    *   `yearly` — lists statistics of infected persons for each year.
    *   `countries` —  lists statistics of infected persons for each country of infection (excluding the Czech Republic, i.e. code ' CZ`).
    *   `districts` — lists infected statistics for each district.
    *   `regions` — lists the statistics of infected persons for each region.
*   `FILTERS` can be a combination of the following (each a maximum of once):
    * `-a DATETIME` —  after: only records after this date (including this date) are considered. 'DATETIME `is of the format 'YYYY-MM-DD'.
    * `-b DATETIME` — before: only records before this date (including this date) are considered.
    * `-g GENDER` — only records of infected persons of a given sex are considered. 'GENDER' can be ' M ' (men) or `Z` (women).
    * `-s [WIDTH]` - for the commands `gender`, `age`, `daily`, `monthly`, `yearly`, `countries`, `districts` and `regions`, it prints data not numerically, but graphically in the form of histograms. The optional `WIDTH` parameter sets the width of the histograms, i.e. the length of the longest line, to `WIDTH`. Thus, `WIDTH` must be a positive integer. If the `WIDTH` parameter is not specified, the line widths follow the requirements below.
    * `-h` - prints a help with a brief description of each command and switch.

Description
=====

1. The script filters the records of people with proven covid-19 coronavirus infection. If the script is also given a command, it executes the command over the filtered records. If no command is specified, the `merge ' command is used by default.
2. If the script receives neither a filter nor a command, it describes the records to the standard output.
3. The script can also handle records compressed using the `gzip` and `bzip2 ' tools (if the file name ends with `.gz ' respectively. `. bz2`).
4. If the command line script does not receive log files (`LOG`, `LOG2`, ...), it expects records on the standard input.
5. The graphs are plotted using ASCII and are rotated to the right. The row value is represented by the sequence of the grid character `#`.

Detailed requirements
==================

1. The script analyzes the records from the specified files in a given order.

2. The record file format is CSV, where the comma character`, `is the separator. The entire file is in ASCII encoding. The format is line-by-line, each _empty_ line (empty lines are those that contain only white characters) corresponds to a record of a single infection of a person in the form (the following is the header of the CSV file)

    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs

where

  * `id` is the record identifier (a string that does not contain white characters and the comma character `,`),
  * `date` is in the format ' YYYY-MM-DD`,
  * `age` is a positive integer,
  * `gender` is ' M '(male) or ' Z ' (female),
  * `country_nuts_code` is [country code] (https://www.czso.cz/csu/rso/kraje_nuts3 where the infection was detected,
  * `okres_lau_kod` is [okres_code](https://www.czso.cz/csu/rso/okresy_nuts4 where the infection was detected,
  * `contagion_in_foreign` indicates whether the source of infection was abroad (`1` indicates that the source of infection was abroad, empty field indicates that it was not),
  * `nakaza_zeme_csu_code` is [country code] (https://www.czso.cz/csu/czso/ciselnik_zemi_-czem -) the onset of the disease (for the disease originated abroad),
  * `reported_khs` indicates whether the infection has been reported to the regional sanitary station.

    Example file with three records:

          id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
          6f4125cb-fb41-4fb0-a478-07b69ba106a4,2020-03-01,21,Z,CZ010,CZ0100,1,IT,1
          f6b08ff5-203d-4a3e-aab0-a5d39ac9ab9e,2020-03-11,32,M,CZ080,CZ0804,,,1
          b03dcf40-04cd-4f7b-a13d-767fc43c3013,2020-03-14,38,M,,,,,

      * First entry from 1. March 2020 marks the infection of a 21-year-old woman in the region "Hlavní město Praha “(code `CZ010`), in the district `Hlavní město Praha`(code 'CZ0100'). The woman was infected in Italy (code 'IT') and the infection was reported to the regional sanitary station.
      * The second entry indicates a national infection of a 32-year-old male in the Moravian-Silesian region (code `CZ080`), in the Nový Jičín district (code `CZ0804`), detected on 11 November 2014. March 2020.
      * The third entry indicates an infection of a 38-year-old man detected on the 14th. March 2020, for which no further information is available.
3.  The script does not modify any file. The script does not use temporary files.

4.  Entries in the input files do not have to be listed chronologically, and if there are multiple files in the input, their order also does not have to be chronological.

5.  If the 'WIDTH' is not specified when using the `-s` Switch, then each occurrence of the ` # ' symbol in the graph corresponds to the number of infections (rounded down) according to the command as follows:

    *   `gender` — 100 000
    *   `age` — 10 000
    *   `daily` — 500
    *   `monthly` — 10 000
    *   `yearly` — 100 000
    *   `countries` — 100
    *   `districts` — 1 000
    *   `regions` — 10 000
6.  When using the `-s` Switch with the specified width `WIDTH`, the number of infections per grid is adjusted according to the largest number of occurrences in the graph row. The row with the largest value will have the number of 'WIDTH' grids and the other rows will have a proportional number of grids with respect to the largest value. When dividing, round down. E. g. at '- s 6 ' and the line with the largest value of 1234, the line with this value will look like this: `######`.

7.  The order of arguments is sufficient to consider such that first all the switches, then (optionally) the command, and finally the list of input files (so `getopts`can be used).

8.  Assume that the input files cannot have names corresponding to a command or switch.

9.   If the `-h` Switch is entered, the help is always printed and the script ends (i.e. if the Switch is followed by a command or file, it will not be executed).

10.  If the attribute value does not exist for the `gender`, `age`, `daily`, `monthly`, `yearly`, `districts`, `regions` commands, aggregate the records with the nonexistent value under the value `None`, which you specify last in the statements.

11.  Assume that if a value for a record attribute is specified in the record, then it is correct (i.e. no need to validate input) with the following exceptions:

*   in the 'date' column, a correct date is expected in the `YYYY-MM-DD ' format, which corresponds to the actual date (i.e., e.g., `yesterday ' or '2020-02-30' are invalid values).
*   a non-negative integer is expected in the column 'vek'(i.e., e.g., '-42`,` 18.5' or '1e10' are invalid values).

If a record is detected that violates any of the conditions listed above, write an error to the error output and continue processing further (missing date/Age value is not a violation). The format for the error is as follows:

    Invalid date: 6f4125cb-fb41-4fb0-a478-07b69ba106a4,2020-04-31,21,Z,CZ010,CZ0100,1,IT,1
    Invalid age: 033fb060-2a10-42ce-80c1-72c2e39b1981,2020-03-05,dvacet,Z,CZ042,CZ0421,,,1

Check the validity of records **before** filtering .

12.  For the `age` Command, work with the following intervals and alignment:

     0-5   :
     6-15  :
     16-25 :
     26-35 :
     36-45 :
     46-55 :
     56-65 :
     66-75 :
     76-85 :
     86-95 :
     96-105:
     >105  :

13.  The implementation of the `-d` and `-r` switches is optional; a correct implementation can make up for other point losses.

14.  For the commands 'gender`,' daily`,` monthly`,` yearly`,` countries`,` districts`,` regions `(without the`- d `and`- r `switches), it is sufficient to print the output in the format` value: number `(without a space before the colon and with just one space after the colon), or (for the`- s `Switch) ' value: ###...#`. For the `age` command, the alignment is specified above.

For the optional switches `-r` and `-d`, the colon at the position is one more than the number of symbols of the longest value, i.e. instance.

    value      : 42
    delsi_value: 1337

15.  The command 'countries `does not list the number of infections in the Czech Republic (code` CZ' or missing value).

16.  Ignore the values in the columns `contagion_in_garden` and `reported_khs` (i.e. for example, the command 'countries` does not need to take `nakaza_in_border' into account).

17.  Records do not necessarily have the appropriate number of columns. In the case of a missing column, proceed as if it were missing a value (if the record is missing `N` fields, it means that the value `N` of the rightmost columns is missing, IE, eg. if the record contains only 7 fields, then the values of the columns `nakaza_zeme_csu_kod` and `reported_khs`are missing).

18.  Do not check that the contents of the columns `kraj_nuts_kod`, `okres_lau_kod` and `nakaza_zeme_csu_kod` correspond to the given codes. In the case of implementing the `-d` and `-r ' extensions when using a value undefined in the district/county definition file, print the given records to the error output in the following format:

     Invalid value: 07958a56-6867-4245-b042-29c291c20359,2020-08-16,5,M,CZ099,CZ0999,,,1


Implementation details
=====================

1. The script should have `POSIXLY_CORRECT=yes ' set throughout the run.

2. The script should run on all common shells ('dash`, 'ksh', 'bash'). If you use a shell-specific property, specify this using the interpreter directive on the first line of the file, e.g. `#!/ bin / bash 'or'#!/usr/bin / env bash ' for ' bash`. You can use the GNU extension for `sed` or `awk`. Languages Perl, Python, Ruby, etc. not allowed.

**Notice:** some servers, e.g. `merlin.fit.vutbr.cz', have symlink ` / bin / sh -> bash`. Make sure that you are actually testing the script with the shell. I recommend to verify the correct functionality using the Virtual Machine below.

3. The script must run on commonly available GNU/Linux, BSD and MacOS OS. A virtual machine with an image is available for students to download here: [http://www.fit.vutbr.cz/~lengal/public/trusty.ova](http://www.fit.vutbr.cz/~lengal/public/trusty.ova) (for VirtualBox, login: 'trusty` / password: `trusty`), on which you can verify the correct functionality of the project.

4. The script must not use temporary files. However, temporary files indirectly created by other commands (e.g. the command 'sed-i').



Project submission
==================

Submit only the 'corona' script (do not pack it into any archive). Submit to IS, term project 1.

Councils
====

*   A good decomposition of the problem into subproblems can greatly facilitate your work and prevent mistakes.
*    Learn to use **functions** in the shell (remember that a lot of functionality, eg. for listings of Statistics, histogram, etc. is similar).

Return value
=================

*   The script returns success if the operation is successful. An internal script error or erroneous arguments will be accompanied by an error message on stderr and an unsuccessful return code.

Examples of use
================

* Samples of infected records are available on the official website of the Ministry of Health: [https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/osoby.csv](https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/osoby.csv (note that it is about 250 MiB). On [this page] (https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19) other data sets are available, including descriptions of their schemas.
* Sample records showing examples of use below are available on [this page] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/tree/main/). these are specifically the following:
* A copy of the file ' persons.csv'z 21. February 2022 [here] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby.csv) (approximately 250 MiB).
* Shortened version version ' persons-short.csv` [here] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby-short.csv) (about 150 KiB).
* A subset of records for January 2022 broken down by day is available [here] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/tree/main/data/infected-jan22).
* Compressed versions of files ' persons.csv ' a ' persons-short.csv` ([`osoby.csv.gz`](https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby.csv.gz), ['persons.csv.bz2'] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby.csv.bz2), [`osoby-short.csv.gz`](https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby-short.csv.gz a) [`osoby-short.csv.bz2`](https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby-short.csv.bz2)).
* File ' persons2.csv's examples of heavier records that need to be processed correctly are [here] (https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby2.csv).



Examples:

    $ cat osoby.csv | head -n 5 | ./corona
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
    6f4125cb-fb41-4fb0-a478-07b69ba106a4,2020-03-01,21,Z,CZ010,CZ0100,1,IT,1
    5841443b-7df4-4af9-acab-75ca47010ec3,2020-03-01,43,M,CZ042,CZ0421,1,IT,1
    5cdb7ece-97a2-4336-9715-59dc70a48a2c,2020-03-01,67,M,CZ010,CZ0100,1,IT,1
    d345e0e2-9056-4d3f-b790-485b12831180,2020-03-03,21,Z,CZ010,CZ0100,,,

    $ ./corona infected osoby.csv
    3510360

    $ ./corona infected infected-jan22/infected-22-01-*.csv
    560894

    $ ./corona merge infected-jan22/infected-22-01-*.csv
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
    741d72a4-2b6e-4703-872d-928748ca0ade,2022-01-01,3,Z,CZ020,CZ0203,,,1
    f39754b8-5e7f-44fd-8b65-e4e7e3b89521,2022-01-01,52,Z,CZ052,CZ0522,,,1
    ...
    1a27f58f-8950-40c5-89fa-3795f4a906f4,2022-01-31,19,Z,CZ063,CZ0635,,,1
    9aebc069-89d5-4ba0-96c5-aefa1f2c6746,2022-01-31,19,M,CZ064,CZ0642,,,1

    $ cat osoby.csv | ./corona gender
    M: 1703679
    Z: 1806681

    $ curl -s 'https://pajda.fit.vutbr.cz/ios/ios-22-1-inputs/-/raw/main/data/osoby.csv' | ./corona -a 2021-07-19 infected
    1835517

    $ cat osoby.csv | ./corona daily
    2020-03-01: 3
    2020-03-03: 2
    2020-03-04: 1
    ...
    2022-02-19: 8218
    2022-02-20: 4267

    $ cat osoby.csv | ./corona monthly
    2020-03: 3316
    2020-04: 4385
    2020-05: 1615
    ...
    2022-01: 560894
    2022-02: 465810

    $ cat osoby.csv | ./corona yearly
    2020: 732808
    2021: 1750848
    2022: 1026704

    $ ./corona countries osoby.csv
    99: 1
    AD: 1
    AE: 444
    AF: 13
    ...
    ZA: 36
    ZM: 2
    ZW: 1

(kód země `99` na prvním řádku je chyba v datové sadě; neřešte ji)

    $ ./corona -g M osoby.csv | head -n 6
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
    5841443b-7df4-4af9-acab-75ca47010ec3,2020-03-01,43,M,CZ042,CZ0421,1,IT,1
    5cdb7ece-97a2-4336-9715-59dc70a48a2c,2020-03-01,67,M,CZ010,CZ0100,1,IT,1
    496a049f-656e-4274-a51f-72aa92d01f33,2020-03-05,49,M,CZ042,CZ0421,1,IT,1
    815a2219-2735-46ae-8b14-658459481b2f,2020-03-06,47,M,CZ010,CZ0100,1,IT,1
    9f78dd0d-2e71-4d37-89a2-665b44b2a607,2020-03-06,44,M,CZ010,CZ0100,1,IT,1

    $ cat /dev/null | ./corona
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs

    $ ./corona -s daily osoby.csv
    2020-03-01:
    2020-03-03:
    2020-03-04:
    ...
    2022-02-19: ################
    2022-02-20: ########

    $ ./corona -s monthly osoby.csv
    2020-03:
    2020-04:
    2020-05:
    ...
    2022-01: ########################################################
    2022-02: ##############################################

    $ ./corona -s 20 yearly osoby.csv
    2020: ########
    2021: ####################
    2022: ###########

    $ ./corona osoby.csv.gz | head -n 5
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
    6f4125cb-fb41-4fb0-a478-07b69ba106a4,2020-03-01,21,Z,CZ010,CZ0100,1,IT,1
    5841443b-7df4-4af9-acab-75ca47010ec3,2020-03-01,43,M,CZ042,CZ0421,1,IT,1
    5cdb7ece-97a2-4336-9715-59dc70a48a2c,2020-03-01,67,M,CZ010,CZ0100,1,IT,1
    d345e0e2-9056-4d3f-b790-485b12831180,2020-03-03,21,Z,CZ010,CZ0100,,,

    $ ./corona osoby.csv.bz2 | head -n 5
    id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs
    6f4125cb-fb41-4fb0-a478-07b69ba106a4,2020-03-01,21,Z,CZ010,CZ0100,1,IT,1
    5841443b-7df4-4af9-acab-75ca47010ec3,2020-03-01,43,M,CZ042,CZ0421,1,IT,1
    5cdb7ece-97a2-4336-9715-59dc70a48a2c,2020-03-01,67,M,CZ010,CZ0100,1,IT,1
    d345e0e2-9056-4d3f-b790-485b12831180,2020-03-03,21,Z,CZ010,CZ0100,,,

    $ ./corona districts osoby.csv
    CZ0100: 448252
    CZ0201: 34423
    CZ0202: 33545
    CZ0203: 54368
    CZ0204: 36166
    ...
    CZ0806: 103556
    None: 2959

    $ ./corona regions osoby.csv
    CZ010: 448252
    CZ020: 482138
    ...
    CZ080: 387509
    None: 2926

    $ ./corona age osoby.csv
    0-5   : 118107
    6-15  : 511868
    16-25 : 410980
    26-35 : 511672
    36-45 : 649751
    46-55 : 570064
    56-65 : 359275
    66-75 : 225485
    76-85 : 110360
    86-95 : 39405
    96-105: 2651
    >105  : 302
    None  : 440

    $ ./corona infected osoby2.csv
    9
    Invalid date: 0dc57759-d153-45c2-8d14-fb92fc028060,2020-15-03,62,Z,CZ010,CZ0100,,,1
    Invalid age: 5b0a9692-a72a-4f34-a014-83ae08a79f20,2020-03-10,3.1415,Z,CZ071,CZ0712,1,IT,1

    $ ./corona daily osoby2.csv
    2020-03-01: 3
    2020-03-03: 2
    2020-03-04: 1
    2020-03-05: 3
    Invalid date: 0dc57759-d153-45c2-8d14-fb92fc028060,2020-15-03,62,Z,CZ010,CZ0100,,,1
    Invalid age: 5b0a9692-a72a-4f34-a014-83ae08a79f20,2020-03-10,3.1415,Z,CZ071,CZ0712,1,IT,1

Extension
---------

    $ ./corona -d okresy.csv districts osoby.csv
    Benesov         : 34423
    Beroun          : 33545
    Blansko         : 34374
    Brno-mesto      : 123692
    ...
    Zdar nad Sazavou: 37928
    Zlin            : 69348
    Znojmo          : 32733
    None            : 2959

    $ ./corona -r kraje.csv regions osoby.csv
    Hlavni mesto Praha  : 448252
    Jihocesky kraj      : 206288
    Jihomoravsky kraj   : 374972
    Karlovarsky kraj    : 77709
    Kraj Vysocina       : 158169
    Kralovehradecky kraj: 190181
    Liberecky kraj      : 148988
    Moravskoslezsky kraj: 387509
    Olomoucky kraj      : 208593
    Pardubicky kraj     : 183208
    Plzensky kraj       : 193696
    Stredocesky kraj    : 482138
    Ustecky kraj        : 248821
    Zlinsky kraj        : 198910
    None                : 2926