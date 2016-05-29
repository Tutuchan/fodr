#' Fetch datasets
#'
#' This method is used to retrieve datasets from a portal.
#'
#' \code{refine} and \code{exclude}, if set, must be named lists where the names are the
#' facets to use and the values of the list, the values to pick or exclude.
#'
#' \code{sort} takes a character in the \code{sortables} element of the portal object and sorts
#' the results according to its value. Add a \code{-} in front in order to sort in descending
#' order (e.g. \code{sort = "-commune"}).
#'
#' \code{q} is used to perform a full text-search in all elements of the dataset. To search for all
#' datasets containing the word "Paris", use \code{q = "Paris"}. See
#' \href{https://docs.opendatasoft.com/en/api/query_language_and_geo_filtering.html#query-language}{here} for more information.
#'
#' \code{lang} can be set to use language-specific functions on the elements passed to the \code{q}
#' parameter but is not implemented yet.
#'
#' \code{theme} can be set to filter only datasets with a specific theme.
#'
#' @param nrows an integer, indicates the number of records to fetch (defaults to NULL, i.e. all matching records are fetched)
#' @param refine a named list
#' @param exclude a named list
#' @param sort a character
#' @param q a character, used to do full-text search
#' @param lang a character, the language used in the \code{q} parameter
#' @param theme a character, one of the themes of the portal
#' @name portal_search
#' @examples \donttest{portal$search(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL,
#' q = NULL, lang = NULL, theme = NULL)}
NULL
