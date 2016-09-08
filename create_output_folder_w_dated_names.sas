/* Create a folder with dates every day or every time as needed */

%LET numdate= %SYSFUNC(TODAY(),YYMMDDN8.);*<---the yymmddn8. will give like 20150120, the 'n' before 8 is the option of 'no separators', can use p10 there to show like 2015.01.20;
%PUT numdate is &numdate.;
%PUT &workplace.output_&numdate.;
%LET outputput = &workplace.\output\output_&numdate;
%PUT &workoutput;
%LET outputfolder=&workoutput;
%PUT &outputfolder.;

%MACRO mkdir (dir=);
%IF %SYSFUNC(FILEEXIST(&workoutput))^=1 %THEN %DO;
X "MD &DIR";
X "EXIT";
%END;
%ELSE %PUT &workoutput. already exist;
%MEND mkdir;
%mkdir(dir=&workoutput);
ODS LISTING;

/* if you want to set a particular date as the name of the folder */
%macro mkdir(dir=);
* CREATE WORK DIRECTORY FOR OUTPUT IF IT DOES NOT EXIST;
%if %sysfunc(fileexist(&OUTFOLDER)) ^= 1 %then %do;
options dlcreatedir;
libname out "&outfolder.";
%end;
%else %put &OUTFOLDER. already exits;
%mend mkdir;
%mkdir(dir=&OUTFOLDER);
/* in above which the {options dlcreatedir; libname out "&outfolder.";} is the trick, it creates the folder */
