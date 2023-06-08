timestamp=$(date +%s)
curl https://s3-us-west-1.amazonaws.com//files.airnowtech.org/airnow/today/reportingarea.dat > reportingarea.dat
cp reportingarea.dat backups/reportingarea-${timestamp}.dat
echo "Issue date|Valid date|Valid time|Time zone|Record sequence|Data type|Primary|Reporting area|State code|Latitude|Longitude|Parameter name|AQI value|AQI category|Action day|Discussion|Forecast|Source" | cat - reportingarea.dat > working.dat
in2csv -d "|" -f csv working.dat > aqi.csv
csvcut -C "Valid date","Valid time","Latitude","Longitude","Action day","Discussion" aqi.csv | csvgrep -c "Primary" -m "True" > temp.csv
mv temp.csv aqi.csv
csvsql --db sqlite:///aqi.db --insert --overwrite aqi.csv
csvsql --query "select * from aqi where (\"Reporting area\" = \"Metropolitan Washington\") OR (\"Reporting area\" = \"New York City Region\") OR (\"Reporting area\" = \"Philadelphia\") OR (\"Reporting area\" = \"Boston\") OR (\"Reporting area\" = \"Chicago\") OR (\"Reporting area\" = \"Pittsburgh\") OR (\"Reporting area\" = \"Metro Baltimore\");" aqi.csv > filtered.csv
csvjson filtered.csv > filtered.json