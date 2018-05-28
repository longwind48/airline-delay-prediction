displayDelayProbabilities <- function(probabilities, title) {
  barWidths <- c(1,1,1,1,1,4,1)
  barplot(probabilities,
          horiz = FALSE,
          las = 1,
          main = title,
          xlab = "Categories for Minutes of Delay by Categories",
          ylab = "Probabilities",
          names.arg = c("<0",
                        "0-15",
                        "15-30",
                        "30-45",
                        "45-60",
                        "60-120",
                        ">120"),
          col = c('green','red','red','red','red','red','red'),
          width = barWidths,
          cex.names = 1.0)
}

test.probabilities <- c(0.5, 0.17, 0.13, 0.1, 0.05, 0.02, 0.03)
displayDelayProbabilities(test.probabilities, "Test Plot for displayDelayProbabilities Function")

