#' Main dataset class
#'
#' This is the entry point to retrieve records from a dataset. Initialize a \code{FODRDataset}
#' with a \code{provider} and an \code{id}.
#'
#' @docType class
#' @param provider a character, must be one of the available providers
#' @param id a character, the dataset identifier
#' @field provider a character, must be one of the available providers
#' @field data a data.frame returned by the \code{\link[=dataset_get]{get}} method
#' @field fields a character vector
#' @field facets a character vector or variables that can be used to f
#' @return An object of class \code{\link{FODRDataset}} with methods designed to retrieve data from an open dataset.
#' #' @section Methods:
#' \describe{
#'   \item{\code{\link[=dataset_get]{get}}}{This method retrieves records from the dataset.}}
#' @export
FODRDataset <- R6::R6Class("FODRDataset",
                           public = list(
                             provider = NULL,
                             data = NULL,
                             facets = NULL,
                             fields = NULL,
                             id = NULL,
                             info = NULL,
                             sortables = NULL,
                             url = NULL,
                             initialize = function(provider, id){
                               raw_data <- get_dataset(provider, id)

                               self$provider <- provider
                               self$id <- id

                               self$url <- raw_data$url
                               dataset <- raw_data$data


                               self$info$features <- unlist(dataset$features)
                               dataset$metas$keywords <- unlist(dataset$metas$keyword)
                               dataset$metas$keyword <- NULL
                               self$info$meta <- dataset$metas
                               self$info$attachments <- dataset$attachments
                               self$info$alternative_exports <- dataset$alternative_exports
                               self$info$billing_plans <- dataset$billing_plans
                               self$fields <- dataset$fields
                               self$facets <- get_facets(self$fields)
                               self$sortables <- get_sortables(self$fields)
                             },
                             get = function(nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL) {
                               url <- get_provider_url(provider, "records") %>%
                                 paste0("search?dataset=", id) %>%
                                 add_parameters_to_url(nrows, refine, exclude, sort, q, lang, geofilter.distance, geofilter.polygon)

                               res <- jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE) %$%
                                 records

                               out <- if (length(res) > 0) {
                                 fields <- res %>%
                                   purrr::transpose() %$%
                                   fields %>%
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
                               cat(paste("Provider:", self$info$meta$publisher, "\n"))
                               cat("--------------------------------------------------------------------\n")
                               cat(paste("Number of records:", self$info$meta$records_count, "\n"))
                               cat(paste("Number of files:", length(self$info$attachments), "\n"))
                               cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
                               if (!is.null(self$facets)) cat(paste("Facets:", paste(self$facets, collapse = ", "), "\n"))
                               if (!is.null(self$sortables)) cat(paste("Sortables:", paste(self$sortables, collapse = ", "), "\n"))
                               cat("--------------------------------------------------------------------\n")
                             }
                           ))
