#' Fetch dataset records
#'
#' This method is used to retrieve records for a specific dataset.
#'
#' \code{refine} and \code{exclude}, if set, must be named lists where the names are the
#' facets to use and the values of the list, the values to pick or exclude. For example,
#' if a dataset has the \code{type_dossier} facet and you want to keep only the \code{DP}
#' types, you should set \code{refine = list(type_dossier = "DP")}.
#'
#' \code{sort} takes a character in the \code{sortables} element of the dataset and sorts
#' the results according to its value. Add a \code{-} in front in order to sort in descending
#' order (e.g. \code{sort = "-commune"}).
#'
#' \code{q} is used to perform a full text-search in all elements of the dataset. To search for all
#' records containing the word "Paris", use \code{q = "Paris"}. See
#' \href{https://docs.opendatasoft.com/en/api/query_language_and_geo_filtering.html#query-language}{here} for more information.
#'
#' \code{lang} can be set to use language-specific functions on the elements passed to the \code{q}
#' parameter but is not implemented yet.
#'
#' \code{geofilter.distance} can be used to retrieve only the records that are within the
#' specified distance from the specified point, if applicable.
#'
#' \code{geofilter.polygon} can be used to retrieve only the records that are within the
#' specified polygon, if applicable.
#'
#' @param nrows an integer, indicates the number of records to fetch (defaults to 10)
#' @param refine a named list
#' @param exclude a named list
#' @param sort a character
#' @param q a character, used to do full-text search
#' @param lang a character, the language used in the \code{q} parameter
#' @param geofilter.distance a numeric vector of three elements in the \code{(latitude, longitude, distance (in meters))}
#' format (e.g. \code{c(48.57, 2.24, 500)})
#' @param geofilter.polygon a data.frame with two columns named \code{lat} and \code{lon}
#' @param debug a logical, if TRUE, prints the url sent to the portal
#' @name get_records
#' @examples \donttest{dts$get_records(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL,
#' lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL)}
NULL
