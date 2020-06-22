/*BEGINCCC
$Id$
$URL$

This program reads in  
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
/*  PROVIDES-DATA:  bls_us_county_&yr.sas7bdat                            */
/*========================================================================*/


option ls=80;
options macrogen symbolgen mprint mlogic;


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
Only process the most recent year).
CCCEND*/

%let year=&bls_end_year.;


/*BEGINCCC
The files are zip files, they are first downloaded from the bls ftp site to the ARCHIVE location, 
and then unzipped through the filename below. Because of the archival format, all states are in the same
file, and are extracted prior to creating the read-in loop by state.
These files give NAICS based data.

The files within each zip file have the special .END (not ENB!) extension 
CCCEND*/

%let yr=%substr(&year,3,2);
%let zipfile=&year..all.enb.zip;


  %do j=1 %to %sysfunc(countw(&statelist.));
  %let st=%scan(%quote(&statelist),&j);
  %let fips=%sysfunc(stfips(&st),z2.);

	%do quarter=1 %to &bls_end_quarter;


  
%let enbfile=cn&fips.&st.%substr(&year,3,2)&quarter..end;
filename cewzip pipe "unzip -pC &archive./&zipfile. county/&enbfile.";
  


data &st.&yr.&quarter.recent (drop=emp_month2);
   
    length state $2 county $3 year 4 quarter 3 datatype $1
	    emp_month1 emp_month3 8 total_wage 8 
           aggregation_level $2 ownership_code $1
           status_disclosure $ 1;

  /* see http://www.bls.gov/cew/doc/layouts/end_layout.csv */
  infile cewzip lrecl=111;

input 
        state                $ 4-5 
        county		     $ 6-8
	datatype             $ 9-9
	size                 $ 10-10
        ownership_code       $ 11-11 
        industry_code        $ 12-17 
        year                   18-21 
        quarter                22-22
        aggregation_level    $ 23-24 
        status_disclosure    $ 25-25
        n                      26-33
        emp_month1             34-42
        emp_month2             43-51
        emp_month3             52-60
        total_wage             61-75
	tx_total_wage          76-90
	;

/*BEGINCCC
Label the variables- even those not retained in the data set- for purposes
of documentation.
CCCEND*/

 label  state              = "State FIPS Code                    ";
 label  county             = "County FIPS Code                   ";
 label  size               = "Size Code                          ";
 label  ownership_code     = "Ownership Code                     ";
 label  industry_code      = "Industry Code                      ";
 label  quarter            = "Quarter                            ";
 label  year               = "Year                               ";
 label  aggregation_level  = "Aggregation Level                  ";
 label  total_wage	   = "Total Quarterly Wages              ";
 label  tx_total_wage      = "Taxable Total Quarterly Wages   ";
 label  emp_month1         = "Employment, Month 1                ";
 label  emp_month3         = "Employment, Month 3                ";
 label  total_wage         = "Total Quarterly Wages              ";
 label  tx_total_wage      = "Taxable Total Quarterly Wages      ";
 label  n               = "Quarterly Number of Establishments";
  
 label  status_disclosure  = "Status/Disclosure Code"; 

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

* if state="&fips" ; * and ownership_code in ("0","5","1");
 
run;
%end; /*quarter*/

/*stack quarterly files*/
data &st.&yr.recent;
    set
      %do qtr = 1 %to &bls_end_quarter.;
          &st.&yr.&qtr.recent
      %end;;
run;

%end; /* end j loop */

data QCEW.bls_us_county_&year.;
    set
     %do j=1 %to %sysfunc(countw(&statelist)); %let st=%scan(%quote(&statelist),&j);
      &st.&yr.recent () %end;;

    %bls_industry_recode;
run;

/*BEGINCCC
Sort the data.
CCCEND*/

proc sort data=QCEW.bls_us_county_&year.;
    by year state county aggregation_level all_naics quarter;
run;

proc freq data=QCEW.bls_us_county_&year.;
    table quarter;
run;

proc contents data=QCEW.bls_us_county_&year.;
run;

proc datasets library=work;
    delete %do j=1 %to &statecnt; %let st=%scan(%quote(&statelist),&j);
      &st.&yr.recent %end;;
run;

x rm -rf &workpath./enb;

%mend state_year;

%state_year ;

