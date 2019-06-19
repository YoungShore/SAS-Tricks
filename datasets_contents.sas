
/* ====== check datasets names in a library ====== */

%let yourLibname = ; *<---this defines your library name needed to check ;

proc sql noprint;

* ------ general use: list all datasets names into a macro variable: ------ ;

select memname into : dstList separated by " "
	from dictionary.tables
	  where libname=upcase("&yourLibname.") ;


* ------ list datasets names in a particular pattern: ------ ;

%let subDstPatern = ; *<---this defines the keyword for particualr datasets names ---;

select memname into : dstList separated by " "
	from dictionary.tables
	  where libname=upcase("&yourLibname.") and memname like upcase("&subDstPatern.");


* ------ list empty/non-empty datasets: ------ ;

select memname into : dstList separated by " "
	from dictionary.tables
	  where libname=upcase("&yourLibname.") and nobs=0 ; *<---this is listing empty datasets, if need non-empty, use nobs^=0;
    
quit;

* ------ full auto pull all datasets names and variable names from a library with PROC CONTENTS: ------ ;




/* ====== check datasets names & var names ====== */

%let dstNam = ; *<---this defines the dataset name(s) you are interested in ;

proc sql noprint;
create table dsts_vars_List(compress=binary) as
  select memname, name
    from dictionary.columns /*<-- note here it's columns, and above is tables*/
      where libname=upcase("&yourLibname") and memname like upcase("&dstNam%");
quit; 

* ------ if want to list variable names in a SAS data from proc contents: ------ ;

proc contents data=&yourLibname..&dstNam out=contes_&dstNam. ; run;