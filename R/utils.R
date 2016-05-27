# Get content portal url
get_portal_url <- function(portal, endpoint){
  stopifnot(portal %in% portals()$portals)
  paste0(get_base_url(portal), "/api/", endpoint, "/1.0/")
}

# Get datasets data
get_datasets <- function(portal, nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL, lang = NULL) {
  url <- get_portal_url(portal, "datasets") %>%
    paste0("search/") %>%
    add_parameters_to_url(nrows, refine, exclude, sort, q, lang)
  list(data = jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE), url = url)
}

# Get dataset meta data
get_dataset <- function(portal, id) {
  url <- get_portal_url(portal, "datasets") %>%
    paste0(id, "/")
  list(data = jsonlite::fromJSON(url, simplifyVector = FALSE, flatten = FALSE), url = url)
}

get_facets <- function(fields){
  lapply(fields, function(field) {
    if (!"annotations" %in% names(field)) return(NULL) else {
      annotations <- field$annotations
      res <- lapply(annotations, function(annotation) {
        annotation$name == "facet"
      }) %>%
        unlist() %>%
        any()
      if (res) field$name else NULL
    }
  }) %>% unlist()
}

get_sortables <- function(fields){
  lapply(fields, function(field) {
    if (field$type == "int") field$name else NULL
  }) %>% unlist()
}

# Transform the geom_x_y column
tidy_geom_xy <- function(x) {
  lapply(x, function(xx) list(x = xx[[1]], y = xx[[2]]))
}

# Transform the geom column
tidy_geom <- function(x) {
  lapply(x, function(xx) {
    setNames(purrr::transpose(xx$coordinates[[1]]), c("x", "y")) %>%
      purrr::transpose() %>%
      dplyr::bind_rows()
  })
}


# Add additional parameters to the url
add_parameters_to_url <- function(url, nrows = NULL, refine = NULL, exclude = NULL, sort = NULL, q = NULL,
                                  lang = NULL, geofilter.distance = NULL, geofilter.polygon = NULL) {
  if (all(is.null(nrows),
          is.null(refine),
          is.null(exclude),
          is.null(sort),
          is.null(q),
          is.null(lang),
          is.null(geofilter.distance),
          is.null(geofilter.polygon))) return(url) else additional_url <- c()

          # Handle nrows
          if (!is.null(nrows)) additional_url <- c(additional_url, rows = nrows)

          # Handle refine
          if (!is.null(refine)) for (i in 1:length(refine)) {
            facet = names(refine)[i]
            val <- refine[[i]]
            names(val) = paste0("refine.", facet)
            additional_url <- c(additional_url, facet = facet, val)
          }

          # Handle exclude
          if (!is.null(exclude)) for (i in 1:length(exclude)) {
            facet = names(exclude)[i]
            val <- exclude[[i]]
            names(val) = paste0("exclude.", facet)
            additional_url <- c(additional_url, facet = facet, val)
          }

          # Handle sort
          if (!is.null(sort)) additional_url <- c(additional_url, sort = sort)

          # Handle q
          if (!is.null(q)) additional_url <- c(additional_url, q = q)

          # Handle geofilter.distance
          if (!is.null(geofilter.distance)) additional_url <- c(additional_url, geofilter.distance = paste(geofilter.distance, collapse = ","))

          # Handle geofilter.polygon
          if (!is.null(geofilter.polygon)) {
            geofilter.polygon <- (geofilter.polygon %>%
              tidyr::unite(polygon, lat, lon, sep = ",") %>%
              dplyr::mutate(polygon = paste0("(", polygon, ")")))$polygon %>%
              paste(collapse = ",")
            additional_url <- c(additional_url, geofilter.polygon = geofilter.polygon)
          }
          sep <- if (grepl("?", url, fixed = TRUE)) "&" else "?"
          url <- paste0(url, sep, paste(names(additional_url), additional_url, sep = "=", collapse = "&"))
          url

}

clean_list <- function(l) {
	l[!sapply(l, is.null)]
}

# Constants
portals <- function(){
  dplyr::data_frame(portals = c("ratp",
                                  "iledefrance",
                                  "infogreffe",
                                  "toulouse",
                                  "star",
                                  "issy",
                                  "stif",
                                  "paris",
                                  "04",
                                  "62",
                                  "92",
                                  "enesr"),
                    base_urls = c("http://data.ratp.fr",
                                  "http://data.iledefrance.fr",
                                  "http://datainfogreffe.fr",
                                  "https://data.toulouse-metropole.fr",
                                  "https://data.explore.star.fr",
                                  "http://data.issy.com",
                                  "http://opendata.stif.info",
                                  "http://opendata.paris.fr",
                                  "http://tourisme04.opendatasoft.com",
                                  "http://tourisme62.opendatasoft.com",
                                  "https://opendata.hauts-de-seine.fr",
                                  "http://data.enseignementsup-recherche.gouv.fr"))
}

get_base_url <- function(portal){
  (portals() %>%
    dplyr::filter(portals == portal))$base_urls
}

datasets_facets <- function(){
  c("modified",
    "published",
    "issued",
    "accrualperiodicity",
    "language",
    "license",
    "granularity",
    "dataquality",
    "theme",
    "keyword",
    "created",
    "creator",
    "contributor")
}

datasets_sortables <- function(){
  c("modified",
    "issued",
    "created")
}
