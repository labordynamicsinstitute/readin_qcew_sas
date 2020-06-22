/*BEGINCCC
$Id$
$URL$

The most recent (post-2001) ES-202 data from the Bureau of Labor Statistics'
Covered Employment and Wages (CEW) program is read in from zipped files.
These files are obtained from 

ftp://ftp.bls.gov/pub/special.requests/cew

Documentation and layouts exist on this site and will provide you with
the information necessary to fully understand the data.  Thoroughly 
reviewing the documentation and in particular the various aggregation 
levels is advised.  

This program reads in the yearly files. The next program reads in 
the last year's quarterly files.

This program, instead of downloading the individual files from the BLS website,
refers to an archive location where the ENB ZIP files (whole-year-archive) have been 
downloaded. This is due to a change to the BLS FTP server. ENB archives need to be downloaded
separately, prior to running this program.

CCCEND*/


%include "config.sas"  / source2;

/*========================================================================*/
/*  Original Date: <02/11/04 14:00:50 bjell001>                           */
/*  Time-stamp: <03/06/19 15:18:16 bjell001>                              */
/*  Author:  Melissa Bjelland                                             */
/*  Title:  01_bls.sas                                                    */
/*  Location:  .../QA_sequence/qa_files/es202/County                      */
/*                                                                        */
/*  DESCRIPTION:                                                          */
/*  Reads in and stacks the most recent annual county data from           */
/*  zipped files obtained from the BLS (CEW).                             */
/*                                                                        */
/*  REQUIRES-SAS:  format_naics2.sas                                      */
/*  REQUIRES-SAS:  format_st2fips.sas                                     */
/*  REQUIRES-SAS:  format_sic2.sas                                        */
/*                                                                        */
/*                                                                        */
/*  PROVIDES-DATA:  bls_us_county_&yr.sas7bdat                            */
/*========================================================================*/


option ls=80;
options macrogen symbolgen mprint mlogic;
options fullstimer;


%let workpath=%sysfunc(pathname(work));

/***********************************************************************************************/

/*BEGINCCC
The following macro state_year reads in the BLS website the county data for years which need to be updated,   
except the most recent year whose data are read in the next program 
(so this program handles years from end_year to end_year_new-1)         
CCCEND*/

%let statelist=al ak az ar ca co ct de
               dc fl ga hi id il in ia
               ks ky la me md ma mi mn 
               ms mo mt ne nv nh nj nm  
               ny nc nd oh ok or pa ri 
               sc sd tn tx ut vt va wa 
               wv wi wy pr vi;

/*BEGINCCC
The macro state_year reads in the BLS data for all   
states, Puerto Rico, and the Virgin Islands.         
CCCEND*/

%macro state_year;

%global temp1;
%let temp1=0;
%do %until (%quote(%scan(&statelist,&temp1))=);
    %let temp1=%eval(&temp1+1);
%end;

%let statecnt=%eval(&temp1-1);

/*BEGINCCC
Create the yearlist of available additional years of data (except the most recent one).
CCCEND*/

%local stopyear;
%if ( "&bls_end_quarter." = "4" ) %then %let stopyear=&bls_end_year.;
%else %let stopyear=%eval(&bls_end_year.-1);
%if ( "&sysparm" != "" ) %then %let bls_start_year=&sysparm.;

%do yr=&bls_start_year. %to &stopyear;


/*BEGINCCC
The files are zip files, they are first downloaded from the bls ftp site to the ARCHIVE location, 
and then unzipped through the filename below. Because of the archival format, all states are in the same
file, and are extracted prior to creating the read-in loop by state.
These files give NAICS based data.
CCCEND*/

%let zipfile=&yr..all.enb.zip;
x unzip -L &archive./&zipfile. -d &workpath./enb;


  %do j=1 %to &statecnt;
  %let st=%scan(%quote(&statelist),&j);
  
  
/*BEGINCCC
Convert the state postal abbreviation into its FIPS code.
CCCEND*/

%let fips=%sysfunc(stfips(&st));*two-digit FIPs code;

%macro fipsfix;
%if &fips<10 %then %let fips=0&fips;

%mend fipsfix;

%fipsfix;;

/*BEGINCCC
The files within each zip file have the special .ENB extension 
CCCEND*/

%let enbfile=cn&fips&st%substr(&yr,3,2).enb;



data &st.&yr.recent (drop=employ_: total_wage_q: n_q: );
   
    length state $2 county $3 year 4 quarter 3 
	    emp_month1 emp_month3 8 total_wage 8 
           aggregation_level $2 ownership_code $1
           status_disclosure $ 1;

*  filename cewzip pipe "gzip -dc &interwrk/&zipfile.";
   filename enbfile  "&workpath/enb/county/&enbfile.";
  infile enbfile lrecl=449;

input 
        state                $ 4-5 
        county               $ 6-8
        ownership_code       $ 11-11 
        industry_code        $ 12-17 
        year                   18-21 
        aggregation_level    $ 22-23 
        status_disclosure    $ 24-24
        n_q1                   25-32
        employ_jan             33-41
        employ_mar             51-59
        total_wage_q1          60-74
        n_q2                   112-119
        employ_apr             120-128
        employ_jun             138-146
        total_wage_q2          147-161
        n_q3                   199-206
        employ_jul             207-215
        employ_sep             225-233 
        total_wage_q3          234-248
        n_q4                   286-293
        employ_oct             294-302
        employ_dec             312-320
        total_wage_q4          321-335;

/*BEGINCCC
Label the variables- even those not retained in the data set- for purposes
of documentation.
CCCEND*/

 label  state              = "State FIPS Code                    ";
 label  county             = "County FIPS Code                   ";
 label  ownership_code     = "Ownership Code                     ";
 label  industry_code      = "Industry Code                      ";
 label  quarter            = "Quarter                            ";
 label  year               = "Year                               ";
 label  aggregation_level  = "Aggregation Level                  ";
 label  employ_jan         = "January Employment                 ";
 label  employ_mar         = "March Employment                 ";
 label  total_wage_q1      = "Total Quarterly Wages              ";
 label  employ_apr         = "April Employment                   ";
 label  employ_jun         = "June Employment                   ";
 label  total_wage_q2      = "Total Quarterly Wages              ";
 label  employ_jul         = "July Employment                    ";
 label  employ_sep         = "Sept Employment                    ";
 label  total_wage_q3      = "Total Quarterly Wages              ";
 label  employ_oct         = "October Employment                 ";
 label  employ_dec         = "December Employment                ";
 label  total_wage_q4      = "Total Quarterly Wages              ";
 label  emp_month1         = "Employment, Month 1                ";
 label  emp_month3         = "Employment, Month 3                ";
 label  total_wage         = "Total Quarterly Wages              ";
 label  aggregation_level  = "Level of aggregation               ";
 label  status_disclosure  = "Status/Disclosure Code"; 
 label  n_q1               = "Quarterly Number of Establishments";
 label  n_q2               = "Quarterly Number of Establishments";
 label  n_q3               = "Quarterly Number of Establishments";
 label  n_q4               = "Quarterly Number of Establishments";
 label  n               = "Quarterly Number of Establishments";

/*BEGINCCC
Recode county for consistency with LEHD files, as well as  
for consistency across years of the ES-202 data. 
CCCEND*/

 if county eq "999" then county = "ZZZ"; 

/*BEGINCCC
Only retain observations for that particular state and for ownership
codes 0 and 5. Only all industry aggregates are available in the 2001 
data and beyond for our purposes.  In the future, a SIC-NAICS 
crosswalk may be implemented, but in the meantime, we only strip
off the aggregation level for all industries.
CCCEND*/

 if state="&fips" ; * and ownership_code in ("0","5","1");

/*BEGINCCC
Select out month 1 employment and total wage for each quarter.
CCCEND*/

 %do q=1 %to 4;
     quarter=&q;
     if quarter=1 then do;
         n = n_q1;
	 emp_month1=employ_jan;
	 emp_month3=employ_mar;
	 total_wage=total_wage_q1;
	 output;
     end;
     else if quarter=2 then do;
         n = n_q2;
         emp_month1=employ_apr;
         emp_month3=employ_jun;
	 total_wage=total_wage_q2;
	 output;
     end;
     else if quarter=3 then do;
         n = n_q3;
         emp_month1=employ_jul;
         emp_month3=employ_sep;
	 total_wage=total_wage_q3;
	 output;
     end;
     else if quarter=4 then do;
         n = n_q4;
         emp_month1=employ_oct;
         emp_month3=employ_dec;
	 total_wage=total_wage_q4;
	 output;
     end;
 %end;

 
run;


%end; /*state*/

data QCEW.bls_us_county_&yr.;
    set
     %do j=1 %to &statecnt; %let st=%scan(%quote(&statelist),&j);
      &st.&yr.recent () %end;;

    %bls_industry_recode;
run;

/*BEGINCCC
Sort the data.
CCCEND*/

proc sort data=QCEW.bls_us_county_&yr.;
    by year state county aggregation_level all_naics quarter;
run;

proc freq data=QCEW.bls_us_county_&yr.;
    table quarter;
run;

proc contents data=QCEW.bls_us_county_&yr.;
run;

proc datasets library=work;
    delete %do j=1 %to &statecnt; %let st=%scan(%quote(&statelist),&j);
      &st.&yr.recent %end;;
run;

x rm -rf &workpath./enb;

%end; /*year*/



%mend state_year;

%state_year ;

