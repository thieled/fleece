#' Recursively unnest a nested data frame until every column is unnested
#'
#' This function takes a nested data frame and recursively applies the "unnest_wider"
#' function from the tidyr package to unnest list columns until all columns are
#' in a tidy format. The function separates list columns from non-list columns,
#' checks if there is anything to unnest, and then applies the unnesting process
#' recursively to deeply nested list columns.
#'
#' @param df A nested data frame (data.table or data.frame) containing list columns.
#'
#' @return A data frame with all nested list columns unnested and merged with other columns.
#'   The resulting data frame will have a tidy format.
#'
#' @examples
#' # Sample nested list, with elements of unequal lengths
#' l <- list(list(id = 1,
#'                message = "abc",
#'                author = list(name = "A",
#'                              date = as.Date("2020-01-01")),
#'                flag = list()
#' ),
#' list(id = 2,
#'      message = "abcdef",
#'      author = list(name = "B",
#'                    date = as.Date("2022-01-01")),
#'      flag = list()
#' ),
#' list(id = 3,
#'      message = "abcdefg",
#'      author = list(name = "C",
#'                    date = as.Date("2023-01-01")),
#'      flag = list("spam", "deleted")
#' )
#' )
#'
#' # Use do.call("rbind") to transform into data.frame
#' df <- do.call("rbind", l) |> as.data.frame()
#'
#' # Unnest recursively:
#' unnested_df <- unnest_recursively(df)
#'
#' @export
unnest_recursively <- function(df) {
  # Separate list columns from non-list columns
  df_l <-  df |> dplyr::select_if(is.list)
  df_nl <- df |> dplyr::select_if(~!is.list(.x))

  # Check if there is something to unnest
  if (ncol(df_l) == 0){
    return(df)
  } else {

    # Check which list columns are deeper nested
    max_lengths <- function(x) max(lengths(x))
    v <- sapply(df_l, max_lengths)
    cols <- v[v > 1] |> names()

    if (length(cols) == 0) { # "list" columns, but not deeper nested
      df_unnested <- df_l |>
        dplyr::select(-tidyselect::all_of(cols)) |>
        tidyr::unnest(cols = tidyselect::everything(), keep_empty = TRUE, names_repair = "minimal", names_sep = "_")
      # Bind with regular columns if any
      if (ncol(df_nl > 0)){
        df_unnested <- dplyr::bind_cols(df_nl, df_unnested)
      }
      return(df_unnested)

    } else {
      df_unnested <- df_l |>
        dplyr::select(-tidyselect::all_of(cols)) |>
        tidyr::unnest(cols = tidyselect::everything(), keep_empty = TRUE, names_repair = "minimal", names_sep = "_")
      # Bind with regular columns if any
      if (ncol(df_nl > 0)){
        df_unnested <- dplyr::bind_cols(df_nl, df_unnested)
      }
      df_remaining <- df |> dplyr::select(tidyselect::all_of(cols))
      df_remaining_unnested <- df_remaining |>
        tidyr::unnest_wider(tidyselect::all_of(cols), strict = FALSE, names_repair = "minimal", names_sep = "_")

      # Recur on the remaining nested columns
      df_unnested <- dplyr::bind_cols(df_unnested, unnest_recursively(df_remaining_unnested))
      return(df_unnested)
    }
  }
}
