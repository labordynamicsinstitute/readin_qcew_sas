# A sequence of programs to readin in QCEW data from the Bureau of Labor Statistics

These programs have been used since at least 2001 in order to read in raw [Quarterly Census of Employment and Wages (QCEW)](https://www.bls.gov/cew/) data (in ENB format) from the Bureau of Labor Statistics. They have been updated over the years, and may be functionally superseded by the more modern [BLS API](https://www.bls.gov/developers/), but they still allow to readin several decades of data in bulk.


They were originally written by Melissa Bjelland as a student at Cornell University, and were maintained over the years by Lars Vilhuber, Cornell University.

## Requirements

The programs are meant to be run on a Linux system with SAS installed, but are likely to run on any system with `bash` (untested).

## Configuring the programs

The `config.sas` has hard-coded the last year of data, allowing the user to control which data to pull. Edit it before starting.

You will need to adjust directory structure to suit your needs.

The last year is handled differently, in large part because the year might be incomplete. 

## Running programs

```
./02.01.get_enb_files.sh
sas 02.02.bls-last-year-county-files-enb.sas
sas 02.03.bls-yearly-county-files-enb-archive.sas
sas 02.04.bls_county_combine.sas
```


## License

These programs are provided as-is, with no warranty that they are right, meaningful, or useful. See [LICENSE](LICENSE).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
