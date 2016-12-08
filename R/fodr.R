#' fodr: fetch French Open Data with R
#' 
#' Fetch data from various French Open Data portals. Use 
#' \code{\link{fodr_dataset}} and \code{\link{fodr_portal}} to retrieve records.
#' 
#' @section Constants:
#' \describe{
#'   \item{MAX_API_RECORDS = 10000}{the OpenDataSoft \code{search} API has a limit for the number of rows that can be returned}
#' }
#' 
#' @importFrom magrittr %>% %$% 
#' 
#' @name fodr
globalVariables(c("lat", "lon", "polygon"))
