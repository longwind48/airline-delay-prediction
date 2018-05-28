multivariateAnalysis <- function(data, cat) {
  # 7.0 Correlations between categorical variables ==============================================================
  if (cat ==TRUE) {
    subset <- c(1:3,14,16,32,33)
    GKmatrix <- GKtauDataframe(data[,subset])
    plot(GKmatrix)
  }
  # Check for relationships between all categorical variables

  # -> The Goodman-Kruskal tau measure: knowledge of marital.status is predictive of relationship, and similar otherwise.
  # -> Reference: https://cran.r-project.org/web/packages/GoodmanKruskal/vignettes/GoodmanKruskal.html
  
  # 7.5 Correlations between numerical variables ============================================================
  else {
  # -> To show this, we combining correlogram with the significance test, 
  # -> Reference: http://www.sthda.com/english/wiki/visualize-correlation-matrix-using-correlogram
  # Build a function to compute a matrix of p-values
    cor.mtest <- function(mat, ...) {
      mat <- as.matrix(mat)
      n <- ncol(mat)
      p.mat<- matrix(NA, n, n)
      diag(p.mat) <- 0
      for (i in 1:(n - 1)) {
        for (j in (i + 1):n) {
          tmp <- cor.test(mat[, i], mat[, j], ...)
          p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
        }
      }
      colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
      p.mat
    }
    
    numericalVariables <- c("DISTANCE",
                           "CRS_DEP_TIME_MINS",
                           "CRS_ARR_TIME_MINS",
                           "ARR_DELAY",
                           "ORIGIN_AIRPORT_LAT",
                           "ORIGIN_AIRPORT_LONG",
                           "DEST_AIRPORT_LAT",
                           "DEST_AIRPORT_LONG"
                           #"ORIGIN_AIRPORT_SIZE"
                           #"DEST_AIRPORT_SIZE"
                           )
    cor <- cor(data[numericalVariables])
    p.mat <- cor.mtest(data[numericalVariables])
    
    # Build a correlogram
    par(mai = c(0.5,0.5,0.5,0.5)) # set plot margins
    col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
    corrplot(cor, method="color", col=col(200),  
             type="upper", order="hclust", 
             addCoef.col = "black", # Add coefficient of correlation
             tl.col="black", tl.srt=45, #Text label color and rotation
             # Combine with significance
             p.mat = p.mat, sig.level = 0.01, 
             # hide correlation coefficient on the principal diagonal
             diag=FALSE)
    # -> correlations with p-value > 0.05 are considered as insignificant, and crosses are added for those.
    # -> Don't seem to have any correlation among numerical variables, which is a good thing.
  }
}
