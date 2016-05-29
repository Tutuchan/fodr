#' Main dataset class
#'
#' This is the entry point to retrieve records from a dataset. Initialize a \code{FODRDataset}
#' with a \code{portal} and an \code{id}.
#'
#' @docType class
#' @param portal a character, must be one of the available portals
#' @param id a character, the dataset identifier
#' @field portal a character, must be one of the available portals
#' @field data a data.frame returned by the \code{\link[=dataset_get]{get}} method
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
                             get_records = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL) {
                               if (is.null(nrows)) nrows <- self$info$metas$records_count
                               url <- get_portal_url(self$portal, "records") %>%
                                 paste0("search?dataset=", self$id) %>%
                                 add_parameters_to_url(nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon)
                               
                               res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE)$records
                               
                               out <- if (length(res) > 0) {
                                 fields <- (res %>%
                                              purrr::transpose())$fields %>%
                                   purrr::transpose()
                                 
                                 if ("geom" %in% names(fields)) fields$geom <- tidy_geom(fields$geom)
                                 if ("geom_x_y" %in% names(fields)) fields$geom_x_y <- tidy_geom_xy(fields$geom_x_y)
                                 
                                 c(fields[!names(fields) %in% c("geom", "geom_x_y")] %>% lapply(unlist), fields[names(fields) %in% c("geom", "geom_x_y")]) %>%
                                   dplyr::tbl_df()
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
                               cat(paste("Number of files:", nrow(self$info$attachments), "\n"))
                               cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
                               if (!is.null(self$facets)) cat(paste("Facets:", paste(self$facets, collapse = ", "), "\n"))
                               if (!is.null(self$sortables)) cat(paste("Sortables:", paste(self$sortables, collapse = ", "), "\n"))
                               cat("--------------------------------------------------------------------\n")
                             }
                           ))
