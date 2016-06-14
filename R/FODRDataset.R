#' Main dataset class
#'
#' This is the entry point to retrieve records from a dataset. Initialize a \code{FODRDataset}
#' with a \code{portal} and an \code{id}.
#'
#' @docType class
#' @field portal a character, must be one of the available portals
#' @field data a data.frame returned by the \code{\link[=get_records]{get_records}} method
#' @field fields a character vector
#' @field facets a character vector or variables that can be used to filter results
#' @field id a character, the dataset id
#' @field info a list of five elements:
#' \itemize{
#'  \item features: a character vector of available services on this dataset, \emph{unused}
#'  \item metas: a list of meta-information about the dataset (publisher, language, theme, etc.)
#'  \item attachments: a list of downloadable files related to this dataset, if any, \emph{not downloadable from R}
#'  \item alternative_exports: \emph{unknown purpose}
#'  \item billing_plans: \emph{unknown purpose}
#' }
#' @field sortables a character vector containing a subset of \strong{fields}, indicates on which fields sorting is allowed
#' @field url a character, the actual url sent to the API
#' @return An object of class \code{\link{FODRDataset}} with methods designed to retrieve data from an open dataset.
#' @section Methods:
#' \describe{
#'   \item{\code{\link{get_attachments}}}{This method retrieves attachments from the dataset.}
#'   \item{\code{\link{get_records}}}{This method retrieves records from the dataset.}}
#' @export
FODRDataset <- R6::R6Class("FODRDataset",
                           public = list(
                             portal = NULL,
                             data = NULL,
                             facets = NULL,
                             fields = NULL,
                             id = NULL,
                             info = NULL,
                             sortables = NULL,
                             url = NULL,
                             initialize = function(portal, id){
                               raw_data <- get_dataset(portal, id)
                               
                               self$portal <- portal
                               self$id <- id
                               
                               self$url <- raw_data$url
                               dataset <- raw_data$data
                               
                               
                               self$info$features <- unlist(dataset$features)
                               dataset$metas$keywords <- unlist(dataset$metas$keyword)
                               dataset$metas$keyword <- NULL
                               self$info <- c(self$info, dataset[c("metas", "attachments", "alternative_exports", "billing_plans")])
                               self$info$attachments <- self$info$attachments %>% purrr::transpose() %>% lapply(unlist)
                               self$fields <- dataset$fields
                               self$facets <- get_facets(self$fields)
                               self$sortables <- get_sortables(self$fields)
                             },
                             get_attachments = function(fname, output = NULL){
                               id <- self$info$attachments$id[which(self$info$attachments$title == fname)]
                               url <- paste0(self$url, "attachments/", id)
                               if (is.null(output)) output <- fname
                               curl::curl_download(url = url, destfile = output)
                             },
                             get_records = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL, debug = FALSE) {
                               if (is.null(nrows)) nrows <- self$info$metas$records_count
                               url <- get_portal_url(self$portal, "records") %>%
                                 paste0("search?dataset=", self$id) %>%
                                 add_parameters_to_url(nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon, debug)
                               
                               res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE)$records
                               
                               out <- if (length(res) > 0) {
                                 # Find all fields
                                 tres <- res %>%
                                   purrr::transpose()
                                 fields <- suppressWarnings(tres$fields %>%
                                   purrr::transpose())
                                 
                                 # Check if geo_shape field for GIS processing
                                 geo_shape <- if ("geo_shape" %in% names(fields)) fields$geo_shape else NULL
                                 
                                 # Remove fields that have too many elements
                                 lfields <- lapply(fields, function(x) length(unlist(x)))
                                 fields <- fields[lfields <= nrows]
                                 
                                 records <- fields %>% 
                                   lapply(function(x) {
                                     x[sapply(x, is.null)] <- NA
                                     unlist(x)}) %>%
                                   dplyr::tbl_df()
                                 
                                 # Handle GIS information
                                 geometry <- tres$geometry
                                 if (!is.null(geometry)) {
                                   geometry  <- geometry %>% 
                                     purrr::transpose()
                                   geometry$type <- unlist(geometry$type)
                                   dfLonlat <- lapply(geometry$coordinates, function(x) dplyr::data_frame(lng = x[[1]], lat = x[[2]])) %>% 
                                     dplyr::bind_rows()
                                   records <- dplyr::bind_cols(records, dfLonlat)
                                 }
                                 
                                 if (!is.null(geo_shape)) {
                                   geo_shape  <- geo_shape %>% 
                                     purrr::transpose()
                                   geo_shape$type <- unlist(geo_shape$type)
                                   
                                   # Can have LineString or MultiLineString, Polygon or MultiPolygon
                                   dfGeoShape <- dplyr::data_frame(geo_shape = lapply(seq_along(geo_shape$type), function(i) {
                                     switch(geo_shape$type[i],
                                            LineString = tidy_line_string(geo_shape$coordinates[[i]]),
                                            MultiLineString = lapply(geo_shape$coordinates[[i]], tidy_line_string),
                                            Polygon = tidy_polygon(geo_shape$coordinates[[i]]),
                                            MultiPolygon = lapply(geo_shape$coordinates[[i]], tidy_polygon))
                                   }))
                                   records <- dplyr::bind_cols(records, dfGeoShape)
                                 }
                                 records
                               } else dplyr::data_frame()
                               
                               self$data <- out
                               self$data
                             },
                             
                             print = function() {
                               cat("FODRDataset object\n")
                               cat("--------------------------------------------------------------------\n")
                               cat(paste("Dataset id:", self$id, "\n"))
                               cat(paste("Theme:", self$info$meta$theme, "\n"))
                               cat(paste("Keywords:", paste(self$info$meta$keywords, collapse = ", "), "\n"))
                               cat(paste("Publisher:", self$info$meta$publisher, "\n"))
                               cat("--------------------------------------------------------------------\n")
                               cat(paste("Number of records:", self$info$meta$records_count, "\n"))
                               if (is.null(nfiles <- nrow(self$info$attachments))) nfiles <- 0
                               cat(paste("Number of files:", nfiles, "\n"))
                               cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
                               if (!is.null(self$facets)) cat(paste("Facets:", paste(self$facets, collapse = ", "), "\n"))
                               if (!is.null(self$sortables)) cat(paste("Sortables:", paste(self$sortables, collapse = ", "), "\n"))
                               cat("--------------------------------------------------------------------\n")
                             }
                           ))
