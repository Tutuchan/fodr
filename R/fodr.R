#' the fodr package
#' 
#' Fetch data from various French Open Data portals. Use 
#' \code{\link{fodr_dataset}} and \code{\link{fodr_portal}} to retrieve records.
#' 
#' @importFrom magrittr %>% %$% 
#' @importFrom R6 R6Class
#' @importFrom curl curl_download
#' 
#' @name fodr
globalVariables(c("lat", "lon", "polygon"))
