/*BEGINCCC
$Id$
$URL$

We create a concatenation of the bls_us_county_YYYY files in this 
program , with appropriate creation of the naicssec variable.

CCCEND*/


%include "config.sas"  / source2;

option ls=80;
options macrogen symbolgen mprint mlogic;


%let interwrk=%sysfunc(pathname(interwrk));


/*===== now create the county x naicssec file =====*/

%macro make_county_x_naicssec;

data OUTPUTS.bls_us_county_naicssec;
     set
%do year=&bls_start_year. %to &bls_end_year.;
       QCEW.bls_us_county_&year.(drop=sic: NAICS: where=(aggregation_level='74'))
%end;
     ;
     naicssec=all_naics;
     label naicssec = "NAICS Sector (naicssec)";
run;

proc sort data=OUTPUTS.bls_us_county_naicssec;
    by year quarter state county aggregation_level all_naics ownership_code;
run;
%mend; 
%make_county_x_naicssec;

proc contents data=OUTPUTS.bls_us_county_naicssec;
title "County x NAICSSEC file";
run;
proc sql;
select unique state from OUTPUTS.bls_us_county_naicssec;
select unique naicssec from OUTPUTS.bls_us_county_naicssec;
quit;
run;

