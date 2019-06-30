
/* Define All RX Coding System Related Libraries: */

%inc "W:\onenote\references\Drug NDCs\SAS Codes\Routine Pack\0-ALL Meds Header & Pull - v20180614.sas" ;

%let verDate = %sysfunc(date(),yymmdd6.) ; %put &verDate ;

/* RxNorm API Instruction Page: https://rxnav.nlm.nih.gov/RxNormAPIREST.html#label:functions */

%let baseURL = https://rxnav.nlm.nih.gov/REST ;


/* vvvvvvvvvvvvvvvvvv pull all types of RXCUIs vvvvvvvvvvvvvvvv */
/* only need to run as needed, like every 3 months ;

filename rxcuis 'RXCUIs.json';

proc http
	url="&baseURL./allconcepts.json?tty=IN+MIN+PIN+BN+SBD+BPCK+SBDC+SBDG+SBDF+SCD+GPCK+SCDC+SCDG+SCDF" out=rxcuis; 
								*^---remember to add '.json' after 'allconcepts' and before the question mark to adpat this prepare method;
run;

libname import JSON fileref=rxcuis ; *<---need to redefine the import library each time changing searching contents;

proc datasets lib=import; quit; *<---testing whether get proper outcomes, should see 'MINCONCEPTGROUP_MINCONCEPT' dataset, otherwise sth wrong;

data RXN.all_rxcuis_ttys_&verDate.(keep=rxcui name tty compress=binary alter='aDmSY19' label="Updated on &verDate. Alter=_AD_MSY19") ;
set import.MINCONCEPTGROUP_MINCONCEPT;run;
proc sort data=rxn.all_rxcuis_ttys_&verDate.(alter='aDmSY19') nodupkey;
by rxcui name tty ;
run;

proc freq data=rxcui_all_ttys;table tty/missing;run;

*/

/* ==================================================================== */
/*				use above data for specific medicine search	 			*/

/* vvvvvvvvvv List Needed GNNs Here vvvvvvvvvv */

%let GNNList = 
TOCILIZUMAB | 
ETANERCEPT |
;


%macro rxcui_search(KEYWORD,verDate); /* ----- search for sepecific GNNs & BNs ------ */

%let KEY = %substr(&KEYWORD,1,3)%substr(&KEYWORD,%length(&KEYWORD)-2,3) ;

data &GNN._&KEY(compress=binary) ;
set rxn.all_rxcuis_ttys_&verDate. ;
if find(name,"&KEYWORD",'i');
run;

%mend;

%macro rxcuis_pul_by_GNNList(drugClass,verDate) ;

%let i=0 ;
%do %while(%scan(&gnnList.,%eval(&i + 1),|) ne ) ;
	%let i = %eval(&i + 1) ;
	%let gnn = %scan(&gnnList., &i.,|) ; %put &gnn;

	%rxcui_search(&gnn,&verDate.);


/* ------------ pull Ingredient ID for BrandName search ---------- */
filename data 'Export_gn.json';

proc http 
	url="&baseURL./rxcui.json?name=&GNN&srclist=RXNORM&allsrc=1&search=2" out=data;
						  *^---remember to add '.json' after 'allconcepts' and before the question mark to adpat this prepare method;
run;

libname import JSON fileref=data ; *<---need to redefine the import library each time changing searching contents;

proc datasets lib=import; quit; *<---testing whether get proper outcomes, should see 'CONCEPTGROUP_CONCEPTPROPERTIES' dataset, otherwise sth wrong;

proc sql noprint;
select distinct rxnormID1 into: ingre_ID separated by '|' from import.IDGROUP_RXNORMID ;
quit;
%put &ingre_id ;

libname import clear;

/* --------------- brandName search -------------- */

*%let in_rxcui = 612865 ;
filename data 'Export_bn.json';
proc http
	url="&baseURL./brands.json?ingredientids=&ingre_ID." out=data; 
run;

libname import JSON fileref=data ; *<---need to redefine the import library each time changing searching contents;

proc datasets lib=import; quit; *<---testing whether get proper outcomes, should see 'MINCONCEPTGROUP_MINCONCEPT' dataset, otherwise sth wrong;

proc sql noprint;
select distinct name into: BNList separated by '|' from import.BRANDGROUP_CONCEPTPROPERTIES ;
quit;
%put &bnlist;

libname import clear;

	%let j=0 ;
	%do %while(%scan(&bnList.,%eval(&j + 1),|) ne ) ;
		%let j = %eval(&j + 1) ;
		%let bn = %scan(&bnList, &j.,|) ;

		%rxcui_search(&BN,&verDate.);

	%end;

data &drugClass._&gnn(compress=binary);
length GNN $50 ;
set &gnn._:(keep=rxcui name tty) ;
GNN = "&gnn";
Name = upcase(name);
run;
proc sort data=&drugClass._&gnn. nodupkey;
by gnn tty rxcui name ;
run;

%end;

%mend;
%rxcuis_pul_by_GNNList(all,190612); *<-- if only need some specific GNNs, then use 'ALL'/'ANY' whatever make sense to you as drugClass;
									*<-- if the GNN list belong to a specific class, like Autoimmune and you set the drugClass=Autoimu, 
										 then you will find all outcomes started with 'Autoimu', which is easier for your further combine;