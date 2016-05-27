#' Wrappers
#'
#' These functions wrap the class initializers.
#'
#' @name wrappers
NULL

#' @param portal a character
#' @rdname wrappers
#' @export
fodr_portal <- function(portal){
  FODRPortal$new(portal)
}

#' @param id a character
#' @rdname wrappers
#' @export
fodr_dataset <- function(portal, id){
  FODRDataset$new(portal, id)
}
