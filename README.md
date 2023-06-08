# aqi-process
 
This is a rudimentary script that pulls the latest AQI data from AirNow.gov.

This script expects that you're in a Python environment ([we use Anaconda](https://blog.apps.npr.org/2013/06/06/how-to-setup-a-developers-environment.html)) and have `csvkit` installed.

```
git clone git@github.com:nprapps/aqi-process.git
cd aqi-process
conda create --name aqi-process python=3.9
conda install -c conda-forge csvkit
```

To run it:

```
conda activate aqi-process
bash aqi.sh
```

## Data notes

The AQI datafile is a pipe-delimited `.dat` textfile, updated hourly. [Documentation lives here.](https://docs.airnowapi.org/docs/ReportingAreaFactSheet.pdf)

Note: Forecast data beyond the current day does not exist for all reporting areas.

[Additional data](http://files.airnowtech.org/?prefix=airnow/today/) and [documentation](https://docs.airnowapi.org/files) (API account may be required to access)

## What the script does

1. Download the datafile from the AQI site
2. Add column headers
3. Convert to a CSV and trim out extra columns / rows
4. Query results just for a subset of cities
5. Export the filtered set to JSON and copy it over to a dgnext graphic `aqi-cities-20230608` in the separate `graphics-js` repo
    * _(Assumption: you work at NPR and already have this repo on your machine.)_

## Further development

TODO: Perhaps borrowing from the [covid data pipeline](https://github.com/nprapps/jhu-interceptor/tree/master), upload this to a server and set it on a cron, uploading the result to a folder on apps.npr.org.