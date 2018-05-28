appendAirportData <- function(data, columnName, factor) {
  # Additional features to add
  originAirportIDs <- data$ORIGIN_AIRPORT_ID
  destAirportIDs <- data$DEST_AIRPORT_ID
  if(factor == TRUE) {
    newOriginColumn <- as.factor(lookupAirportData(originAirportIDs, columnName))
    newDestColumn <- as.factor(lookupAirportData(destAirportIDs, columnName))
  } else {
    newOriginColumn <- as.numeric(lookupAirportData(originAirportIDs, columnName))
    newDestColumn <- as.numeric(lookupAirportData(destAirportIDs, columnName))
  }
  output.data <- cbind(data,
                       newOriginColumn,
                       newDestColumn)
  old.col.names <- names(data)
  new.col.names <- c(old.col.names,
                     paste("ORIGIN_", columnName, sep = ""),
                     paste("DEST_", columnName, sep = ""))
  output.data <- setNames(output.data, new.col.names)

  return(output.data)
}