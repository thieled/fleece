#' Bind JSON data parsed as an R list to a data frame and unnest nested columns
#'
#' This function takes JSON data parsed as an R list, binds it to a data frame, and
#' then recursively applies the "unnest_recursively" function to unnest any nested
#' list columns in the data frame. The input data can contain either a single observation
#' (a list representing a row) or multiple observations (a list of lists representing
#' multiple rows).
#'
#' @param content A list containing JSON data parsed into R format.
#'
#' @return A data frame with JSON data bound and all nested list columns unnested
#'   to achieve a tidy format.
#'
#' @examples
#' # Sample JSON data parsed as an R list
#'
#' @export
rectangularize <- function(content){

  # Stop if content is not a list
  if (!is.list(content)){
    stop("Error: Please provide content in list format.")
  }

    # Check if content contains 1 observation (=> simple rbind; 1 row df)
    if(all(sapply(content, is.list))){

      con <- do.call(rbind, content) |> tibble::as_tibble()
      con <- unnest_recursively(con)
      return(con)

    }else{ # ...or more (=> do.call(rbind, l); multiple rows df)

      con <- rbind(content) |> tibble::as_tibble()
      con <- unnest_recursively(con)
      return(con)
    }

}
