timestamp=$(date +%s)

# pull the data from EPA
curl https://s3-us-west-1.amazonaws.com//files.airnowtech.org/airnow/today/reportingarea.dat > reportingarea.dat

# add header rows
echo "Issue date|Valid date|Valid time|Time zone|Record sequence|Data type|Primary|Reporting area|State code|Latitude|Longitude|Parameter name|AQI value|AQI category|Action day|Discussion|Forecast|Source" | cat - reportingarea.dat > working.dat

# archive the datafile
cp reportingarea.dat backups/reportingarea-${timestamp}.dat

# clear out weird lone quote mark that breaks things and makes NYC disappear
find='|"|'
replace='||'
sed "s/${find}/${replace}/g" working.dat > temp.dat
rm working.dat
mv temp.dat working.dat

# turn it into a CSV
in2csv -I -d "|" -f csv working.dat > aqi.csv

# trim out extra columns and filter to only primary data rows
csvcut -C "Issue date","Latitude","Longitude","Action day","Discussion" aqi.csv | csvgrep -c "Primary" -m "Y" > temp.csv
rm aqi.csv
mv temp.csv aqi.csv

# dump it into a squlite database and filter only the cities we're interested in
csvsql --db sqlite:///aqi.db --insert --overwrite aqi.csv
csvsql --query "select * from aqi where (\"Reporting area\" = \"Metropolitan Washington\") OR (\"Reporting area\" = \"New York City Region\") OR (\"Reporting area\" = \"Philadelphia\") OR (\"Reporting area\" = \"Boston\") OR (\"Reporting area\" = \"Chicago\") OR (\"Reporting area\" = \"Pittsburgh\") OR (\"Reporting area\" = \"Metro Baltimore\") OR (\"Reporting area\" = \"Detroit\");" aqi.csv > filtered.csv
csvjson filtered.csv > filtered.json

# copy the data over to a dngext graphic
cp filtered.json ../graphics-js/aqi-cities-20230608/