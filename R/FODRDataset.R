#' main dataset class
#'
#' @description This is the entry point to retrieve records from a dataset. 
#' Initialize a \code{FODRDataset} with a \code{portal} and an \code{id} using the \code{\link{fodr_dataset}} wrapper.
#'
#' @docType class
#' 
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
#' 
#' @field sortables a character vector containing a subset of \strong{fields}, indicates on which fields sorting is allowed
#' @field url a character, the actual url sent to the API
#' @return An object of class \code{\link{FODRDataset}} with methods designed to retrieve data from an open dataset.
#' 
#' @section Methods:
#' \describe{
#'   \item{\code{\link{get_attachments}}}{This method retrieves attachments from the dataset.}
#'   \item{\code{\link{get_records}}}{This method retrieves records from the dataset.}
#' }
#' 
#' @usage NULL
#'   
#' @export
FODRDataset <- R6::R6Class(
  "FODRDataset",
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
      self$info <- c(
        self$info, 
        dataset[c(
          "metas", 
          "attachments", 
          "alternative_exports", 
          "billing_plans"
        )]
      )
      self$info$attachments <- self$info$attachments %>% 
        purrr::transpose() %>% 
        lapply(unlist)
      self$fields <- dataset$fields
      self$facets <- get_facets(self$fields)
      self$sortables <- get_sortables(self$fields)
    },
    get_attachments = function(fname, output = NULL){
      attachments <- self$info$attachments
      id <- attachments$id[which(attachments$title == fname)]
      url <- paste0(self$url, "attachments/", id)
      if (is.null(output)) output <- fname
      curl::curl_download(url = url, destfile = output)
    },
    get_records = function(
      nrows = NULL, 
      refine = NULL, 
      exclude = NULL, 
      sort = NULL, 
      q = NULL, 
      lang = NULL, 
      geofilter.distance = NULL, 
      geofilter.polygon = NULL, 
      quiet = TRUE,
      debug = FALSE,
      ...
      ) {
      if (is.null(nrows)) nrows <- self$info$metas$records_count
      
      if (nrows > MAX_API_RECORDS) {
        if (!quiet) cat(
          "Too many rows for direct call to API, downloading file ...\n"
          )
        url <- get_portal_url(self$portal, "records") %>%
          paste0("download?dataset=", self$id) %>%
          add_parameters_to_url(
            refine = refine, 
            exclude = exclude,
            q = q, 
            lang = lang, 
            geofilter.distance = geofilter.distance,
            geofilter.polygon = geofilter.polygon, 
            format = "json",
            debug = debug
          )
        response <- if (!quiet) httr::GET(url, httr::progress()) else 
          httr::GET(url)
        if (!quiet) cat("\nFile downloaded, now parsing ...")
        res <- httr::content(response)
      } else {
        url <- get_portal_url(self$portal, "records") %>%
          paste0("search?dataset=", self$id) %>%
          add_parameters_to_url(
            nrows = nrows, 
            refine = refine, 
            exclude = exclude, 
            sort = sort, 
            q = q, 
            lang = lang, 
            geofilter.distance = geofilter.distance, 
            geofilter.polygon = geofilter.polygon,
            debug = debug,
            ...
          )
        res <- from_json(url)$records
        }
      
      
      out <- if (length(res) > 0) {
        nrows <- length(res)
        # Find all fields
        tres <- res %>%
          purrr::transpose()
        fields <- suppressWarnings(
          tres$fields %>%
            purrr::transpose()
        )
        
        # Check if geo_shape field for GIS processing
        geo_shape <- if ("geo_shape" %in% names(fields)) fields$geo_shape else 
          NULL
        
        # Remove fields that have too many elements
        lfields <- lapply(fields, function(x) length(unlist(x)))
        fields <- fields[lfields <= nrows]
        
        records <- fields %>% 
          lapply(function(x) {
            x[vapply(x, is.null, logical(1))] <- NA
            unlist(x)}) %>%
          tibble::tibble()
        
        # Handle GIS information
        geometry <- tres$geometry
        if (!is.null(geometry)) {
          geometry  <- geometry %>% 
            purrr::transpose()
          geometry$type <- unlist(geometry$type)
          dfLonlat <- lapply(geometry$coordinates, function(x) {
            tibble::tibble(lng = x[[1]], lat = x[[2]])
          }) %>% 
            dplyr::bind_rows()
          records <- dplyr::bind_cols(records, dfLonlat)
        }
        
        if (!is.null(geo_shape)) {
          geo_shape  <- geo_shape %>% 
            purrr::transpose()
          geo_shape$type <- unlist(geo_shape$type)
          
          # Can have LineString or MultiLineString, Polygon or MultiPolygon
          dfGeoShape <- dplyr::data_frame(
            geo_shape = lapply(seq_along(geo_shape$type), function(i) {
              coords <- geo_shape$coordinates[[i]]
              switch(
                geo_shape$type[i],
                LineString = tidy_line_string(coords),
                MultiLineString = lapply(coords, tidy_line_string),
                Polygon = tidy_polygon(coords),
                MultiPolygon = lapply(coords, tidy_polygon))
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
      cat("---------------------------------------------------------------\n")
      cat(paste("Dataset id:", self$id, "\n"))
      cat(paste("Theme:", toString(self$info$meta$theme), "\n"))
      cat(paste("Keywords:", toString(self$info$meta$keywords), "\n"))
      cat(paste("Publisher:", self$info$meta$publisher, "\n"))
      cat("---------------------------------------------------------------\n")
      cat(paste("Number of records:", self$info$meta$records_count, "\n"))
      if (is.null(nfiles <- nrow(self$info$attachments))) nfiles <- 0
      cat(paste("Number of files:", nfiles, "\n"))
      cat(paste("Modified:", as.Date(self$info$meta$modified), "\n"))
      if (!is.null(self$facets)) 
        cat(paste("Facets:", toString(self$facets), "\n"))
      if (!is.null(self$sortables)) 
        cat(paste("Sortables:", toString(self$sortables), "\n"))
      cat("---------------------------------------------------------------\n")
      cat("Description:\n")
      self$info$metas$description %>% 
        gsub("<p>|<br/>", "\n", .) %>% 
        gsub("<.*?>", "", .) %>% 
        gsub("\\t", "", .) %>%
        trimws() %>% 
        cat()
      cat("\n---------------------------------------------------------------\n")
    }
  )
)

#' @title initialize a dataset
#' 
#' @description A wrapper around \code{FODRDataset$new(portal, id)} for convenience.
#' 
#' @param portal a character in \code{\link{list_portals}}
#' @param id a character
#' 
#' @examples 
#' \dontrun{
#' votes <- fodr_dataset("paris", "resultats-des-votes-budget-participatif-2016")
#' votes
#' }
#' 
#' @name fodr_dataset
#' @export
fodr_dataset <- function(portal, id){
  FODRDataset$new(portal, id)
}
