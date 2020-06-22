/* $Id$ */
/* $URL$ */

%let dataset=qcew;


%let &dataset.out=../../clean/&dataset.;


libname &dataset.fmt "&&&dataset.out.";

options nocenter;
options fmtsearch=(&dataset.fmt);

%let basedata=../../clean;



*%let interwrk=/temporary/&dataset./interwrk;
%let archive=../../raw/&dataset.;
%let interwrk=&archive.;
/*
x mkdir -p &interwrk.;
*/

/* ftp://ftp.bls.gov/pub/special.requests/cew (Q)CEW */
libname &dataset. "&basedata./&dataset./yearly"; 
libname inputs ("&basedata./inputs","&basedata./&dataset.");
libname interwrk "&interwrk.";
libname outputs "&basedata./&dataset./extra";

options sasautos=(!SASAUTOS,"../common/macros","macros/" );


/*  BLS boundary years and quarters */

%let bls_start_year=1990;
%let bls_end_year=2020;
%let bls_end_quarter=1;

