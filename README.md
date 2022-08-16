

# Integrate all types of data from the Neuromodulation Research Center

## Documentation

Read here: https://datastorageanalysisarchitecture.readthedocs.io/en/latest/


## Notes

1. All tdt names use upper case, e.g. GRMT, UMCX

2. In tdt system, using the first character to discriminate different device

- U represents utah array, e.g. UMCX, UPMC, and UDLP represent utah array in MC, PMC and DLP areas invidually

- GRMT represents gray matter

- D represent DBS lead, e.g. DBSS and DBSG reprent DBS leads in STN and GP individually

3. How to store eye tracking data, two alternatives

- Send a link to the original txt file (done)

- Store as the time series data and the particular time stamp for eye movement detected (done)

4. In tdt system, no need to store snip field

5. DLC data

- Store the link to the recorded videos (done)

- Store the dlc processed x, y trajectory data (Done)

6. MA data

- Store the link to the recorded raw MA data

- Store the cleaned MA data as time series data 

