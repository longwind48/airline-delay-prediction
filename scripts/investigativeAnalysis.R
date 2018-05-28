# Investigative Code To Understand Data Better
d <- appendAirportData(data_2017, "AIRPORT_COUNTRY_NAME", factor = TRUE)
structure(d$ORIGIN_AIRPORT_COUNTRY_NAME)
# The flights are all from the following regions (which explains the coordinates outside continental United States):
#  American Samoa
#  Guam
#  Puerto Rico
#  United States
#  Virgin Islands