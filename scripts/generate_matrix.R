# Alignment Algorithm - Generate Matrix
# Date: July 2016
# Author: Jenny Nguyen
# Email: jnnguyen2@wisc.edu

#' Converts values less than -1000 to -INF
convert <- function(x) ifelse(x < -1000, "-INF", x)

#' Generate the 3 DP matrices (M, Ix, Iy)
#'
#' Parameters:
#' - str_c, str_r: (vector) the two strings to compare
#' - match, mismatch, gap, space: (int) scores for match, mismatch, gap, space
#'
#' Returns: a list containing the 3 matrices (M, Ix, Iy)
#'
make_matrices <- function(str_c, str_r, match, mismatch, space, gap, use_local){
  
  # choose the right algorithm
  if(gap == 0){
    out <- make_matrices_linear(str_c, str_r, match, mismatch, space, use_local)
  } else{
    out <- make_matrices_affine(str_c, str_r, match, mismatch, space, gap, use_local)
  }
  
  return(out)
}

#'
make_matrices_linear <- function(str_c, str_r, match, mismatch, space, use_local){

  # pre-compute the dimensions for the 3 matrices
  ncol <- length(str_c)
  nrow <- length(str_r)

  # initialize the matrices with 0
  matrices <- matrix(0, ncol = ncol, nrow = nrow)

  # loop over the rows and columns and computes the score for each position
  for(i in 1:nrow){
    for(j in 1:ncol){

      # compute s, the match/mismatch score
      s <- compute_s(str_r, str_c, i, j, match, mismatch)

      # different initialization and fill for global vs local alignment
      if(!use_local){

        if(i == 1 & j != 1) matrices[i, j] <- matrices[i, j - 1] + space
        if(j == 1 & i != 1) matrices[i, j] <- matrices[i - 1, j] + space
        if(i == 1 & j == 1) matrices[i, j] <- 0
        if(i != 1 & j != 1) matrices[i, j] <- max( compute_cell(matrices, i, j, s, space, use_local) %>% unlist )

      } else{

        matrices[i, j] <- max( compute_cell(matrices, i, j, s, space, use_local) %>% unlist )
      }
    }
  }

  # return the matrices
  return( list(matrices = matrices, formatted_matrices = matrices) )

}

#'
make_matrices_affine <- function(str_c, str_r, match, mismatch, space, gap, use_local){
  
  # pre-compute the dimensions for the 3 matrices
  ncol <- length(str_c)
  nrow <- length(str_r)
  
  # initialize matrices with infinitely small number
  mat <- matrix(-10000, ncol = ncol, nrow = nrow)
  matrices <- list(m = mat, ix = mat, iy = mat)
  formatted <- matrix("", ncol = ncol, nrow = nrow)
  
  # loop over the rows and columns and computes the score for each position
  for(i in 1:nrow){
    for(j in 1:ncol){
      
      # compute s, the match/mismatch score
      s <- compute_s(str_r, str_c, i, j, match, mismatch)
      
      # compute values for each matrix cell (same for global vs local)
      if(i != 1 & j != 1){
        
        # compute value for m
        matrices[["m"]][i, j] = max( compute_m(matrices, i, j, s, space, gap, use_local) %>% unlist )
        
        # compute value for ix
        matrices[["ix"]][i, j] = max( compute_ix(matrices, i, j, s, space, gap) %>% unlist )
        
        # compute value for iy
        matrices[["iy"]][i, j] = max( compute_iy(matrices, i, j, s, space, gap) %>% unlist )
        
        # different initialization and fill for global vs local alignment
      } else{
        
        if(!use_local){
          
          if(i == 1) matrices[["iy"]][i, j] <- gap + space * (j - 1)
          if(j == 1) matrices[["ix"]][i, j] <- gap + space * (i - 1)
          if(i == 1 & j == 1) matrices[["m"]][i, j] <- 0
          
        } else{
          
          matrices[["m"]][i, j] <- 0
          
        }
      }
      
      # formatted matrix outputs all 3 matrix values
      formatted[i, j] <- with(matrices, paste("m:", convert(m[i, j]), "\nix:", convert(ix[i, j]), "\niy:", convert(iy[i, j])))
      
    }
  }
  
  # return the matrices
  return( list(matrices = matrices, formatted_matrices = formatted) )
  
}
