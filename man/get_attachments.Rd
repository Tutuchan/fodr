% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/doc_get_attachments.R
\name{get_attachments}
\alias{get_attachments}
\title{fetch dataset attachments}
\arguments{
\item{fname}{a character, the title of the file in the \code{attachments} element of the \code{info} field}

\item{output}{a character, the destination file name, if NULL (the default) it will be the same as \code{fname}}
}
\description{
This method is used to retrieve attachments from a  dataset.
}
\examples{
\donttest{
horodateurs <- fodr_dataset("paris", "horodateurs-transactions-de-paiement")
horodateurs$get_attachments(fname = "NOTICE_horodateurs.pdf")
}
}
